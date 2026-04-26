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

  // "moxfieldUrl" field.
  String? _moxfieldUrl;
  String get moxfieldUrl => _moxfieldUrl ?? '';
  bool hasMoxfieldUrl() => _moxfieldUrl != null;

  // "isTemplate" field. true = canonical personal deck, false/absent = tournament snapshot.
  bool? _isTemplate;
  bool get isTemplate => _isTemplate ?? false;
  bool hasIsTemplate() => _isTemplate != null;

  // "templateRef" field. Points snapshots to their canonical template deck.
  DocumentReference? _templateRef;
  DocumentReference? get templateRef => _templateRef;
  bool hasTemplateRef() => _templateRef != null;

  // "archetypeRef" field.
  DocumentReference? _archetypeRef;
  DocumentReference? get archetypeRef => _archetypeRef;
  bool hasArchetypeRef() => _archetypeRef != null;

  // "spicerackDecklistId" field. Stable id shared across crews for the same import.
  int? _spicerackDecklistId;
  int get spicerackDecklistId => _spicerackDecklistId ?? 0;
  bool hasSpicerackDecklistId() => _spicerackDecklistId != null;

  // "tournamentId" field. Set on tournament-snapshot decks; empty on templates.
  String? _tournamentId;
  String get tournamentId => _tournamentId ?? '';
  bool hasTournamentId() => _tournamentId != null;

  // "notes" field.
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null;

  // "avatarCardName" field. Scryfall card name that produced avatarUrl.
  String? _avatarCardName;
  String get avatarCardName => _avatarCardName ?? '';
  bool hasAvatarCardName() => _avatarCardName != null;

  // "gameCount" field. Denormalized by Cloud Function — meaningful on templates.
  int? _gameCount;
  int get gameCount => _gameCount ?? 0;
  bool hasGameCount() => _gameCount != null;

  // "wins" field.
  int? _wins;
  int get wins => _wins ?? 0;
  bool hasWins() => _wins != null;

  // "losses" field.
  int? _losses;
  int get losses => _losses ?? 0;
  bool hasLosses() => _losses != null;

  // "draws" field.
  int? _draws;
  int get draws => _draws ?? 0;
  bool hasDraws() => _draws != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _colors = getDataList(snapshotData['colors']);
    _crewId = snapshotData['crewId'] as String?;
    _avatarName = snapshotData['avatarName'] as String?;
    _avatarUrl = snapshotData['avatarUrl'] as String?;
    _crewmateId = snapshotData['crewmateId'] as String?;
    _crewmateRef = snapshotData['crewmateRef'] as DocumentReference?;
    _deckId = snapshotData['deckId'] as String?;
    _moxfieldUrl = snapshotData['moxfieldUrl'] as String?;
    _isTemplate = snapshotData['isTemplate'] as bool?;
    _templateRef = snapshotData['templateRef'] as DocumentReference?;
    _archetypeRef = snapshotData['archetypeRef'] as DocumentReference?;
    _spicerackDecklistId = castToType<int>(snapshotData['spicerackDecklistId']);
    _tournamentId = snapshotData['tournamentId'] as String?;
    _notes = snapshotData['notes'] as String?;
    _avatarCardName = snapshotData['avatarCardName'] as String?;
    _gameCount = castToType<int>(snapshotData['gameCount']);
    _wins = castToType<int>(snapshotData['wins']);
    _losses = castToType<int>(snapshotData['losses']);
    _draws = castToType<int>(snapshotData['draws']);
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
  String? moxfieldUrl,
  bool? isTemplate,
  DocumentReference? templateRef,
  DocumentReference? archetypeRef,
  int? spicerackDecklistId,
  String? tournamentId,
  String? notes,
  String? avatarCardName,
  int? gameCount,
  int? wins,
  int? losses,
  int? draws,
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
      'moxfieldUrl': moxfieldUrl,
      'isTemplate': isTemplate,
      'templateRef': templateRef,
      'archetypeRef': archetypeRef,
      'spicerackDecklistId': spicerackDecklistId,
      'tournamentId': tournamentId,
      'notes': notes,
      'avatarCardName': avatarCardName,
      'gameCount': gameCount,
      'wins': wins,
      'losses': losses,
      'draws': draws,
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
        e1?.deckId == e2?.deckId &&
        e1?.moxfieldUrl == e2?.moxfieldUrl &&
        e1?.isTemplate == e2?.isTemplate &&
        e1?.templateRef == e2?.templateRef &&
        e1?.archetypeRef == e2?.archetypeRef &&
        e1?.spicerackDecklistId == e2?.spicerackDecklistId &&
        e1?.notes == e2?.notes &&
        e1?.avatarCardName == e2?.avatarCardName &&
        e1?.gameCount == e2?.gameCount &&
        e1?.wins == e2?.wins &&
        e1?.losses == e2?.losses &&
        e1?.draws == e2?.draws;
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
        e?.deckId,
        e?.moxfieldUrl,
        e?.isTemplate,
        e?.templateRef,
        e?.archetypeRef,
        e?.spicerackDecklistId,
        e?.notes,
        e?.avatarCardName,
        e?.gameCount,
        e?.wins,
        e?.losses,
        e?.draws,
      ]);

  @override
  bool isValidKey(Object? o) => o is DecksRecord;
}
