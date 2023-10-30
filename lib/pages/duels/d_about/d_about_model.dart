import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'd_about_widget.dart' show DAboutWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DAboutModel extends FlutterFlowModel<DAboutWidget> {
  ///  Local state fields for this page.

  bool isDeckFilterOpen = true;

  List<String> filteredDeckList = [];
  void addToFilteredDeckList(String item) => filteredDeckList.add(item);
  void removeFromFilteredDeckList(String item) => filteredDeckList.remove(item);
  void removeAtIndexFromFilteredDeckList(int index) =>
      filteredDeckList.removeAt(index);
  void insertAtIndexInFilteredDeckList(int index, String item) =>
      filteredDeckList.insert(index, item);
  void updateFilteredDeckListAtIndex(int index, Function(String) updateFn) =>
      filteredDeckList[index] = updateFn(filteredDeckList[index]);

  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
