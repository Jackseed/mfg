import 'package:cloud_firestore/cloud_firestore.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/archetypes_record.dart';
import '/backend/schema/spicerack_decks_record.dart';

/// CRUD + search helpers for the global `archetypes` collection.
///
/// The collection is keyed by a slug derived from the archetype name, so
/// concurrent writes from different crews converge on the same document.
class ArchetypeService {
  ArchetypeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Lowercase + trim + collapse whitespace for case-insensitive comparison.
  static String normalize(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Deterministic slug used as archetype doc id. "Bant Control" → "bant-control".
  static String slugify(String raw) {
    final n = normalize(raw);
    final s = n.replaceAll(RegExp(r"[^a-z0-9]+"), '-');
    return s.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Search archetypes by prefix on `nameLower`. Returns up to [limit] matches.
  /// Falls back to substring matching on aliases for flexibility.
  Future<List<ArchetypesRecord>> search(String query, {int limit = 10}) async {
    final q = normalize(query);
    if (q.isEmpty) return [];

    // Firestore doesn't support LIKE — use a prefix range on nameLower.
    final end = '$q\uf8ff';
    final byPrefix = await _firestore
        .collection('archetypes')
        .orderBy('nameLower')
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThanOrEqualTo: end)
        .limit(limit)
        .get();

    final results = byPrefix.docs
        .map((d) => ArchetypesRecord.fromSnapshot(d))
        .toList();
    if (results.isNotEmpty) return results;

    // Fall back to alias containment (client-side filter over a bounded set).
    final all = await _firestore
        .collection('archetypes')
        .orderBy('gameCount', descending: true)
        .limit(200)
        .get();

    final matches = <ArchetypesRecord>[];
    for (final d in all.docs) {
      final rec = ArchetypesRecord.fromSnapshot(d);
      final aliases = rec.aliases.map((a) => a.toLowerCase()).toList();
      if (aliases.any((a) => a.contains(q))) {
        matches.add(rec);
        if (matches.length >= limit) break;
      }
    }
    return matches;
  }

  /// Returns the archetype doc for [name] if it already exists; otherwise
  /// creates one and returns it. Safe to call concurrently — the deterministic
  /// slug id prevents duplicates (later writes merge).
  Future<ArchetypesRecord> findOrCreate(
    String name, {
    String? format,
    String? avatarUrl,
    String? avatarCardName,
  }) async {
    final slug = slugify(name);
    if (slug.isEmpty) {
      throw ArgumentError('Archetype name must contain alphanumeric chars.');
    }

    final ref = _firestore.collection('archetypes').doc(slug);
    final snap = await ref.get();

    if (snap.exists) {
      // Opportunistically fill missing avatar fields.
      final rec = ArchetypesRecord.fromSnapshot(snap);
      final updates = <String, dynamic>{};
      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          (!rec.hasAvatarUrl() || rec.avatarUrl.isEmpty)) {
        updates['avatarUrl'] = avatarUrl;
      }
      if (avatarCardName != null &&
          avatarCardName.isNotEmpty &&
          (!rec.hasAvatarCardName() || rec.avatarCardName.isEmpty)) {
        updates['avatarCardName'] = avatarCardName;
      }
      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await ref.update(updates);
      }
      return rec;
    }

    final now = DateTime.now();
    final data = createArchetypesRecordData(
      name: name.trim(),
      nameLower: normalize(name),
      avatarUrl: avatarUrl,
      avatarCardName: avatarCardName,
      format: format,
      createdBy: currentUserReference?.id ?? '',
      createdAt: now,
      updatedAt: now,
      gameCount: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      archetypeId: slug,
    );
    // Aliases are stored separately since createArchetypesRecordData doesn't
    // expose them — we add the normalized name as the initial alias.
    data['aliases'] = [normalize(name)];
    await ref.set(data);

    return ArchetypesRecord.fromSnapshot(await ref.get());
  }

  /// Add a new alias to an existing archetype (idempotent).
  Future<void> addAlias(DocumentReference archetypeRef, String alias) async {
    final a = normalize(alias);
    if (a.isEmpty) return;
    await archetypeRef.update({
      'aliases': FieldValue.arrayUnion([a]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Assigns an archetype to a Spicerack decklist. Updates the global pivot
  /// (`spicerackDecks/{decklistId}`) and returns the archetype record.
  /// A Cloud Function is responsible for propagating the change to every
  /// `decks` doc with the same `spicerackDecklistId`, but we also patch the
  /// caller's local deck here for an immediate UI update.
  Future<ArchetypesRecord> assignToSpicerackDeck({
    required int decklistId,
    required String archetypeName,
    String? avatarUrl,
    String? avatarCardName,
    String? moxfieldUrl,
    DocumentReference? localDeckRef,
  }) async {
    final archetype = await findOrCreate(
      archetypeName,
      avatarUrl: avatarUrl,
      avatarCardName: avatarCardName,
    );

    // Pick the avatar to propagate: caller override wins, else archetype's.
    final effectiveAvatarUrl = (avatarUrl != null && avatarUrl.isNotEmpty)
        ? avatarUrl
        : (archetype.hasAvatarUrl() && archetype.avatarUrl.isNotEmpty
            ? archetype.avatarUrl
            : null);
    final effectiveAvatarCardName =
        (avatarCardName != null && avatarCardName.isNotEmpty)
            ? avatarCardName
            : (archetype.hasAvatarCardName() &&
                    archetype.avatarCardName.isNotEmpty
                ? archetype.avatarCardName
                : null);

    // Upsert the pivot.
    final pivotRef = SpicerackDecksRecord.docRef(decklistId);
    await pivotRef.set(
      createSpicerackDecksRecordData(
        decklistId: decklistId,
        archetypeRef: archetype.reference,
        archetypeName: archetype.name,
        avatarUrl: effectiveAvatarUrl,
        avatarCardName: effectiveAvatarCardName,
        moxfieldUrl: moxfieldUrl,
        lastEditedBy: currentUserReference?.id ?? '',
        lastEditedAt: DateTime.now(),
      ),
      SetOptions(merge: true),
    );

    // Patch the caller's local deck immediately (Cloud Function handles others).
    if (localDeckRef != null) {
      final patch = <String, dynamic>{
        'archetypeRef': archetype.reference,
        'avatarName': archetype.name,
        if (effectiveAvatarUrl != null) 'avatarUrl': effectiveAvatarUrl,
        if (effectiveAvatarCardName != null)
          'avatarCardName': effectiveAvatarCardName,
        if (moxfieldUrl != null && moxfieldUrl.isNotEmpty)
          'moxfieldUrl': moxfieldUrl,
      };
      await localDeckRef.update(patch);
    }

    return archetype;
  }

  /// Top archetypes by gameCount, for the bottom-sheet "popular" chips.
  Future<List<ArchetypesRecord>> topArchetypes({int limit = 20}) async {
    final snap = await _firestore
        .collection('archetypes')
        .orderBy('gameCount', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => ArchetypesRecord.fromSnapshot(d)).toList();
  }
}
