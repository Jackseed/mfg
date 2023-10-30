import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/page_component/deck_form/deck_form_widget.dart';
import 'deck_select_widget.dart' show DeckSelectWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DeckSelectModel extends FlutterFlowModel<DeckSelectWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Deck_select widget.
  String? deckSelectValue;
  FormFieldController<String>? deckSelectValueController;
  List<DecksRecord>? deckSelectPreviousSnapshot;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {}

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
