import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/page_component/crewmate_form/crewmate_form_widget.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'select_crewmate_widget.dart' show SelectCrewmateWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectCrewmateModel extends FlutterFlowModel<SelectCrewmateWidget> {
  ///  Local state fields for this component.

  int loopCount = 0;

  ///  State fields for stateful widgets in this component.

  // Model for DialogTitle component.
  late DialogTitleModel dialogTitleModel;
  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  CrewmatesRecord? selectedCrewmate;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<DecksRecord>? crewmateDecks;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    dialogTitleModel = createModel(context, () => DialogTitleModel());
  }

  void dispose() {
    dialogTitleModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.

  String? get radioButtonValue => radioButtonValueController?.value;
}
