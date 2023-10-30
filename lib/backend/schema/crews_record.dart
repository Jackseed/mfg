import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CrewsRecord extends FirestoreRecord {
  CrewsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "_ref" field.
  DocumentReference? _ref;
  DocumentReference? get ref => _ref;
  bool hasRef() => _ref != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _ref = snapshotData['_ref'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('crews');

  static Stream<CrewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CrewsRecord.fromSnapshot(s));

  static Future<CrewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CrewsRecord.fromSnapshot(s));

  static CrewsRecord fromSnapshot(DocumentSnapshot snapshot) => CrewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CrewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CrewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CrewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CrewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCrewsRecordData({
  String? name,
  DocumentReference? ref,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      '_ref': ref,
    }.withoutNulls,
  );

  return firestoreData;
}

class CrewsRecordDocumentEquality implements Equality<CrewsRecord> {
  const CrewsRecordDocumentEquality();

  @override
  bool equals(CrewsRecord? e1, CrewsRecord? e2) {
    return e1?.name == e2?.name && e1?.ref == e2?.ref;
  }

  @override
  int hash(CrewsRecord? e) => const ListEquality().hash([e?.name, e?.ref]);

  @override
  bool isValidKey(Object? o) => o is CrewsRecord;
}
