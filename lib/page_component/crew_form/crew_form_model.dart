import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import 'crew_form_widget.dart' show CrewFormWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CrewFormModel extends FlutterFlowModel<CrewFormWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // Model for DialogTitle component.
  late DialogTitleModel dialogTitleModel;
  // State field(s) for CrewNameField widget.
  FocusNode? crewNameFieldFocusNode;
  TextEditingController? crewNameFieldController;
  String? Function(BuildContext, String?)? crewNameFieldControllerValidator;
  String? _crewNameFieldControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'r7masohh' /* Field is required */,
      );
    }

    if (val.length < 1) {
      return FFLocalizations.of(context).getText(
        '8vwdg36w' /* Crew name is between 1 to 20 c... */,
      );
    }
    if (val.length > 20) {
      return FFLocalizations.of(context).getText(
        'rmf270e0' /* Crew name is between 1 to 20 c... */,
      );
    }

    return null;
  }

  // State field(s) for UserNameField widget.
  FocusNode? userNameFieldFocusNode;
  TextEditingController? userNameFieldController;
  String? Function(BuildContext, String?)? userNameFieldControllerValidator;
  String? _userNameFieldControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'pugezzni' /* Field is required */,
      );
    }

    if (val.length < 1) {
      return FFLocalizations.of(context).getText(
        'waugnw6n' /* User name is between 1 to 20 c... */,
      );
    }
    if (val.length > 20) {
      return FFLocalizations.of(context).getText(
        'epmyfwo3' /* User name is between 1 to 20 c... */,
      );
    }

    return null;
  }

  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  CrewsRecord? crewDoc;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  CrewmatesRecord? crewmateDoc;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    dialogTitleModel = createModel(context, () => DialogTitleModel());
    crewNameFieldControllerValidator = _crewNameFieldControllerValidator;
    userNameFieldControllerValidator = _userNameFieldControllerValidator;
  }

  void dispose() {
    dialogTitleModel.dispose();
    crewNameFieldFocusNode?.dispose();
    crewNameFieldController?.dispose();

    userNameFieldFocusNode?.dispose();
    userNameFieldController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
