import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrganizationMembersRecord extends FirestoreRecord {
  OrganizationMembersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "crewmateRef" field.
  DocumentReference? _crewmateRef;
  DocumentReference? get crewmateRef => _crewmateRef;
  bool hasCrewmateRef() => _crewmateRef != null;

  // "joinedAt" field.
  DateTime? _joinedAt;
  DateTime? get joinedAt => _joinedAt;
  bool hasJoinedAt() => _joinedAt != null;

  // "role" field. 'member' | 'admin'
  String? _role;
  String get role => _role ?? 'member';
  bool hasRole() => _role != null;

  void _initializeFields() {
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _uid = snapshotData['uid'] as String?;
    _crewmateRef = snapshotData['crewmateRef'] as DocumentReference?;
    _joinedAt = snapshotData['joinedAt'] as DateTime?;
    _role = snapshotData['role'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('members')
          : FirebaseFirestore.instance.collectionGroup('members');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      id != null
          ? parent.collection('members').doc(id)
          : parent.collection('members').doc();

  static Stream<OrganizationMembersRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => OrganizationMembersRecord.fromSnapshot(s));

  static Future<OrganizationMembersRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => OrganizationMembersRecord.fromSnapshot(s));

  static OrganizationMembersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      OrganizationMembersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OrganizationMembersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OrganizationMembersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OrganizationMembersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OrganizationMembersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOrganizationMembersRecordData({
  DocumentReference? userRef,
  String? uid,
  DocumentReference? crewmateRef,
  DateTime? joinedAt,
  String? role,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userRef': userRef,
      'uid': uid,
      'crewmateRef': crewmateRef,
      'joinedAt': joinedAt,
      'role': role,
    }.withoutNulls,
  );

  return firestoreData;
}

class OrganizationMembersRecordDocumentEquality
    implements Equality<OrganizationMembersRecord> {
  const OrganizationMembersRecordDocumentEquality();

  @override
  bool equals(OrganizationMembersRecord? e1, OrganizationMembersRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.uid == e2?.uid &&
        e1?.crewmateRef == e2?.crewmateRef &&
        e1?.joinedAt == e2?.joinedAt &&
        e1?.role == e2?.role;
  }

  @override
  int hash(OrganizationMembersRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.uid,
        e?.crewmateRef,
        e?.joinedAt,
        e?.role,
      ]);

  @override
  bool isValidKey(Object? o) => o is OrganizationMembersRecord;
}
