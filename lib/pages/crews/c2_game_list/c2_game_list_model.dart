import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_checkbox_group.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'c2_game_list_widget.dart' show C2GameListWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class C2GameListModel extends FlutterFlowModel<C2GameListWidget> {
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
  // Stores action output result for [Firestore Query - Query a collection] action in C2_GameList widget.
  DecksRecord? deck;
  // Stores action output result for [Backend Call - Read Document] action in C2_GameList widget.
  CrewmatesRecord? crewmateOwner;
  // State field(s) for CheckboxGroup widget.
  List<String>? checkboxGroupValues;
  FormFieldController<List<String>>? checkboxGroupValueController;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
