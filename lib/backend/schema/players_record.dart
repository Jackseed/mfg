import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PlayersRecord extends FirestoreRecord {
  PlayersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  bool hasScore() => _score != null;

  // "deckName" field.
  String? _deckName;
  String get deckName => _deckName ?? '';
  bool hasDeckName() => _deckName != null;

  // "deckRef" field.
  DocumentReference? _deckRef;
  DocumentReference? get deckRef => _deckRef;
  bool hasDeckRef() => _deckRef != null;

  // "deckId" field.
  String? _deckId;
  String get deckId => _deckId ?? '';
  bool hasDeckId() => _deckId != null;

  // "crewmateId" field.
  String? _crewmateId;
  String get crewmateId => _crewmateId ?? '';
  bool hasCrewmateId() => _crewmateId != null;

  // "crewId" field.
  String? _crewId;
  String get crewId => _crewId ?? '';
  bool hasCrewId() => _crewId != null;

  // "crewmateRef" field.
  DocumentReference? _crewmateRef;
  DocumentReference? get crewmateRef => _crewmateRef;
  bool hasCrewmateRef() => _crewmateRef != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _score = castToType<int>(snapshotData['score']);
    _deckName = snapshotData['deckName'] as String?;
    _deckRef = snapshotData['deckRef'] as DocumentReference?;
    _deckId = snapshotData['deckId'] as String?;
    _crewmateId = snapshotData['crewmateId'] as String?;
    _crewId = snapshotData['crewId'] as String?;
    _crewmateRef = snapshotData['crewmateRef'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('players')
          : FirebaseFirestore.instance.collectionGroup('players');

  static DocumentReference createDoc(DocumentReference parent) =>
      parent.collection('players').doc();

  static Stream<PlayersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PlayersRecord.fromSnapshot(s));

  static Future<PlayersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PlayersRecord.fromSnapshot(s));

  static PlayersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PlayersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PlayersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PlayersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PlayersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PlayersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPlayersRecordData({
  int? score,
  String? deckName,
  DocumentReference? deckRef,
  String? deckId,
  String? crewmateId,
  String? crewId,
  DocumentReference? crewmateRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'score': score,
      'deckName': deckName,
      'deckRef': deckRef,
      'deckId': deckId,
      'crewmateId': crewmateId,
      'crewId': crewId,
      'crewmateRef': crewmateRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class PlayersRecordDocumentEquality implements Equality<PlayersRecord> {
  const PlayersRecordDocumentEquality();

  @override
  bool equals(PlayersRecord? e1, PlayersRecord? e2) {
    return e1?.score == e2?.score &&
        e1?.deckName == e2?.deckName &&
        e1?.deckRef == e2?.deckRef &&
        e1?.deckId == e2?.deckId &&
        e1?.crewmateId == e2?.crewmateId &&
        e1?.crewId == e2?.crewId &&
        e1?.crewmateRef == e2?.crewmateRef;
  }

  @override
  int hash(PlayersRecord? e) => const ListEquality().hash([
        e?.score,
        e?.deckName,
        e?.deckRef,
        e?.deckId,
        e?.crewmateId,
        e?.crewId,
        e?.crewmateRef
      ]);

  @override
  bool isValidKey(Object? o) => o is PlayersRecord;
}
