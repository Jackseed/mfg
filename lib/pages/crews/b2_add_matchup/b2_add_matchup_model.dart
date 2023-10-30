import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_count_controller.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/player_form/player_form_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'b2_add_matchup_widget.dart' show B2AddMatchupWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class B2AddMatchupModel extends FlutterFlowModel<B2AddMatchupWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  DateTime? datePicked;
  // Model for Player1.
  late PlayerFormModel player1Model;
  // State field(s) for Player1CountScore widget.
  int? player1CountScoreValue;
  // Model for Player2.
  late PlayerFormModel player2Model;
  // State field(s) for Player2CountScore widget.
  int? player2CountScoreValue;
  // Stores action output result for [Firestore Query - Query a collection] action in SaveButton widget.
  DecksRecord? deck1;
  // Stores action output result for [Firestore Query - Query a collection] action in SaveButton widget.
  DecksRecord? deck2;
  // Stores action output result for [Custom Action - createsMatchupid] action in SaveButton widget.
  String? matchupId;
  // Stores action output result for [Custom Action - checkIfDateMatchupGameExists] action in SaveButton widget.
  bool? hasDateGame;
  // Stores action output result for [Firestore Query - Query a collection] action in SaveButton widget.
  GamesRecord? dateGame;
  // Stores action output result for [Firestore Query - Query a collection] action in SaveButton widget.
  List<PlayersRecord>? dateGamePlayers;
  // Stores action output result for [Firestore Query - Query a collection] action in SaveButton widget.
  MatchupsRecord? matchupDocExistingGame;
  // Stores action output result for [Custom Action - updateScores] action in SaveButton widget.
  List<ScoreStruct>? updatedMatchupScoreExistingGame;
  // Stores action output result for [Backend Call - Create Document] action in SaveButton widget.
  GamesRecord? newGameDoc;
  // Stores action output result for [Backend Call - Create Document] action in SaveButton widget.
  PlayersRecord? player1Doc;
  // Stores action output result for [Backend Call - Create Document] action in SaveButton widget.
  PlayersRecord? player2Doc;
  // Stores action output result for [Custom Action - checkIfMatchupExists] action in SaveButton widget.
  bool? hasMatchup;
  // Stores action output result for [Firestore Query - Query a collection] action in SaveButton widget.
  MatchupsRecord? matchupDocNewGame;
  // Stores action output result for [Custom Action - updateScores] action in SaveButton widget.
  List<ScoreStruct>? updatedMatchupScoreNewGame;
  // Stores action output result for [Custom Action - createScores] action in SaveButton widget.
  List<ScoreStruct>? newMatchupScore;
  // Stores action output result for [Backend Call - Create Document] action in SaveButton widget.
  MatchupsRecord? newMatchupDoc;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    player1Model = createModel(context, () => PlayerFormModel());
    player2Model = createModel(context, () => PlayerFormModel());
  }

  void dispose() {
    unfocusNode.dispose();
    player1Model.dispose();
    player2Model.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
