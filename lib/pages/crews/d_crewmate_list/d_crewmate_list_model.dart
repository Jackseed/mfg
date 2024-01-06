import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/crewmate_form/crewmate_form_widget.dart';
import '/page_component/crewmate_list/crewmate_list_widget.dart';
import 'd_crewmate_list_widget.dart' show DCrewmateListWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DCrewmateListModel extends FlutterFlowModel<DCrewmateListWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for CrewmateList component.
  late CrewmateListModel crewmateListModel;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    crewmateListModel = createModel(context, () => CrewmateListModel());
  }

  void dispose() {
    unfocusNode.dispose();
    crewmateListModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
