import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/player_form/player_form_widget.dart';
import 'b_game_form_widget.dart' show BGameFormWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BGameFormModel extends FlutterFlowModel<BGameFormWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for PlayerForm1.
  late PlayerFormModel playerForm1Model;
  // Model for PlayerForm2.
  late PlayerFormModel playerForm2Model;
  // Stores action output result for [Firestore Query - Query a collection] action in StartButton widget.
  List<DecksRecord>? crewDecks;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    playerForm1Model = createModel(context, () => PlayerFormModel());
    playerForm2Model = createModel(context, () => PlayerFormModel());
  }

  void dispose() {
    unfocusNode.dispose();
    playerForm1Model.dispose();
    playerForm2Model.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
