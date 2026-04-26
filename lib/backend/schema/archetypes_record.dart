import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ArchetypesRecord extends FirestoreRecord {
  ArchetypesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "nameLower" field. Lowercase normalized name for case-insensitive search.
  String? _nameLower;
  String get nameLower => _nameLower ?? '';
  bool hasNameLower() => _nameLower != null;

  // "aliases" field. Extra lowercased labels the archetype is known by.
  List<String>? _aliases;
  List<String> get aliases => _aliases ?? const [];
  bool hasAliases() => _aliases != null;

  // "avatarUrl" field. Scryfall art_crop URL.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  bool hasAvatarUrl() => _avatarUrl != null;

  // "avatarCardName" field. Scryfall card name that produced avatarUrl.
  String? _avatarCardName;
  String get avatarCardName => _avatarCardName ?? '';
  bool hasAvatarCardName() => _avatarCardName != null;

  // "format" field. Nullable — some archetypes are cross-format.
  String? _format;
  String get format => _format ?? '';
  bool hasFormat() => _format != null;

  // "createdBy" field.
  String? _createdBy;
  String get createdBy => _createdBy ?? '';
  bool hasCreatedBy() => _createdBy != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "gameCount" field. Denormalized by Cloud Function.
  int? _gameCount;
  int get gameCount => _gameCount ?? 0;
  bool hasGameCount() => _gameCount != null;

  // "wins" field.
  int? _wins;
  int get wins => _wins ?? 0;
  bool hasWins() => _wins != null;

  // "losses" field.
  int? _losses;
  int get losses => _losses ?? 0;
  bool hasLosses() => _losses != null;

  // "draws" field.
  int? _draws;
  int get draws => _draws ?? 0;
  bool hasDraws() => _draws != null;

  // "archetypeId" field. Mirror of doc id for queries.
  String? _archetypeId;
  String get archetypeId => _archetypeId ?? '';
  bool hasArchetypeId() => _archetypeId != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _nameLower = snapshotData['nameLower'] as String?;
    _aliases = getDataList(snapshotData['aliases']);
    _avatarUrl = snapshotData['avatarUrl'] as String?;
    _avatarCardName = snapshotData['avatarCardName'] as String?;
    _format = snapshotData['format'] as String?;
    _createdBy = snapshotData['createdBy'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _gameCount = castToType<int>(snapshotData['gameCount']);
    _wins = castToType<int>(snapshotData['wins']);
    _losses = castToType<int>(snapshotData['losses']);
    _draws = castToType<int>(snapshotData['draws']);
    _archetypeId = snapshotData['archetypeId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('archetypes');

  static Stream<ArchetypesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ArchetypesRecord.fromSnapshot(s));

  static Future<ArchetypesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ArchetypesRecord.fromSnapshot(s));

  static ArchetypesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ArchetypesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ArchetypesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ArchetypesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ArchetypesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ArchetypesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createArchetypesRecordData({
  String? name,
  String? nameLower,
  String? avatarUrl,
  String? avatarCardName,
  String? format,
  String? createdBy,
  DateTime? createdAt,
  DateTime? updatedAt,
  int? gameCount,
  int? wins,
  int? losses,
  int? draws,
  String? archetypeId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'nameLower': nameLower,
      'avatarUrl': avatarUrl,
      'avatarCardName': avatarCardName,
      'format': format,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'gameCount': gameCount,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'archetypeId': archetypeId,
    }.withoutNulls,
  );

  return firestoreData;
}

class ArchetypesRecordDocumentEquality implements Equality<ArchetypesRecord> {
  const ArchetypesRecordDocumentEquality();

  @override
  bool equals(ArchetypesRecord? e1, ArchetypesRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.nameLower == e2?.nameLower &&
        listEquality.equals(e1?.aliases, e2?.aliases) &&
        e1?.avatarUrl == e2?.avatarUrl &&
        e1?.avatarCardName == e2?.avatarCardName &&
        e1?.format == e2?.format &&
        e1?.createdBy == e2?.createdBy &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.gameCount == e2?.gameCount &&
        e1?.wins == e2?.wins &&
        e1?.losses == e2?.losses &&
        e1?.draws == e2?.draws &&
        e1?.archetypeId == e2?.archetypeId;
  }

  @override
  int hash(ArchetypesRecord? e) => const ListEquality().hash([
        e?.name,
        e?.nameLower,
        e?.aliases,
        e?.avatarUrl,
        e?.avatarCardName,
        e?.format,
        e?.createdBy,
        e?.createdAt,
        e?.updatedAt,
        e?.gameCount,
        e?.wins,
        e?.losses,
        e?.draws,
        e?.archetypeId,
      ]);

  @override
  bool isValidKey(Object? o) => o is ArchetypesRecord;
}
