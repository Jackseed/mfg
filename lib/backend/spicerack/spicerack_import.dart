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

    // 4. Ensure the importing player has a crewmate entry with userReference
    // so they appear in the "real members" filter alongside manually-added crew.
    await _findOrCreateCrewmate(
      crewRef: crewRef,
      crewId: crewId,
      spicerackUserId: playerUserId,
      name: playerReg.userIdentifier,
      userRef: currentUserReference,
    );

    // 5. Import ONLY the matches the importing user played in. Importing a
    //    full tournament's bracket is expensive (~10× more matches in a Swiss
    //    event) and most users don't need it on first import. Use
    //    [expandTournament] from the tournament page to fetch the rest on
    //    demand.
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

    // Crewmate lookups can race in parallel — the in-memory cache prevents
    // duplicate doc creation within a session, and the Firestore-by-name
    // dedup further protects against duplicates across sessions.
    final crewmateRefs = await Future.wait([
      _findOrCreateCrewmate(
        crewRef: crewRef,
        crewId: crewId,
        spicerackUserId: player1.userId,
        name: player1.name,
      ),
      _findOrCreateCrewmate(
        crewRef: crewRef,
        crewId: crewId,
        spicerackUserId: player2.userId,
        name: player2.name,
      ),
    ]);
    final crewmate1Ref = crewmateRefs[0];
    final crewmate2Ref = crewmateRefs[1];

    final dl1 = decklists[player1.userId];
    final dl2 = decklists[player2.userId];

    // Decks similarly run in parallel — they only depend on the crewmate
    // refs we just resolved.
    final deckRefs = await Future.wait([
      _findOrCreateDeck(
        crewId: crewId,
        crewmateRef: crewmate1Ref,
        crewmateId: crewmate1Ref.id,
        tournamentId: tournamentRef.id,
        decklist: dl1,
        playerName: player1.name,
      ),
      _findOrCreateDeck(
        crewId: crewId,
        crewmateRef: crewmate2Ref,
        crewmateId: crewmate2Ref.id,
        tournamentId: tournamentRef.id,
        decklist: dl2,
        playerName: player2.name,
      ),
    ]);
    final deck1Ref = deckRefs[0];
    final deck2Ref = deckRefs[1];

    final deck1Id = deck1Ref.id;
    final deck2Id = deck2Ref.id;

    final score1 = player1.gamesWon;
    final score2 = player2.gamesWon;

    final sortedDeckIds = [deck1Id, deck2Id]..sort();
    final matchupIdStr = '${tournamentRef.id}_${sortedDeckIds.join('_')}';

    // Matchup must exist (or be created) before the game so we can reference it.
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

    // Final 4 writes (game + 2 player sub-docs + matchup gameIds update) all
    // commit together as a single batch — one round-trip instead of four.
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
    gameData['deckIds'] = [deck1Id, deck2Id];

    final player1Ref = PlayersRecord.createDoc(gameRef);
    final player2Ref = PlayersRecord.createDoc(gameRef);

    final batch = _firestore.batch();
    batch.set(gameRef, gameData);
    batch.set(
        player1Ref,
        createPlayersRecordData(
          score: score1,
          deckName: dl1?.archetype ?? dl1?.name ?? 'Unknown',
          deckRef: deck1Ref,
          deckId: deck1Id,
          crewmateId: crewmate1Ref.id,
          crewId: crewId,
          crewmateRef: crewmate1Ref,
        ));
    batch.set(
        player2Ref,
        createPlayersRecordData(
          score: score2,
          deckName: dl2?.archetype ?? dl2?.name ?? 'Unknown',
          deckRef: deck2Ref,
          deckId: deck2Id,
          crewmateId: crewmate2Ref.id,
          crewId: crewId,
          crewmateRef: crewmate2Ref,
        ));
    batch.update(matchupRef, {
      'gameIds': FieldValue.arrayUnion([gameRef.id]),
    });
    await batch.commit();
  }

  /// Expand a tournament that was imported player-only by pulling in every
  /// match in the bracket. Existing matchups are skipped via the natural
  /// dedup in [_findOrCreateMatchup]; only the missing ones get created.
  ///
  /// Returns the number of matches we attempted to import (the dedup happens
  /// silently inside [_findOrCreateMatchup], so the precise "new vs existing"
  /// split isn't surfaced — the caller can re-render and Firestore is the
  /// source of truth).
  Future<int> expandTournament({
    required int spicerackEventId,
    void Function(int current, int total, String status)? onProgress,
  }) async {
    onProgress?.call(0, 1, 'Loading tournament data...');

    // 1. Find the existing tournament doc to reuse its crew/org context.
    final existing = await _firestore
        .collection('tournaments')
        .where('spicerackEventId', isEqualTo: spicerackEventId)
        .limit(1)
        .get();
    if (existing.docs.isEmpty) {
      throw StateError(
          'Tournament for event $spicerackEventId not yet imported');
    }
    final tournamentDoc = existing.docs.first;
    final tournamentRef = tournamentDoc.reference;
    final tData = tournamentDoc.data();
    final crewId = tData['crewId'] as String? ?? '';
    final orgRef = tData['organizationRef'] as DocumentReference?;
    final orgId = tData['organizationId'] as String? ?? '';
    if (crewId.isEmpty || orgRef == null || orgId.isEmpty) {
      throw StateError('Tournament is missing crew/org metadata');
    }
    final crewRef = _firestore.collection('crews').doc(crewId);

    // 2. Reconstruct the SpicerackEvent shell needed by _importMatch.
    final dateField = tData['date'];
    DateTime? startDate;
    if (dateField is Timestamp) startDate = dateField.toDate();
    final event = SpicerackEvent(
      id: spicerackEventId,
      name: tData['name'] as String? ?? '',
      format: tData['format'] as String? ?? '',
      startDate: startDate,
      conventionId: null,
      conventionName: null,
      organizerId: 0, // not used downstream
      organizerName: '',
    );

    // 3. Fetch the full bracket + registrations + decklists in parallel.
    final service = SpicerackService();
    final fetched = await Future.wait([
      service.getEventDetails(spicerackEventId),
      service.getEventRegistrations(spicerackEventId),
      service.getEventDecklists(spicerackEventId),
    ]);
    final eventDetail = fetched[0] as Map<String, dynamic>;
    final registrations = fetched[1] as List<SpicerackRegistration>;
    final decklists = fetched[2] as Map<int, SpicerackDecklist>;
    final allMatches = service.parseMatches(eventDetail);

    final allRegs = <int, SpicerackRegistration>{
      for (final r in registrations) r.userId: r
    };

    final ones = allMatches.where((m) => m.isOneVsOne).toList();
    final stopwatch = Stopwatch()..start();

    // 4. Import each match in parallel — _findOrCreateMatchup dedups on
    //    (matchupId, crewId) so already-imported matches become no-ops.
    int progress = 0;
    onProgress?.call(0, ones.length, 'Importing ${ones.length} matches...');

    final futures = ones.map((match) async {
      try {
        await _importMatch(
          match: match,
          event: event,
          crewRef: crewRef,
          crewId: crewId,
          orgRef: orgRef,
          orgId: orgId,
          tournamentRef: tournamentRef,
          playerUserId: 0, // unused inside _importMatch
          allRegistrations: allRegs,
          decklists: decklists,
        );
      } catch (e) {
        print('[ImportV2] expand match failed: $e');
      } finally {
        progress++;
        onProgress?.call(progress, ones.length,
            'Imported $progress/${ones.length} matches');
      }
    }).toList();

    await Future.wait(futures);
    print('[ImportV2] expandTournament processed ${ones.length} matches '
        'in ${stopwatch.elapsedMilliseconds}ms');
    return ones.length;
  }

  /// Delete ALL data created by the importer:
  /// - Matchups with a non-empty tournamentId
  /// - Games referenced by those matchups (and their player sub-docs)
  /// - Tournament documents with a spicerackEventId
  /// User-created matchups/games (no tournamentId) are preserved.
  ///
  /// Reads are parallelised; deletes are issued via [WriteBatch] in chunks of
  /// 500 ops (Firestore's hard cap). This turns hundreds of round-trips into
  /// a handful of batch commits.
  Future<void> _cleanAllImportedData() async {
    final stopwatch = Stopwatch()..start();

    // 1. Discover all tournaments to clean.
    final allTournaments = await _firestore
        .collection('tournaments')
        .where('spicerackEventId', isGreaterThan: 0)
        .get();

    final tournamentIds = <String>{};
    for (final doc in allTournaments.docs) {
      final tid = doc.data()['tournamentId'] as String?;
      if (tid != null && tid.isNotEmpty) tournamentIds.add(tid);
    }
    final tidList = tournamentIds.toList();

    // 2. Fetch matchups in parallel (chunked by Firestore's whereIn limit of 30).
    final matchupChunkFutures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (var i = 0; i < tidList.length; i += 30) {
      final end = i + 30 > tidList.length ? tidList.length : i + 30;
      matchupChunkFutures.add(_firestore
          .collection('matchups')
          .where('tournamentId', whereIn: tidList.sublist(i, end))
          .get());
    }

    // Also fetch orphaned matchups (referenced by tournamentRef instead of tournamentId).
    final orphanedFutures = allTournaments.docs.map((doc) => _firestore
        .collection('matchups')
        .where('tournamentRef', isEqualTo: doc.reference)
        .get());

    // Decks scoped to those tournaments.
    final deckChunkFutures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (var i = 0; i < tidList.length; i += 30) {
      final end = i + 30 > tidList.length ? tidList.length : i + 30;
      deckChunkFutures.add(_firestore
          .collection('decks')
          .where('tournamentId', whereIn: tidList.sublist(i, end))
          .get());
    }

    final allReads = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      ...matchupChunkFutures,
      ...orphanedFutures,
      ...deckChunkFutures,
    ]);

    final matchupSnaps = allReads.sublist(0, matchupChunkFutures.length);
    final orphanedSnaps = allReads.sublist(matchupChunkFutures.length,
        matchupChunkFutures.length + orphanedFutures.length);
    final deckSnaps = allReads.sublist(
        matchupChunkFutures.length + orphanedFutures.length);

    // De-duplicate matchups by reference path (orphaned set may overlap with main set).
    final matchupDocs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final snap in [...matchupSnaps, ...orphanedSnaps]) {
      for (final doc in snap.docs) {
        matchupDocs[doc.reference.path] = doc;
      }
    }

    // 3. Collect all game IDs we need to clean up.
    final gameIds = <String>{};
    for (final mDoc in matchupDocs.values) {
      final ids = (mDoc.data()['gameIds'] as List?)?.cast<String>() ?? [];
      gameIds.addAll(ids);
    }

    // 4. Fetch all player sub-doc collections in parallel — one query per game.
    final playerSubcolFutures = gameIds.map((gid) =>
        _firestore.collection('games').doc(gid).collection('players').get());
    final playerSnaps = await Future.wait(playerSubcolFutures);

    // 5. Build the full delete list, then commit in batches of 500.
    final deletes = <DocumentReference>[];
    for (final snap in playerSnaps) {
      for (final p in snap.docs) {
        deletes.add(p.reference);
      }
    }
    for (final gid in gameIds) {
      deletes.add(_firestore.collection('games').doc(gid));
    }
    for (final mDoc in matchupDocs.values) {
      deletes.add(mDoc.reference);
    }
    for (final snap in deckSnaps) {
      for (final d in snap.docs) {
        deletes.add(d.reference);
      }
    }
    for (final t in allTournaments.docs) {
      deletes.add(t.reference);
    }

    // Commit batches in parallel — each Firestore batch handles up to 500 ops.
    final batchFutures = <Future<void>>[];
    for (var i = 0; i < deletes.length; i += 500) {
      final batch = _firestore.batch();
      final end = i + 500 > deletes.length ? deletes.length : i + 500;
      for (var j = i; j < end; j++) {
        batch.delete(deletes[j]);
      }
      batchFutures.add(batch.commit());
    }
    await Future.wait(batchFutures);

    print('[ImportV2] cleanup deleted ${deletes.length} docs in '
        '${stopwatch.elapsedMilliseconds}ms');
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

    // Create new crew — marked isSolo so users know it's an LGS crew,
    // not a friend crew. They can still create/join a real crew later.
    final crewRef = _firestore.collection('crews').doc();
    await crewRef.set(createCrewsRecordData(
      name: organizerName,
      ref: crewRef,
      isSolo: true,
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
    // Set for the importing user so they appear as a real crew member.
    DocumentReference? userRef,
  }) async {
    final cacheKey = '${crewId}_$spicerackUserId';
    if (_crewmateCache.containsKey(cacheKey)) {
      // If we now have a userRef and the cached crewmate doesn't, backfill it.
      if (userRef != null) {
        await _crewmateCache[cacheKey]!
            .set({'userReference': userRef}, SetOptions(merge: true));
      }
      return _crewmateCache[cacheKey]!;
    }

    // Check if crewmate exists with this name in this crew
    final existing = await crewRef
        .collection('crewmates')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final ref = existing.docs.first.reference;
      if (userRef != null) {
        await ref.set({'userReference': userRef}, SetOptions(merge: true));
      }
      _crewmateCache[cacheKey] = ref;
      return ref;
    }

    // Create new crewmate
    final crewmateRef = CrewmatesRecord.createDoc(crewRef);
    await crewmateRef.set(createCrewmatesRecordData(
      name: name,
      userId: spicerackUserId.toString(),
      userReference: userRef,
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

  /// Set user's crewId to the organizer they played with the most.
  Future<void> _assignUserToMostPlayedCrew() async {
    if (currentUserReference == null) return;

    // Only update the user's org memberships — never touch crewId/crewRef.
    // The crew is the user's friend group (created manually); orgs are LGS
    // stores where tournaments happen. Keeping them separate means the
    // crewmate list and deck list stay clean of tournament opponents.
    if (_orgIdsForUser.isNotEmpty) {
      await currentUserReference!.set({
        'organizationIds': FieldValue.arrayUnion(_orgIdsForUser.toList()),
      }, SetOptions(merge: true));
    }
  }
}
