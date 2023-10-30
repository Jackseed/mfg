import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MatchupsRecord extends FirestoreRecord {
  MatchupsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "gameIds" field.
  List<String>? _gameIds;
  List<String> get gameIds => _gameIds ?? const [];
  bool hasGameIds() => _gameIds != null;

  // "deckIds" field.
  List<String>? _deckIds;
  List<String> get deckIds => _deckIds ?? const [];
  bool hasDeckIds() => _deckIds != null;

  // "scores" field.
  List<ScoreStruct>? _scores;
  List<ScoreStruct> get scores => _scores ?? const [];
  bool hasScores() => _scores != null;

  // "matchupId" field.
  String? _matchupId;
  String get matchupId => _matchupId ?? '';
  bool hasMatchupId() => _matchupId != null;

  // "crewId" field.
  String? _crewId;
  String get crewId => _crewId ?? '';
  bool hasCrewId() => _crewId != null;

  void _initializeFields() {
    _gameIds = getDataList(snapshotData['gameIds']);
    _deckIds = getDataList(snapshotData['deckIds']);
    _scores = getStructList(
      snapshotData['scores'],
      ScoreStruct.fromMap,
    );
    _matchupId = snapshotData['matchupId'] as String?;
    _crewId = snapshotData['crewId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('matchups');

  static Stream<MatchupsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MatchupsRecord.fromSnapshot(s));

  static Future<MatchupsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MatchupsRecord.fromSnapshot(s));

  static MatchupsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MatchupsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MatchupsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MatchupsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MatchupsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MatchupsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMatchupsRecordData({
  String? matchupId,
  String? crewId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'matchupId': matchupId,
      'crewId': crewId,
    }.withoutNulls,
  );

  return firestoreData;
}

class MatchupsRecordDocumentEquality implements Equality<MatchupsRecord> {
  const MatchupsRecordDocumentEquality();

  @override
  bool equals(MatchupsRecord? e1, MatchupsRecord? e2) {
    const listEquality = ListEquality();
    return listEquality.equals(e1?.gameIds, e2?.gameIds) &&
        listEquality.equals(e1?.deckIds, e2?.deckIds) &&
        listEquality.equals(e1?.scores, e2?.scores) &&
        e1?.matchupId == e2?.matchupId &&
        e1?.crewId == e2?.crewId;
  }

  @override
  int hash(MatchupsRecord? e) => const ListEquality()
      .hash([e?.gameIds, e?.deckIds, e?.scores, e?.matchupId, e?.crewId]);

  @override
  bool isValidKey(Object? o) => o is MatchupsRecord;
}
