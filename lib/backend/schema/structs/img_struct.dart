// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ImgStruct extends FFFirebaseStruct {
  ImgStruct({
    String? downloadURL,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _downloadURL = downloadURL,
        super(firestoreUtilData);

  // "downloadURL" field.
  String? _downloadURL;
  String get downloadURL => _downloadURL ?? '';
  set downloadURL(String? val) => _downloadURL = val;
  bool hasDownloadURL() => _downloadURL != null;

  static ImgStruct fromMap(Map<String, dynamic> data) => ImgStruct(
        downloadURL: data['downloadURL'] as String?,
      );

  static ImgStruct? maybeFromMap(dynamic data) =>
      data is Map<String, dynamic> ? ImgStruct.fromMap(data) : null;

  Map<String, dynamic> toMap() => {
        'downloadURL': _downloadURL,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'downloadURL': serializeParam(
          _downloadURL,
          ParamType.String,
        ),
      }.withoutNulls;

  static ImgStruct fromSerializableMap(Map<String, dynamic> data) => ImgStruct(
        downloadURL: deserializeParam(
          data['downloadURL'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ImgStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ImgStruct && downloadURL == other.downloadURL;
  }

  @override
  int get hashCode => const ListEquality().hash([downloadURL]);
}

ImgStruct createImgStruct({
  String? downloadURL,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ImgStruct(
      downloadURL: downloadURL,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ImgStruct? updateImgStruct(
  ImgStruct? img, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    img
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addImgStructData(
  Map<String, dynamic> firestoreData,
  ImgStruct? img,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (img == null) {
    return;
  }
  if (img.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue && img.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final imgData = getImgFirestoreData(img, forFieldValue);
  final nestedData = imgData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = img.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getImgFirestoreData(
  ImgStruct? img, [
  bool forFieldValue = false,
]) {
  if (img == null) {
    return {};
  }
  final firestoreData = mapToFirestore(img.toMap());

  // Add any Firestore field values
  img.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getImgListFirestoreData(
  List<ImgStruct>? imgs,
) =>
    imgs?.map((e) => getImgFirestoreData(e, true)).toList() ?? [];
