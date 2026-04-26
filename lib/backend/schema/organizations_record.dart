import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrganizationsRecord extends FirestoreRecord {
  OrganizationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "kind" field. 'lgs' | 'league' | 'spicerack_store' | 'online' | 'other'
  String? _kind;
  String get kind => _kind ?? '';
  bool hasKind() => _kind != null;

  // "spicerackStoreId" field.
  String? _spicerackStoreId;
  String get spicerackStoreId => _spicerackStoreId ?? '';
  bool hasSpicerackStoreId() => _spicerackStoreId != null;

  // "allowsManualGames" field.
  bool? _allowsManualGames;
  bool get allowsManualGames => _allowsManualGames ?? false;
  bool hasAllowsManualGames() => _allowsManualGames != null;

  // "createdBy" field.
  String? _createdBy;
  String get createdBy => _createdBy ?? '';
  bool hasCreatedBy() => _createdBy != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "memberCount" field.
  int? _memberCount;
  int get memberCount => _memberCount ?? 0;
  bool hasMemberCount() => _memberCount != null;

  // "organizationId" field.
  String? _organizationId;
  String get organizationId => _organizationId ?? '';
  bool hasOrganizationId() => _organizationId != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _kind = snapshotData['kind'] as String?;
    _spicerackStoreId = snapshotData['spicerackStoreId'] as String?;
    _allowsManualGames = snapshotData['allowsManualGames'] as bool?;
    _createdBy = snapshotData['createdBy'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _memberCount = castToType<int>(snapshotData['memberCount']);
    _organizationId = snapshotData['organizationId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('organizations');

  static Stream<OrganizationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OrganizationsRecord.fromSnapshot(s));

  static Future<OrganizationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OrganizationsRecord.fromSnapshot(s));

  static OrganizationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      OrganizationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OrganizationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OrganizationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OrganizationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OrganizationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOrganizationsRecordData({
  String? name,
  String? kind,
  String? spicerackStoreId,
  bool? allowsManualGames,
  String? createdBy,
  DateTime? createdAt,
  int? memberCount,
  String? organizationId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'kind': kind,
      'spicerackStoreId': spicerackStoreId,
      'allowsManualGames': allowsManualGames,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'memberCount': memberCount,
      'organizationId': organizationId,
    }.withoutNulls,
  );

  return firestoreData;
}

class OrganizationsRecordDocumentEquality
    implements Equality<OrganizationsRecord> {
  const OrganizationsRecordDocumentEquality();

  @override
  bool equals(OrganizationsRecord? e1, OrganizationsRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.kind == e2?.kind &&
        e1?.spicerackStoreId == e2?.spicerackStoreId &&
        e1?.allowsManualGames == e2?.allowsManualGames &&
        e1?.createdBy == e2?.createdBy &&
        e1?.createdAt == e2?.createdAt &&
        e1?.memberCount == e2?.memberCount &&
        e1?.organizationId == e2?.organizationId;
  }

  @override
  int hash(OrganizationsRecord? e) => const ListEquality().hash([
        e?.name,
        e?.kind,
        e?.spicerackStoreId,
        e?.allowsManualGames,
        e?.createdBy,
        e?.createdAt,
        e?.memberCount,
        e?.organizationId,
      ]);

  @override
  bool isValidKey(Object? o) => o is OrganizationsRecord;
}
