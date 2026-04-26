import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Global pivot that stores, for a Spicerack decklist id, the agreed-upon
/// archetype / avatar / moxfield attribution. Any local `decks` doc with the
/// same `spicerackDecklistId` inherits from here, which means a user in crew A
/// tagging a tournament deck propagates the attribution to crew B who later
/// imports the same tournament.
class SpicerackDecksRecord extends FirestoreRecord {
  SpicerackDecksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "decklistId" field. Spicerack decklist id (numeric).
  int? _decklistId;
  int get decklistId => _decklistId ?? 0;
  bool hasDecklistId() => _decklistId != null;

  // "archetypeRef" field.
  DocumentReference? _archetypeRef;
  DocumentReference? get archetypeRef => _archetypeRef;
  bool hasArchetypeRef() => _archetypeRef != null;

  // "archetypeName" field. Denormalized for fast reads.
  String? _archetypeName;
  String get archetypeName => _archetypeName ?? '';
  bool hasArchetypeName() => _archetypeName != null;

  // "avatarUrl" field. Denormalized Scryfall art_crop.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  bool hasAvatarUrl() => _avatarUrl != null;

  // "avatarCardName" field. Scryfall card name that produced avatarUrl.
  String? _avatarCardName;
  String get avatarCardName => _avatarCardName ?? '';
  bool hasAvatarCardName() => _avatarCardName != null;

  // "moxfieldPublicId" field.
  String? _moxfieldPublicId;
  String get moxfieldPublicId => _moxfieldPublicId ?? '';
  bool hasMoxfieldPublicId() => _moxfieldPublicId != null;

  // "moxfieldUrl" field.
  String? _moxfieldUrl;
  String get moxfieldUrl => _moxfieldUrl ?? '';
  bool hasMoxfieldUrl() => _moxfieldUrl != null;

  // "lastEditedBy" field.
  String? _lastEditedBy;
  String get lastEditedBy => _lastEditedBy ?? '';
  bool hasLastEditedBy() => _lastEditedBy != null;

  // "lastEditedAt" field.
  DateTime? _lastEditedAt;
  DateTime? get lastEditedAt => _lastEditedAt;
  bool hasLastEditedAt() => _lastEditedAt != null;

  void _initializeFields() {
    _decklistId = castToType<int>(snapshotData['decklistId']);
    _archetypeRef = snapshotData['archetypeRef'] as DocumentReference?;
    _archetypeName = snapshotData['archetypeName'] as String?;
    _avatarUrl = snapshotData['avatarUrl'] as String?;
    _avatarCardName = snapshotData['avatarCardName'] as String?;
    _moxfieldPublicId = snapshotData['moxfieldPublicId'] as String?;
    _moxfieldUrl = snapshotData['moxfieldUrl'] as String?;
    _lastEditedBy = snapshotData['lastEditedBy'] as String?;
    _lastEditedAt = snapshotData['lastEditedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('spicerackDecks');

  /// Returns the document reference for a given Spicerack decklist id.
  static DocumentReference docRef(int decklistId) =>
      collection.doc(decklistId.toString());

  static Stream<SpicerackDecksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SpicerackDecksRecord.fromSnapshot(s));

  static Future<SpicerackDecksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SpicerackDecksRecord.fromSnapshot(s));

  static SpicerackDecksRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SpicerackDecksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SpicerackDecksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SpicerackDecksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SpicerackDecksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SpicerackDecksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSpicerackDecksRecordData({
  int? decklistId,
  DocumentReference? archetypeRef,
  String? archetypeName,
  String? avatarUrl,
  String? avatarCardName,
  String? moxfieldPublicId,
  String? moxfieldUrl,
  String? lastEditedBy,
  DateTime? lastEditedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'decklistId': decklistId,
      'archetypeRef': archetypeRef,
      'archetypeName': archetypeName,
      'avatarUrl': avatarUrl,
      'avatarCardName': avatarCardName,
      'moxfieldPublicId': moxfieldPublicId,
      'moxfieldUrl': moxfieldUrl,
      'lastEditedBy': lastEditedBy,
      'lastEditedAt': lastEditedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class SpicerackDecksRecordDocumentEquality
    implements Equality<SpicerackDecksRecord> {
  const SpicerackDecksRecordDocumentEquality();

  @override
  bool equals(SpicerackDecksRecord? e1, SpicerackDecksRecord? e2) {
    return e1?.decklistId == e2?.decklistId &&
        e1?.archetypeRef == e2?.archetypeRef &&
        e1?.archetypeName == e2?.archetypeName &&
        e1?.avatarUrl == e2?.avatarUrl &&
        e1?.avatarCardName == e2?.avatarCardName &&
        e1?.moxfieldPublicId == e2?.moxfieldPublicId &&
        e1?.moxfieldUrl == e2?.moxfieldUrl &&
        e1?.lastEditedBy == e2?.lastEditedBy &&
        e1?.lastEditedAt == e2?.lastEditedAt;
  }

  @override
  int hash(SpicerackDecksRecord? e) => const ListEquality().hash([
        e?.decklistId,
        e?.archetypeRef,
        e?.archetypeName,
        e?.avatarUrl,
        e?.avatarCardName,
        e?.moxfieldPublicId,
        e?.moxfieldUrl,
        e?.lastEditedBy,
        e?.lastEditedAt,
      ]);

  @override
  bool isValidKey(Object? o) => o is SpicerackDecksRecord;
}
