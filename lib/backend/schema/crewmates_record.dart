import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CrewmatesRecord extends FirestoreRecord {
  CrewmatesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "userReference" field.
  DocumentReference? _userReference;
  DocumentReference? get userReference => _userReference;
  bool hasUserReference() => _userReference != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _name = snapshotData['name'] as String?;
    _userReference = snapshotData['userReference'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('crewmates')
          : FirebaseFirestore.instance.collectionGroup('crewmates');

  static DocumentReference createDoc(DocumentReference parent) =>
      parent.collection('crewmates').doc();

  static Stream<CrewmatesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CrewmatesRecord.fromSnapshot(s));

  static Future<CrewmatesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CrewmatesRecord.fromSnapshot(s));

  static CrewmatesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CrewmatesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CrewmatesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CrewmatesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CrewmatesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CrewmatesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCrewmatesRecordData({
  String? userId,
  String? name,
  DocumentReference? userReference,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'name': name,
      'userReference': userReference,
    }.withoutNulls,
  );

  return firestoreData;
}

class CrewmatesRecordDocumentEquality implements Equality<CrewmatesRecord> {
  const CrewmatesRecordDocumentEquality();

  @override
  bool equals(CrewmatesRecord? e1, CrewmatesRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.name == e2?.name &&
        e1?.userReference == e2?.userReference;
  }

  @override
  int hash(CrewmatesRecord? e) =>
      const ListEquality().hash([e?.userId, e?.name, e?.userReference]);

  @override
  bool isValidKey(Object? o) => o is CrewmatesRecord;
}
