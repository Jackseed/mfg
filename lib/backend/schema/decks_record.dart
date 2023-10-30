import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DecksRecord extends FirestoreRecord {
  DecksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "colors" field.
  List<String>? _colors;
  List<String> get colors => _colors ?? const [];
  bool hasColors() => _colors != null;

  // "crewId" field.
  String? _crewId;
  String get crewId => _crewId ?? '';
  bool hasCrewId() => _crewId != null;

  // "avatarName" field.
  String? _avatarName;
  String get avatarName => _avatarName ?? '';
  bool hasAvatarName() => _avatarName != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  bool hasAvatarUrl() => _avatarUrl != null;

  // "crewmateId" field.
  String? _crewmateId;
  String get crewmateId => _crewmateId ?? '';
  bool hasCrewmateId() => _crewmateId != null;

  // "crewmateRef" field.
  DocumentReference? _crewmateRef;
  DocumentReference? get crewmateRef => _crewmateRef;
  bool hasCrewmateRef() => _crewmateRef != null;

  // "deckId" field.
  String? _deckId;
  String get deckId => _deckId ?? '';
  bool hasDeckId() => _deckId != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _colors = getDataList(snapshotData['colors']);
    _crewId = snapshotData['crewId'] as String?;
    _avatarName = snapshotData['avatarName'] as String?;
    _avatarUrl = snapshotData['avatarUrl'] as String?;
    _crewmateId = snapshotData['crewmateId'] as String?;
    _crewmateRef = snapshotData['crewmateRef'] as DocumentReference?;
    _deckId = snapshotData['deckId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('decks');

  static Stream<DecksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DecksRecord.fromSnapshot(s));

  static Future<DecksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DecksRecord.fromSnapshot(s));

  static DecksRecord fromSnapshot(DocumentSnapshot snapshot) => DecksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DecksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DecksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DecksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DecksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDecksRecordData({
  String? name,
  String? crewId,
  String? avatarName,
  String? avatarUrl,
  String? crewmateId,
  DocumentReference? crewmateRef,
  String? deckId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'crewId': crewId,
      'avatarName': avatarName,
      'avatarUrl': avatarUrl,
      'crewmateId': crewmateId,
      'crewmateRef': crewmateRef,
      'deckId': deckId,
    }.withoutNulls,
  );

  return firestoreData;
}

class DecksRecordDocumentEquality implements Equality<DecksRecord> {
  const DecksRecordDocumentEquality();

  @override
  bool equals(DecksRecord? e1, DecksRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        listEquality.equals(e1?.colors, e2?.colors) &&
        e1?.crewId == e2?.crewId &&
        e1?.avatarName == e2?.avatarName &&
        e1?.avatarUrl == e2?.avatarUrl &&
        e1?.crewmateId == e2?.crewmateId &&
        e1?.crewmateRef == e2?.crewmateRef &&
        e1?.deckId == e2?.deckId;
  }

  @override
  int hash(DecksRecord? e) => const ListEquality().hash([
        e?.name,
        e?.colors,
        e?.crewId,
        e?.avatarName,
        e?.avatarUrl,
        e?.crewmateId,
        e?.crewmateRef,
        e?.deckId
      ]);

  @override
  bool isValidKey(Object? o) => o is DecksRecord;
}
