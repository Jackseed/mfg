import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ImagesRecord extends FirestoreRecord {
  ImagesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "image" field.
  List<ImgStruct>? _image;
  List<ImgStruct> get image => _image ?? const [];
  bool hasImage() => _image != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "colors" field.
  List<String>? _colors;
  List<String> get colors => _colors ?? const [];
  bool hasColors() => _colors != null;

  void _initializeFields() {
    _image = getStructList(
      snapshotData['image'],
      ImgStruct.fromMap,
    );
    _type = snapshotData['type'] as String?;
    _colors = getDataList(snapshotData['colors']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('images');

  static Stream<ImagesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ImagesRecord.fromSnapshot(s));

  static Future<ImagesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ImagesRecord.fromSnapshot(s));

  static ImagesRecord fromSnapshot(DocumentSnapshot snapshot) => ImagesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ImagesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ImagesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ImagesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ImagesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createImagesRecordData({
  String? type,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'type': type,
    }.withoutNulls,
  );

  return firestoreData;
}

class ImagesRecordDocumentEquality implements Equality<ImagesRecord> {
  const ImagesRecordDocumentEquality();

  @override
  bool equals(ImagesRecord? e1, ImagesRecord? e2) {
    const listEquality = ListEquality();
    return listEquality.equals(e1?.image, e2?.image) &&
        e1?.type == e2?.type &&
        listEquality.equals(e1?.colors, e2?.colors);
  }

  @override
  int hash(ImagesRecord? e) =>
      const ListEquality().hash([e?.image, e?.type, e?.colors]);

  @override
  bool isValidKey(Object? o) => o is ImagesRecord;
}
