import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/small_components/crewmate_select/crewmate_select_widget.dart';
import '/small_components/deck_select/deck_select_widget.dart';
import 'player_form_widget.dart' show PlayerFormWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PlayerFormModel extends FlutterFlowModel<PlayerFormWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for CrewmateSelect component.
  late CrewmateSelectModel crewmateSelectModel;
  // Model for DeckSelect component.
  late DeckSelectModel deckSelectModel;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    crewmateSelectModel = createModel(context, () => CrewmateSelectModel());
    deckSelectModel = createModel(context, () => DeckSelectModel());
  }

  void dispose() {
    crewmateSelectModel.dispose();
    deckSelectModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
