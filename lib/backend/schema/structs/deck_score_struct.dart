// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DeckScoreStruct extends FFFirebaseStruct {
  DeckScoreStruct({
    int? wins,
    double? winrate,
    int? losses,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _wins = wins,
        _winrate = winrate,
        _losses = losses,
        super(firestoreUtilData);

  // "wins" field.
  int? _wins;
  int get wins => _wins ?? 0;
  set wins(int? val) => _wins = val;
  void incrementWins(int amount) => _wins = wins + amount;
  bool hasWins() => _wins != null;

  // "winrate" field.
  double? _winrate;
  double get winrate => _winrate ?? 0.0;
  set winrate(double? val) => _winrate = val;
  void incrementWinrate(double amount) => _winrate = winrate + amount;
  bool hasWinrate() => _winrate != null;

  // "losses" field.
  int? _losses;
  int get losses => _losses ?? 0;
  set losses(int? val) => _losses = val;
  void incrementLosses(int amount) => _losses = losses + amount;
  bool hasLosses() => _losses != null;

  static DeckScoreStruct fromMap(Map<String, dynamic> data) => DeckScoreStruct(
        wins: castToType<int>(data['wins']),
        winrate: castToType<double>(data['winrate']),
        losses: castToType<int>(data['losses']),
      );

  static DeckScoreStruct? maybeFromMap(dynamic data) => data is Map
      ? DeckScoreStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'wins': _wins,
        'winrate': _winrate,
        'losses': _losses,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'wins': serializeParam(
          _wins,
          ParamType.int,
        ),
        'winrate': serializeParam(
          _winrate,
          ParamType.double,
        ),
        'losses': serializeParam(
          _losses,
          ParamType.int,
        ),
      }.withoutNulls;

  static DeckScoreStruct fromSerializableMap(Map<String, dynamic> data) =>
      DeckScoreStruct(
        wins: deserializeParam(
          data['wins'],
          ParamType.int,
          false,
        ),
        winrate: deserializeParam(
          data['winrate'],
          ParamType.double,
          false,
        ),
        losses: deserializeParam(
          data['losses'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'DeckScoreStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DeckScoreStruct &&
        wins == other.wins &&
        winrate == other.winrate &&
        losses == other.losses;
  }

  @override
  int get hashCode => const ListEquality().hash([wins, winrate, losses]);
}

DeckScoreStruct createDeckScoreStruct({
  int? wins,
  double? winrate,
  int? losses,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    DeckScoreStruct(
      wins: wins,
      winrate: winrate,
      losses: losses,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

DeckScoreStruct? updateDeckScoreStruct(
  DeckScoreStruct? deckScore, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    deckScore
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addDeckScoreStructData(
  Map<String, dynamic> firestoreData,
  DeckScoreStruct? deckScore,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (deckScore == null) {
    return;
  }
  if (deckScore.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && deckScore.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final deckScoreData = getDeckScoreFirestoreData(deckScore, forFieldValue);
  final nestedData = deckScoreData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = deckScore.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getDeckScoreFirestoreData(
  DeckScoreStruct? deckScore, [
  bool forFieldValue = false,
]) {
  if (deckScore == null) {
    return {};
  }
  final firestoreData = mapToFirestore(deckScore.toMap());

  // Add any Firestore field values
  deckScore.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getDeckScoreListFirestoreData(
  List<DeckScoreStruct>? deckScores,
) =>
    deckScores?.map((e) => getDeckScoreFirestoreData(e, true)).toList() ?? [];
