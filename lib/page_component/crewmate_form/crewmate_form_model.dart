import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_snackbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import 'crewmate_form_widget.dart' show CrewmateFormWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CrewmateFormModel extends FlutterFlowModel<CrewmateFormWidget> {
  ///  Local state fields for this component.

  bool showSnackbar = false;

  String? snackbarMessage = '';

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // Model for DialogTitle component.
  late DialogTitleModel dialogTitleModel;
  // State field(s) for NameInput widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputController;
  String? Function(BuildContext, String?)? nameInputControllerValidator;
  String? _nameInputControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'i027ud27' /* Username is required */,
      );
    }

    if (val.length < 1) {
      return FFLocalizations.of(context).getText(
        'zws9wruf' /* Username is required */,
      );
    }

    return null;
  }

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<CrewmatesRecord>? crewmates;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  CrewmatesRecord? crewmateDocBeforeNameChange;
  // Model for CustomSnackbar component.
  late CustomSnackbarModel customSnackbarModel;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    dialogTitleModel = createModel(context, () => DialogTitleModel());
    nameInputControllerValidator = _nameInputControllerValidator;
    customSnackbarModel = createModel(context, () => CustomSnackbarModel());
  }

  void dispose() {
    dialogTitleModel.dispose();
    nameInputFocusNode?.dispose();
    nameInputController?.dispose();

    customSnackbarModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
