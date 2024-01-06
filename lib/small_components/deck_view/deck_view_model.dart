import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/page_component/deck_edit/deck_edit_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import 'deck_view_widget.dart' show DeckViewWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DeckViewModel extends FlutterFlowModel<DeckViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getDeckScore] action in DeckView widget.
  DeckScoreStruct? deckScore;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {}

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
