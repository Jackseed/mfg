import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _currentGameDeckRef2 = prefs.getString('ff_currentGameDeckRef2')?.ref ??
          _currentGameDeckRef2;
    });
    _safeInit(() {
      _currentGameDeckRef1 = prefs.getString('ff_currentGameDeckRef1')?.ref ??
          _currentGameDeckRef1;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _deck1Selected = false;
  bool get deck1Selected => _deck1Selected;
  set deck1Selected(bool _value) {
    _deck1Selected = _value;
  }

  bool _deck2Selected = false;
  bool get deck2Selected => _deck2Selected;
  set deck2Selected(bool _value) {
    _deck2Selected = _value;
  }

  DocumentReference? _currentGameDeckRef2 =
      FirebaseFirestore.instance.doc('/decks/0YMtzxv9Gae9WsgfPcjG');
  DocumentReference? get currentGameDeckRef2 => _currentGameDeckRef2;
  set currentGameDeckRef2(DocumentReference? _value) {
    _currentGameDeckRef2 = _value;
    _value != null
        ? prefs.setString('ff_currentGameDeckRef2', _value.path)
        : prefs.remove('ff_currentGameDeckRef2');
  }

  DocumentReference? _currentGameDeckRef1 =
      FirebaseFirestore.instance.doc('/decks/0YMtzxv9Gae9WsgfPcjG');
  DocumentReference? get currentGameDeckRef1 => _currentGameDeckRef1;
  set currentGameDeckRef1(DocumentReference? _value) {
    _currentGameDeckRef1 = _value;
    _value != null
        ? prefs.setString('ff_currentGameDeckRef1', _value.path)
        : prefs.remove('ff_currentGameDeckRef1');
  }
}

LatLng? _latLngFromString(String? val) {
  if (val == null) {
    return null;
  }
  final split = val.split(',');
  final lat = double.parse(split.first);
  final lng = double.parse(split.last);
  return LatLng(lat, lng);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
