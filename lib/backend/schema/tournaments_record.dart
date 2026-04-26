import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TournamentsRecord extends FirestoreRecord {
  TournamentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "format" field.
  String? _format;
  String get format => _format ?? '';
  bool hasFormat() => _format != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "crewId" field.
  String? _crewId;
  String get crewId => _crewId ?? '';
  bool hasCrewId() => _crewId != null;

  // "spicerackEventId" field.
  int? _spicerackEventId;
  int get spicerackEventId => _spicerackEventId ?? 0;
  bool hasSpicerackEventId() => _spicerackEventId != null;

  // "tournamentId" field.
  String? _tournamentId;
  String get tournamentId => _tournamentId ?? '';
  bool hasTournamentId() => _tournamentId != null;

  // "organizationRef" field.
  DocumentReference? _organizationRef;
  DocumentReference? get organizationRef => _organizationRef;
  bool hasOrganizationRef() => _organizationRef != null;

  // "organizationId" field.
  String? _organizationId;
  String get organizationId => _organizationId ?? '';
  bool hasOrganizationId() => _organizationId != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _format = snapshotData['format'] as String?;
    _date = snapshotData['date'] as DateTime?;
    _crewId = snapshotData['crewId'] as String?;
    _spicerackEventId = castToType<int>(snapshotData['spicerackEventId']);
    _tournamentId = snapshotData['tournamentId'] as String?;
    _organizationRef = snapshotData['organizationRef'] as DocumentReference?;
    _organizationId = snapshotData['organizationId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tournaments');

  static Stream<TournamentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TournamentsRecord.fromSnapshot(s));

  static Future<TournamentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TournamentsRecord.fromSnapshot(s));

  static TournamentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TournamentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TournamentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TournamentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TournamentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TournamentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTournamentsRecordData({
  String? name,
  String? format,
  DateTime? date,
  String? crewId,
  int? spicerackEventId,
  String? tournamentId,
  DocumentReference? organizationRef,
  String? organizationId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'format': format,
      'date': date,
      'crewId': crewId,
      'spicerackEventId': spicerackEventId,
      'tournamentId': tournamentId,
      'organizationRef': organizationRef,
      'organizationId': organizationId,
    }.withoutNulls,
  );

  return firestoreData;
}

class TournamentsRecordDocumentEquality
    implements Equality<TournamentsRecord> {
  const TournamentsRecordDocumentEquality();

  @override
  bool equals(TournamentsRecord? e1, TournamentsRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.format == e2?.format &&
        e1?.date == e2?.date &&
        e1?.crewId == e2?.crewId &&
        e1?.spicerackEventId == e2?.spicerackEventId &&
        e1?.tournamentId == e2?.tournamentId &&
        e1?.organizationRef == e2?.organizationRef &&
        e1?.organizationId == e2?.organizationId;
  }

  @override
  int hash(TournamentsRecord? e) => const ListEquality().hash([
        e?.name,
        e?.format,
        e?.date,
        e?.crewId,
        e?.spicerackEventId,
        e?.tournamentId,
        e?.organizationRef,
        e?.organizationId,
      ]);

  @override
  bool isValidKey(Object? o) => o is TournamentsRecord;
}
