import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_snackbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/select_crewmate/select_crewmate_widget.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import 'join_crew_widget.dart' show JoinCrewWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class JoinCrewModel extends FlutterFlowModel<JoinCrewWidget> {
  ///  Local state fields for this component.

  bool showSnackbar = false;

  String? snackbarMessage = '';

  ///  State fields for stateful widgets in this component.

  // Model for DialogTitle component.
  late DialogTitleModel dialogTitleModel;
  // State field(s) for CodeInput widget.
  FocusNode? codeInputFocusNode;
  TextEditingController? codeInputController;
  String? Function(BuildContext, String?)? codeInputControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<CrewsRecord>? crewList;
  // Model for CustomSnackbar component.
  late CustomSnackbarModel customSnackbarModel;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    dialogTitleModel = createModel(context, () => DialogTitleModel());
    customSnackbarModel = createModel(context, () => CustomSnackbarModel());
  }

  void dispose() {
    dialogTitleModel.dispose();
    codeInputFocusNode?.dispose();
    codeInputController?.dispose();

    customSnackbarModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
