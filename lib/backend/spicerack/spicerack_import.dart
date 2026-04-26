import 'package:cloud_firestore/cloud_firestore.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/crews_record.dart';
import '/backend/schema/crewmates_record.dart';
import '/backend/schema/decks_record.dart';
import '/backend/schema/games_record.dart';
import '/backend/schema/matchups_record.dart';
import '/backend/schema/organizations_record.dart';
import '/backend/schema/organization_members_record.dart';
import '/backend/schema/players_record.dart';
import '/backend/schema/spicerack_decks_record.dart';
import '/backend/schema/tournaments_record.dart';
import '/backend/schema/users_record.dart';
import '/backend/schema/structs/score_struct.dart';
import 'spicerack_service.dart';
import 'archetype_card_resolver.dart';

/// Orchestrates importing Spicerack tournament data into Firestore.
class SpicerackImporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cache of organizer ID -> crew doc ref (to avoid creating duplicates).
  final Map<int, DocumentReference> _crewCache = {};

  /// Cache of organizer ID -> organization doc ref.
  final Map<int, DocumentReference> _orgCache = {};

  /// Cache of (crewId, spicerackUserId) -> crewmate doc ref.
  final Map<String, DocumentReference> _crewmateCache = {};

  /// Cache of (crewId, deckKey) -> deck doc ref.
  final Map<String, DocumentReference> _deckCache = {};

  /// Track how many events each organizer has (to pick the main crew).
  final Map<int, int> _organizerEventCount = {};

  /// Organizations the importing user was added to during this run.
  /// Flushed to `users/{uid}.organizationIds` at the end.
  final Set<String> _orgIdsForUser = {};

  /// Import all player events into Firestore.
  /// Returns the number of events imported.
  /// If [forceReimport] is true, first cleans all tournament-linked data
  /// (matchups/games with a tournamentId, and tournaments with a spicerackEventId),
  /// then re-imports everything. User-created data without tournamentId is preserved.
  Future<int> importEvents({
    required List<PlayerEventResult> events,
    bool forceReimport = false,
    void Function(int current, int total, String status)? onProgress,
  }) async {
    print('[ImportV2] START forceReimport=$forceReimport events=${events.length}');
    // If force reimport, clean ALL imported data first (safe: only touches
    // data with tournamentId set, i.e. data created by this importer).
    if (forceReimport) {
      onProgress?.call(0, events.length, 'Cleaning old imported data...');
      await _cleanAllImportedData();
    }

    int imported = 0;

    for (var i = 0; i < events.length; i++) {
      final result = events[i];
      onProgress?.call(i + 1, events.length,
          'Importing ${result.event.name}...');

      try {
        await _importSingleEvent(result, forceReimport: forceReimport);
        imported++;

        // Track organizer frequency
        final orgId = result.event.organizerId;
        _organizerEventCount[orgId] =
            (_organizerEventCount[orgId] ?? 0) + 1;
      } catch (e) {
        // Log but continue with other events
        print('Error importing event ${result.event.name}: $e');
      }
    }

    // Set user's crew to the most frequent organizer
    await _assignUserToMostPlayedCrew();

    onProgress?.call(
        events.length, events.length, 'Imported $imported events!');
    return imported;
  }

  /// Import a single event.
  Future<void> _importSingleEvent(PlayerEventResult result,
      {bool forceReimport = false}) async {
    final event = result.event;
    final playerReg = result.registration;
    final playerUserId = playerReg.userId;

    // 1. Find or create Crew (by organizer)
    final crewRef = await _findOrCreateCrew(
      organizerId: event.organizerId,
      organizerName: event.organizerName,
    );
    final crewId = crewRef.id;

    // 1b. Find or create Organization (Spicerack store context, distinct from
    //     the crew of friends). The importing user is added as admin.
    final orgRef = await _findOrCreateOrganization(
      organizerId: event.organizerId,
      organizerName: event.organizerName,
    );
    final orgId = orgRef.id;
    _orgIdsForUser.add(orgId);

    // 2. Check if tournament already imported (dedup by spicerackEventId)
    final existingTournament = await _firestore
        .collection('tournaments')
        .where('spicerackEventId', isEqualTo: event.id)
        .limit(1)
        .get();
    if (existingTournament.docs.isNotEmpty && !forceReimport) {
      return; // Already imported
    }

    // If force reimport, skip — data already cleaned globally in importEvents()
    if (existingTournament.docs.isNotEmpty && forceReimport) {
      // Already cleaned, proceed to re-create
    }

    // 3. Create Tournament (scoped to organization; crewId kept for back-compat)
    final tournamentRef = _firestore.collection('tournaments').doc();
    await tournamentRef.set(createTournamentsRecordData(
      name: event.name,
      format: event.format,
      date: event.startDate,
      crewId: crewId,
      spicerackEventId: event.id,
      tournamentId: tournamentRef.id,
      organizationRef: orgRef,
      organizationId: orgId,
    ));

    // 4. Ensure all players have crewmate entries
    // First, ensure the importing player is a crewmate
    await _findOrCreateCrewmate(
      crewRef: crewRef,
      crewId: crewId,
      spicerackUserId: playerUserId,
      name: playerReg.userIdentifier,
    );

    // 5. Import player's matches
    final playerMatches = result.matches.where(
      (m) => m.players.any((p) => p.userId == playerUserId),
    );

    for (final match in playerMatches) {
      await _importMatch(
        match: match,
        event: event,
        crewRef: crewRef,
        crewId: crewId,
        orgRef: orgRef,
        orgId: orgId,
        tournamentRef: tournamentRef,
        playerUserId: playerUserId,
        allRegistrations: result.allRegistrations,
        decklists: result.decklists,
      );
    }
  }

  /// Import a single 1v1 match.
  Future<void> _importMatch({
    required SpicerackMatch match,
    required SpicerackEvent event,
    required DocumentReference crewRef,
    required String crewId,
    required DocumentReference orgRef,
    required String orgId,
    required DocumentReference tournamentRef,
    required int playerUserId,
    required Map<int, SpicerackRegistration> allRegistrations,
    required Map<int, SpicerackDecklist> decklists,
  }) async {
    if (!match.isOneVsOne) return;

    final player1 = match.players[0];
    final player2 = match.players[1];

    // Ensure both players are crewmates
    final crewmate1Ref = await _findOrCreateCrewmate(
      crewRef: crewRef,
      crewId: crewId,
      spicerackUserId: player1.userId,
      name: player1.name,
    );
    final crewmate2Ref = await _findOrCreateCrewmate(
      crewRef: crewRef,
      crewId: crewId,
      spicerackUserId: player2.userId,
      name: player2.name,
    );

    // Find or create decks for both players
    final dl1 = decklists[player1.userId];
    final dl2 = decklists[player2.userId];

    final deck1Ref = await _findOrCreateDeck(
      crewId: crewId,
      crewmateRef: crewmate1Ref,
      crewmateId: crewmate1Ref.id,
      tournamentId: tournamentRef.id,
      decklist: dl1,
      playerName: player1.name,
    );
    final deck2Ref = await _findOrCreateDeck(
      crewId: crewId,
      crewmateRef: crewmate2Ref,
      crewmateId: crewmate2Ref.id,
      tournamentId: tournamentRef.id,
      decklist: dl2,
      playerName: player2.name,
    );

    final deck1Id = deck1Ref.id;
    final deck2Id = deck2Ref.id;

    // Store actual game counts for BO3 display (e.g. 2/1 or 2/0).
    // _userResult() compares > / < so WIN/LOSS/DRAW badges still work correctly.
    final score1 = player1.gamesWon;
    final score2 = player2.gamesWon;
    print('[ImportV2] ${player1.name} gamesWon=$score1 vs ${player2.name} gamesWon=$score2');

    // Create matchup ID from tournament + sorted deck IDs (unique per tournament)
    final sortedDeckIds = [deck1Id, deck2Id]..sort();
    final matchupIdStr = '${tournamentRef.id}_${sortedDeckIds.join('_')}';

    // Find or create matchup
    final matchupRef = await _findOrCreateMatchup(
      crewId: crewId,
      orgRef: orgRef,
      orgId: orgId,
      matchupId: matchupIdStr,
      deck1Id: deck1Id,
      deck1Ref: deck1Ref,
      deck2Id: deck2Id,
      deck2Ref: deck2Ref,
      score1: score1,
      score2: score2,
      tournamentRef: tournamentRef,
      tournamentId: tournamentRef.id,
      round: match.roundNumber,
    );

    // Create game — scoped to organization (Spicerack context).
    final gameRef = _firestore.collection('games').doc();
    final gameData = createGamesRecordData(
      date: event.startDate,
      docReference: gameRef,
      crewId: crewId,
      gameId: gameRef.id,
      matchupId: matchupIdStr,
      matchupRef: matchupRef,
      organizationRef: orgRef,
      organizationId: orgId,
      tournamentRef: tournamentRef,
      tournamentId: tournamentRef.id,
    );
    // Add deckIds array
    gameData['deckIds'] = [deck1Id, deck2Id];
    await gameRef.set(gameData);

    // Create player sub-documents
    await _createPlayerDoc(
      gameRef: gameRef,
      crewId: crewId,
      crewmateRef: crewmate1Ref,
      crewmateId: crewmate1Ref.id,
      deckRef: deck1Ref,
      deckId: deck1Id,
      deckName: dl1?.archetype ?? dl1?.name ?? 'Unknown',
      score: score1,
    );
    await _createPlayerDoc(
      gameRef: gameRef,
      crewId: crewId,
      crewmateRef: crewmate2Ref,
      crewmateId: crewmate2Ref.id,
      deckRef: deck2Ref,
      deckId: deck2Id,
      deckName: dl2?.archetype ?? dl2?.name ?? 'Unknown',
      score: score2,
    );

    // Add game ID to matchup
    await matchupRef.update({
      'gameIds': FieldValue.arrayUnion([gameRef.id]),
    });
  }

  /// Delete ALL data created by the importer:
  /// - Matchups with a non-empty tournamentId
  /// - Games referenced by those matchups (and their player sub-docs)
  /// - Tournament documents with a spicerackEventId
  /// User-created matchups/games (no tournamentId) are preserved.
  Future<void> _cleanAllImportedData() async {
    // 1. Delete all matchups that have a tournamentId set
    //    (We can't query "where field is not empty", so we query all matchups
    //    and filter client-side — or we query tournaments first to get all IDs)
    final allTournaments = await _firestore
        .collection('tournaments')
        .where('spicerackEventId', isGreaterThan: 0)
        .get();

    final tournamentIds = <String>{};
    for (final doc in allTournaments.docs) {
      final tid = doc.data()['tournamentId'] as String?;
      if (tid != null && tid.isNotEmpty) tournamentIds.add(tid);
    }

    // Delete matchups for each tournament (batched by whereIn limit of 30)
    final tidList = tournamentIds.toList();
    for (var i = 0; i < tidList.length; i += 30) {
      final batch =
          tidList.sublist(i, i + 30 > tidList.length ? tidList.length : i + 30);
      final matchups = await _firestore
          .collection('matchups')
          .where('tournamentId', whereIn: batch)
          .get();

      for (final doc in matchups.docs) {
        // Delete games associated with this matchup
        final gameIds =
            (doc.data()['gameIds'] as List?)?.cast<String>() ?? [];
        for (final gameId in gameIds) {
          // Delete player sub-docs first
          final playerDocs = await _firestore
              .collection('games')
              .doc(gameId)
              .collection('players')
              .get();
          for (final pDoc in playerDocs.docs) {
            await pDoc.reference.delete();
          }
          await _firestore.collection('games').doc(gameId).delete();
        }
        await doc.reference.delete();
      }
    }

    // Also clean up any matchups with old-format matchupId (no tournament prefix)
    // that might have been created before the fix. These have a tournamentId that
    // points to one of our known tournaments but might not be found above due to
    // the cross-contamination bug.
    // Query matchups that reference any known tournament
    for (final doc in allTournaments.docs) {
      final tournamentRef = doc.reference;
      final orphanedMatchups = await _firestore
          .collection('matchups')
          .where('tournamentRef', isEqualTo: tournamentRef)
          .get();
      for (final mDoc in orphanedMatchups.docs) {
        final gameIds =
            (mDoc.data()['gameIds'] as List?)?.cast<String>() ?? [];
        for (final gameId in gameIds) {
          final playerDocs = await _firestore
              .collection('games')
              .doc(gameId)
              .collection('players')
              .get();
          for (final pDoc in playerDocs.docs) {
            await pDoc.reference.delete();
          }
          await _firestore.collection('games').doc(gameId).delete();
        }
        await mDoc.reference.delete();
      }
    }

    // 2. Delete tournament-scoped deck snapshots
    for (var i = 0; i < tidList.length; i += 30) {
      final batch =
          tidList.sublist(i, i + 30 > tidList.length ? tidList.length : i + 30);
      final decks = await _firestore
          .collection('decks')
          .where('tournamentId', whereIn: batch)
          .get();
      for (final doc in decks.docs) {
        await doc.reference.delete();
      }
    }

    // 3. Delete all tournament documents
    for (final doc in allTournaments.docs) {
      await doc.reference.delete();
    }
  }

  /// Find or create an organization for the given Spicerack organizer. Uses
  /// the (stringified) organizer id as doc id, so identical stores converge
  /// across users/crews.
  Future<DocumentReference> _findOrCreateOrganization({
    required int organizerId,
    required String organizerName,
  }) async {
    if (_orgCache.containsKey(organizerId)) {
      return _orgCache[organizerId]!;
    }

    final docId = 'spicerack_$organizerId';
    final orgRef = _firestore.collection('organizations').doc(docId);
    final snap = await orgRef.get();

    if (!snap.exists) {
      await orgRef.set(createOrganizationsRecordData(
        name: organizerName,
        kind: 'spicerack_store',
        spicerackStoreId: organizerId.toString(),
        allowsManualGames: false,
        createdBy: currentUserReference?.id ?? '',
        createdAt: DateTime.now(),
        memberCount: 1,
        organizationId: orgRef.id,
      ));
    }

    // Ensure the importing user is a member (admin if they created the org).
    final uid = currentUserReference?.id;
    if (uid != null && uid.isNotEmpty) {
      final memberRef = orgRef.collection('members').doc(uid);
      final memberSnap = await memberRef.get();
      if (!memberSnap.exists) {
        await memberRef.set(createOrganizationMembersRecordData(
          userRef: currentUserReference,
          uid: uid,
          joinedAt: DateTime.now(),
          role: snap.exists ? 'member' : 'admin',
        ));
        if (snap.exists) {
          await orgRef.update({
            'memberCount': FieldValue.increment(1),
          });
        }
      }
    }

    _orgCache[organizerId] = orgRef;
    return orgRef;
  }

  /// Find or create a crew for the given organizer.
  Future<DocumentReference> _findOrCreateCrew({
    required int organizerId,
    required String organizerName,
  }) async {
    if (_crewCache.containsKey(organizerId)) {
      return _crewCache[organizerId]!;
    }

    // Check Firestore for existing crew with this name
    final existing = await _firestore
        .collection('crews')
        .where('name', isEqualTo: organizerName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      _crewCache[organizerId] = existing.docs.first.reference;
      return existing.docs.first.reference;
    }

    // Create new crew
    final crewRef = _firestore.collection('crews').doc();
    await crewRef.set(createCrewsRecordData(
      name: organizerName,
      ref: crewRef,
    ));

    _crewCache[organizerId] = crewRef;
    return crewRef;
  }

  /// Find or create a crewmate in a crew.
  Future<DocumentReference> _findOrCreateCrewmate({
    required DocumentReference crewRef,
    required String crewId,
    required int spicerackUserId,
    required String name,
  }) async {
    final cacheKey = '${crewId}_$spicerackUserId';
    if (_crewmateCache.containsKey(cacheKey)) {
      return _crewmateCache[cacheKey]!;
    }

    // Check if crewmate exists with this name in this crew
    final existing = await crewRef
        .collection('crewmates')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      _crewmateCache[cacheKey] = existing.docs.first.reference;
      return existing.docs.first.reference;
    }

    // Create new crewmate
    final crewmateRef = CrewmatesRecord.createDoc(crewRef);
    await crewmateRef.set(createCrewmatesRecordData(
      name: name,
      userId: spicerackUserId.toString(),
    ));

    _crewmateCache[cacheKey] = crewmateRef;
    return crewmateRef;
  }

  /// Find or create a deck.
  ///
  /// When [decklist] is set, we first consult the global `spicerackDecks/{id}`
  /// pivot — if another user (any crew) already tagged this Spicerack decklist,
  /// we reuse their archetype / avatar / moxfield. Otherwise we resolve via
  /// Scryfall and upsert the pivot so subsequent imports benefit.
  Future<DocumentReference> _findOrCreateDeck({
    required String crewId,
    required DocumentReference crewmateRef,
    required String crewmateId,
    required String tournamentId,
    SpicerackDecklist? decklist,
    required String playerName,
  }) async {
    final deckName = decklist?.name ?? '$playerName\'s deck';
    // One deck per player per tournament — keyed by tournament + crewmate.
    final cacheKey = '${tournamentId}_$crewmateId';

    if (_deckCache.containsKey(cacheKey)) {
      return _deckCache[cacheKey]!;
    }

    // Check if deck already exists for this player in this tournament.
    final existing = await _firestore
        .collection('decks')
        .where('crewId', isEqualTo: crewId)
        .where('crewmateId', isEqualTo: crewmateId)
        .where('tournamentId', isEqualTo: tournamentId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      _deckCache[cacheKey] = existing.docs.first.reference;
      return existing.docs.first.reference;
    }

    // 1. Consult the global spicerackDecks pivot if we have a decklist id.
    String? avatarUrl;
    String? avatarName;
    String? avatarCardName;
    String? moxfieldUrl = decklist?.moxfieldUrl;
    DocumentReference? archetypeRef;
    SpicerackDecksRecord? pivot;

    if (decklist != null) {
      final pivotRef = SpicerackDecksRecord.docRef(decklist.id);
      final pivotSnap = await pivotRef.get();
      if (pivotSnap.exists) {
        pivot = SpicerackDecksRecord.fromSnapshot(pivotSnap);
        if (pivot.hasAvatarUrl() && pivot.avatarUrl.isNotEmpty) {
          avatarUrl = pivot.avatarUrl;
        }
        if (pivot.hasArchetypeName() && pivot.archetypeName.isNotEmpty) {
          avatarName = pivot.archetypeName;
        }
        if (pivot.hasAvatarCardName() && pivot.avatarCardName.isNotEmpty) {
          avatarCardName = pivot.avatarCardName;
        }
        if (pivot.hasArchetypeRef()) {
          archetypeRef = pivot.archetypeRef;
        }
        if (pivot.hasMoxfieldUrl() && pivot.moxfieldUrl.isNotEmpty) {
          moxfieldUrl ??= pivot.moxfieldUrl;
        }
      }
    }

    // 2. If the pivot didn't supply an avatar, resolve via Scryfall and upsert
    //    the pivot so other crews benefit next time.
    if (avatarUrl == null) {
      final resolveSource = (decklist?.archetype != null &&
              decklist!.archetype!.isNotEmpty)
          ? decklist.archetype!
          : (!deckName.toLowerCase().endsWith("'s deck") &&
                  !deckName.toLowerCase().endsWith('\'s deck') &&
                  deckName != 'Unknown Deck')
              ? deckName
              : null;

      if (resolveSource != null) {
        avatarUrl = await ArchetypeCardResolver.resolve(resolveSource);
        if (avatarUrl != null) {
          avatarName = resolveSource;
        }
      }

      // Upsert pivot if we have a decklist id (seeds the shared attribution
      // even if only moxfield/avatar were resolved; archetypeRef stays null
      // until a user tags it from the bottom sheet).
      if (decklist != null && pivot == null) {
        await SpicerackDecksRecord.docRef(decklist.id).set(
          createSpicerackDecksRecordData(
            decklistId: decklist.id,
            archetypeName: avatarName,
            avatarUrl: avatarUrl,
            avatarCardName: avatarName, // source name = archetype label
            moxfieldPublicId: decklist.moxfieldPublicId,
            moxfieldUrl: decklist.moxfieldUrl,
            lastEditedBy: currentUserReference?.id,
            lastEditedAt: DateTime.now(),
          ),
          SetOptions(merge: true),
        );
      }
    }

    // Create new deck (tournament-scoped snapshot)
    final deckRef = _firestore.collection('decks').doc();
    await deckRef.set(createDecksRecordData(
      name: deckName,
      crewId: crewId,
      crewmateId: crewmateId,
      crewmateRef: crewmateRef,
      deckId: deckRef.id,
      tournamentId: tournamentId,
      moxfieldUrl: moxfieldUrl,
      avatarUrl: avatarUrl,
      avatarName: avatarName,
      avatarCardName: avatarCardName,
      archetypeRef: archetypeRef,
      spicerackDecklistId: decklist?.id,
    ));

    _deckCache[cacheKey] = deckRef;
    return deckRef;
  }

  /// Find or create a matchup and update scores.
  Future<DocumentReference> _findOrCreateMatchup({
    required String crewId,
    required DocumentReference orgRef,
    required String orgId,
    required String matchupId,
    required String deck1Id,
    required DocumentReference deck1Ref,
    required String deck2Id,
    required DocumentReference deck2Ref,
    required int score1,
    required int score2,
    required DocumentReference tournamentRef,
    required String tournamentId,
    required int round,
  }) async {
    // Check for existing matchup
    final existing = await _firestore
        .collection('matchups')
        .where('matchupId', isEqualTo: matchupId)
        .where('crewId', isEqualTo: crewId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final ref = existing.docs.first.reference;
      // Replace scores — each Spicerack match already carries the final gamesWon
      // for the full match, so incrementing would double-count on re-import.
      await ref.update({
        'scores': [
          {'deckId': deck1Id, 'score': score1, 'deckRef': deck1Ref},
          {'deckId': deck2Id, 'score': score2, 'deckRef': deck2Ref},
        ],
        'round': round,
      });
      return ref;
    }

    // Create new matchup
    final matchupRef = _firestore.collection('matchups').doc();
    final matchupData = createMatchupsRecordData(
      matchupId: matchupId,
      crewId: crewId,
      tournamentRef: tournamentRef,
      tournamentId: tournamentId,
      organizationRef: orgRef,
      organizationId: orgId,
      round: round,
    );
    matchupData['deckIds'] = [deck1Id, deck2Id];
    matchupData['gameIds'] = <String>[];
    matchupData['scores'] = [
      {'deckId': deck1Id, 'score': score1, 'deckRef': deck1Ref},
      {'deckId': deck2Id, 'score': score2, 'deckRef': deck2Ref},
    ];

    await matchupRef.set(matchupData);
    return matchupRef;
  }

  /// Create a Player sub-document under a Game.
  Future<void> _createPlayerDoc({
    required DocumentReference gameRef,
    required String crewId,
    required DocumentReference crewmateRef,
    required String crewmateId,
    required DocumentReference deckRef,
    required String deckId,
    required String deckName,
    required int score,
  }) async {
    final playerRef = PlayersRecord.createDoc(gameRef);
    await playerRef.set(createPlayersRecordData(
      score: score,
      deckName: deckName,
      deckRef: deckRef,
      deckId: deckId,
      crewmateId: crewmateId,
      crewId: crewId,
      crewmateRef: crewmateRef,
    ));
  }

  /// Set user's crewId to the organizer they played with the most.
  Future<void> _assignUserToMostPlayedCrew() async {
    if (currentUserReference == null) return;

    // Always persist organizationIds — even if nothing new was imported we
    // want the user marked as member of every org they touched.
    if (_orgIdsForUser.isNotEmpty) {
      await currentUserReference!.set({
        'organizationIds': FieldValue.arrayUnion(_orgIdsForUser.toList()),
      }, SetOptions(merge: true));
    }

    if (_organizerEventCount.isEmpty) return;

    // Find organizer with most events
    int maxCount = 0;
    int? bestOrganizer;
    for (final entry in _organizerEventCount.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        bestOrganizer = entry.key;
      }
    }

    if (bestOrganizer == null || !_crewCache.containsKey(bestOrganizer)) return;

    final crewRef = _crewCache[bestOrganizer]!;
    final crewId = crewRef.id;

    // Find the user's crewmate in this crew
    final crewmateKey = _crewmateCache.keys.where((k) => k.startsWith('${crewId}_'));
    DocumentReference? crewmateRef;
    if (crewmateKey.isNotEmpty) {
      crewmateRef = _crewmateCache[crewmateKey.first];
    }

    await currentUserReference!.set({
      'crewId': crewId,
      'crewRef': crewRef,
      if (crewmateRef != null) 'crewmateRef': crewmateRef,
    }, SetOptions(merge: true));
  }
}
