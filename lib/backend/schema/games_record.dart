import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GamesRecord extends FirestoreRecord {
  GamesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "docReference" field.
  DocumentReference? _docReference;
  DocumentReference? get docReference => _docReference;
  bool hasDocReference() => _docReference != null;

  // "crewId" field.
  String? _crewId;
  String get crewId => _crewId ?? '';
  bool hasCrewId() => _crewId != null;

  // "deckIds" field.
  List<String>? _deckIds;
  List<String> get deckIds => _deckIds ?? const [];
  bool hasDeckIds() => _deckIds != null;

  // "gameId" field.
  String? _gameId;
  String get gameId => _gameId ?? '';
  bool hasGameId() => _gameId != null;

  // "matchupId" field.
  String? _matchupId;
  String get matchupId => _matchupId ?? '';
  bool hasMatchupId() => _matchupId != null;

  // "matchupRef" field.
  DocumentReference? _matchupRef;
  DocumentReference? get matchupRef => _matchupRef;
  bool hasMatchupRef() => _matchupRef != null;

  // "organizationRef" field.
  DocumentReference? _organizationRef;
  DocumentReference? get organizationRef => _organizationRef;
  bool hasOrganizationRef() => _organizationRef != null;

  // "organizationId" field.
  String? _organizationId;
  String get organizationId => _organizationId ?? '';
  bool hasOrganizationId() => _organizationId != null;

  // "tournamentRef" field. Set when game is part of an imported tournament.
  DocumentReference? _tournamentRef;
  DocumentReference? get tournamentRef => _tournamentRef;
  bool hasTournamentRef() => _tournamentRef != null;

  // "tournamentId" field.
  String? _tournamentId;
  String get tournamentId => _tournamentId ?? '';
  bool hasTournamentId() => _tournamentId != null;

  void _initializeFields() {
    _date = snapshotData['date'] as DateTime?;
    _docReference = snapshotData['docReference'] as DocumentReference?;
    _crewId = snapshotData['crewId'] as String?;
    _deckIds = getDataList(snapshotData['deckIds']);
    _gameId = snapshotData['gameId'] as String?;
    _matchupId = snapshotData['matchupId'] as String?;
    _matchupRef = snapshotData['matchupRef'] as DocumentReference?;
    _organizationRef = snapshotData['organizationRef'] as DocumentReference?;
    _organizationId = snapshotData['organizationId'] as String?;
    _tournamentRef = snapshotData['tournamentRef'] as DocumentReference?;
    _tournamentId = snapshotData['tournamentId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('games');

  static Stream<GamesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GamesRecord.fromSnapshot(s));

  static Future<GamesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GamesRecord.fromSnapshot(s));

  static GamesRecord fromSnapshot(DocumentSnapshot snapshot) => GamesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GamesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GamesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GamesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GamesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGamesRecordData({
  DateTime? date,
  DocumentReference? docReference,
  String? crewId,
  String? gameId,
  String? matchupId,
  DocumentReference? matchupRef,
  DocumentReference? organizationRef,
  String? organizationId,
  DocumentReference? tournamentRef,
  String? tournamentId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'date': date,
      'docReference': docReference,
      'crewId': crewId,
      'gameId': gameId,
      'matchupId': matchupId,
      'matchupRef': matchupRef,
      'organizationRef': organizationRef,
      'organizationId': organizationId,
      'tournamentRef': tournamentRef,
      'tournamentId': tournamentId,
    }.withoutNulls,
  );

  return firestoreData;
}

class GamesRecordDocumentEquality implements Equality<GamesRecord> {
  const GamesRecordDocumentEquality();

  @override
  bool equals(GamesRecord? e1, GamesRecord? e2) {
    const listEquality = ListEquality();
    return e1?.date == e2?.date &&
        e1?.docReference == e2?.docReference &&
        e1?.crewId == e2?.crewId &&
        listEquality.equals(e1?.deckIds, e2?.deckIds) &&
        e1?.gameId == e2?.gameId &&
        e1?.matchupId == e2?.matchupId &&
        e1?.matchupRef == e2?.matchupRef &&
        e1?.organizationRef == e2?.organizationRef &&
        e1?.organizationId == e2?.organizationId &&
        e1?.tournamentRef == e2?.tournamentRef &&
        e1?.tournamentId == e2?.tournamentId;
  }

  @override
  int hash(GamesRecord? e) => const ListEquality().hash([
        e?.date,
        e?.docReference,
        e?.crewId,
        e?.deckIds,
        e?.gameId,
        e?.matchupId,
        e?.matchupRef,
        e?.organizationRef,
        e?.organizationId,
        e?.tournamentRef,
        e?.tournamentId,
      ]);

  @override
  bool isValidKey(Object? o) => o is GamesRecord;
}
