// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ScoreStruct extends FFFirebaseStruct {
  ScoreStruct({
    String? deckId,
    int? score,
    DocumentReference? deckRef,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _deckId = deckId,
        _score = score,
        _deckRef = deckRef,
        super(firestoreUtilData);

  // "deckId" field.
  String? _deckId;
  String get deckId => _deckId ?? '';
  set deckId(String? val) => _deckId = val;
  bool hasDeckId() => _deckId != null;

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  set score(int? val) => _score = val;
  void incrementScore(int amount) => _score = score + amount;
  bool hasScore() => _score != null;

  // "deckRef" field.
  DocumentReference? _deckRef;
  DocumentReference? get deckRef => _deckRef;
  set deckRef(DocumentReference? val) => _deckRef = val;
  bool hasDeckRef() => _deckRef != null;

  static ScoreStruct fromMap(Map<String, dynamic> data) => ScoreStruct(
        deckId: data['deckId'] as String?,
        score: castToType<int>(data['score']),
        deckRef: data['deckRef'] as DocumentReference?,
      );

  static ScoreStruct? maybeFromMap(dynamic data) =>
      data is Map<String, dynamic> ? ScoreStruct.fromMap(data) : null;

  Map<String, dynamic> toMap() => {
        'deckId': _deckId,
        'score': _score,
        'deckRef': _deckRef,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'deckId': serializeParam(
          _deckId,
          ParamType.String,
        ),
        'score': serializeParam(
          _score,
          ParamType.int,
        ),
        'deckRef': serializeParam(
          _deckRef,
          ParamType.DocumentReference,
        ),
      }.withoutNulls;

  static ScoreStruct fromSerializableMap(Map<String, dynamic> data) =>
      ScoreStruct(
        deckId: deserializeParam(
          data['deckId'],
          ParamType.String,
          false,
        ),
        score: deserializeParam(
          data['score'],
          ParamType.int,
          false,
        ),
        deckRef: deserializeParam(
          data['deckRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['decks'],
        ),
      );

  @override
  String toString() => 'ScoreStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ScoreStruct &&
        deckId == other.deckId &&
        score == other.score &&
        deckRef == other.deckRef;
  }

  @override
  int get hashCode => const ListEquality().hash([deckId, score, deckRef]);
}

ScoreStruct createScoreStruct({
  String? deckId,
  int? score,
  DocumentReference? deckRef,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ScoreStruct(
      deckId: deckId,
      score: score,
      deckRef: deckRef,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ScoreStruct? updateScoreStruct(
  ScoreStruct? scoreStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    scoreStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addScoreStructData(
  Map<String, dynamic> firestoreData,
  ScoreStruct? scoreStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (scoreStruct == null) {
    return;
  }
  if (scoreStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && scoreStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final scoreStructData = getScoreFirestoreData(scoreStruct, forFieldValue);
  final nestedData =
      scoreStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = scoreStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getScoreFirestoreData(
  ScoreStruct? scoreStruct, [
  bool forFieldValue = false,
]) {
  if (scoreStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(scoreStruct.toMap());

  // Add any Firestore field values
  scoreStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getScoreListFirestoreData(
  List<ScoreStruct>? scoreStructs,
) =>
    scoreStructs?.map((e) => getScoreFirestoreData(e, true)).toList() ?? [];
