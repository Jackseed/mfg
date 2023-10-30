import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_rive_controller.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'c_game_view_widget.dart' show CGameViewWidget;
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CGameViewModel extends FlutterFlowModel<CGameViewWidget> {
  ///  Local state fields for this page.

  bool isPlayer2Victorious = false;

  int randomAvatar1 = 0;

  int randomAvatar2 = 0;

  String avatar1 =
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/magic-6zjv9f/assets/9e5l347v0vwn/output-onlinegiftools.gif';

  String avatar2 =
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/magic-6zjv9f/assets/9e5l347v0vwn/output-onlinegiftools.gif';

  bool isPlayer1Victorious = false;

  int lifeCounter1 = 20;

  int lifeCounter2 = 20;

  int lifeCounterDelta1 = 0;

  int? lifeCounterDelta2 = 0;

  bool isTimer2Set = false;

  bool hasDice = false;

  int diceResult1 = 0;

  int diceResult2 = 0;

  bool isCounter1 = false;

  int counter1 = 0;

  int deltaCounter1 = 0;

  bool isTimerCounter1Set = false;

  bool isCounter2 = false;

  int counter2 = 0;

  int deltaCounter2 = 0;

  bool isTimerCounter2Set = false;

  bool hasSettings1 = true;

  bool hasSettings2 = true;

  bool isTimer1Set = false;

  DateTime? startTime1;

  int showDeltaPeriod = 3000;

  DateTime? startTime2;

  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Stores action output result for [Firestore Query - Query a collection] action in C_GameView widget.
  DecksRecord? deck1;
  // Stores action output result for [Firestore Query - Query a collection] action in C_GameView widget.
  DecksRecord? deck2;
  // Stores action output result for [Firestore Query - Query a collection] action in C_GameView widget.
  List<ImagesRecord>? images;
  // State field(s) for ConfettiPlayer1 widget.
  final confettiPlayer1AnimationsList = [
    'Animation 1',
  ];
  List<FlutterFlowRiveController> confettiPlayer1Controllers = [];
  InstantTimer? minusTimerCounter1;
  InstantTimer? plusTimerCounter1;
  InstantTimer? diceTimer1;
  InstantTimer? endDice1;
  // Stores action output result for [Custom Action - createsMatchupid] action in VictoryButton widget.
  String? matchupId;
  // Stores action output result for [Custom Action - checkIfTodayMatchupGameExists] action in VictoryButton widget.
  bool? hasTodayGame;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  GamesRecord? todayGameDoc;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  PlayersRecord? winnerPlayer;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  MatchupsRecord? existingMatchupDocUpdateGame;
  // Stores action output result for [Custom Action - updateScores] action in VictoryButton widget.
  List<ScoreStruct>? newScoresUpdateGame;
  // Stores action output result for [Backend Call - Create Document] action in VictoryButton widget.
  GamesRecord? savedGameDoc;
  // Stores action output result for [Backend Call - Create Document] action in VictoryButton widget.
  PlayersRecord? player1Doc;
  // Stores action output result for [Backend Call - Create Document] action in VictoryButton widget.
  PlayersRecord? player2Doc;
  // Stores action output result for [Custom Action - checkIfMatchupExists] action in VictoryButton widget.
  bool? hasMatchup;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  MatchupsRecord? existingMatchupDoc;
  // Stores action output result for [Custom Action - updateScores] action in VictoryButton widget.
  List<ScoreStruct>? newScores;
  // Stores action output result for [Custom Action - createScores] action in VictoryButton widget.
  List<ScoreStruct>? createdScores;
  // State field(s) for Dice1-1 widget.
  final dice11AnimationsList = [
    'ShakeFive',
    'ShakeOne',
  ];
  List<FlutterFlowRiveController> dice11Controllers = [];
  // State field(s) for Dice1-2 widget.
  final dice12AnimationsList = [
    'ShakeTwo',
  ];
  List<FlutterFlowRiveController> dice12Controllers = [];
  // State field(s) for Dice1-3 widget.
  final dice13AnimationsList = [
    'ShakeThree',
  ];
  List<FlutterFlowRiveController> dice13Controllers = [];
  // State field(s) for Dice1-4 widget.
  final dice14AnimationsList = [
    'ShakeFour',
  ];
  List<FlutterFlowRiveController> dice14Controllers = [];
  // State field(s) for Dice1-5 widget.
  final dice15AnimationsList = [
    'ShakeFive',
  ];
  List<FlutterFlowRiveController> dice15Controllers = [];
  // State field(s) for Dice1-6 widget.
  final dice16AnimationsList = [
    'ShakeSix',
  ];
  List<FlutterFlowRiveController> dice16Controllers = [];
  // State field(s) for ConfettiPlayer2 widget.
  final confettiPlayer2AnimationsList = [
    'Animation 1',
  ];
  List<FlutterFlowRiveController> confettiPlayer2Controllers = [];
  InstantTimer? minusTimerCounter2;
  InstantTimer? plusTimerCounter2;
  InstantTimer? diceTimer2;
  InstantTimer? endDice2;
  // Stores action output result for [Custom Action - createsMatchupid] action in VictoryButton widget.
  String? matchupId2;
  // Stores action output result for [Custom Action - checkIfTodayMatchupGameExists] action in VictoryButton widget.
  bool? hasTodayGame2;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  GamesRecord? todayGameDoc2;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  PlayersRecord? winnerPlayer2;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  MatchupsRecord? existingMatchupDocUpdateGame2;
  // Stores action output result for [Custom Action - updateScores] action in VictoryButton widget.
  List<ScoreStruct>? newScoresUpdateGame2;
  // Stores action output result for [Backend Call - Create Document] action in VictoryButton widget.
  GamesRecord? savedGameDoc2;
  // Stores action output result for [Backend Call - Create Document] action in VictoryButton widget.
  PlayersRecord? player1Doc2;
  // Stores action output result for [Backend Call - Create Document] action in VictoryButton widget.
  PlayersRecord? player2Doc2;
  // Stores action output result for [Custom Action - checkIfMatchupExists] action in VictoryButton widget.
  bool? hasMatchup2;
  // Stores action output result for [Firestore Query - Query a collection] action in VictoryButton widget.
  MatchupsRecord? existingMatchupDoc2;
  // Stores action output result for [Custom Action - updateScores] action in VictoryButton widget.
  List<ScoreStruct>? newScores2;
  // Stores action output result for [Custom Action - createScores] action in VictoryButton widget.
  List<ScoreStruct>? createdScores2;
  // State field(s) for Dice2-1 widget.
  final dice21AnimationsList = [
    'ShakeFive',
    'ShakeOne',
  ];
  List<FlutterFlowRiveController> dice21Controllers = [];
  // State field(s) for Dice2-2 widget.
  final dice22AnimationsList = [
    'ShakeTwo',
  ];
  List<FlutterFlowRiveController> dice22Controllers = [];
  // State field(s) for Dice2-3 widget.
  final dice23AnimationsList = [
    'ShakeThree',
  ];
  List<FlutterFlowRiveController> dice23Controllers = [];
  // State field(s) for Dice2-4 widget.
  final dice24AnimationsList = [
    'ShakeFour',
  ];
  List<FlutterFlowRiveController> dice24Controllers = [];
  // State field(s) for Dice2-5 widget.
  final dice25AnimationsList = [
    'ShakeFive',
  ];
  List<FlutterFlowRiveController> dice25Controllers = [];
  // State field(s) for Dice2-6 widget.
  final dice26AnimationsList = [
    'ShakeSix',
  ];
  List<FlutterFlowRiveController> dice26Controllers = [];

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    confettiPlayer1AnimationsList.forEach((name) {
      confettiPlayer1Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice11AnimationsList.forEach((name) {
      dice11Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice12AnimationsList.forEach((name) {
      dice12Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice13AnimationsList.forEach((name) {
      dice13Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice14AnimationsList.forEach((name) {
      dice14Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice15AnimationsList.forEach((name) {
      dice15Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice16AnimationsList.forEach((name) {
      dice16Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    confettiPlayer2AnimationsList.forEach((name) {
      confettiPlayer2Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice21AnimationsList.forEach((name) {
      dice21Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice22AnimationsList.forEach((name) {
      dice22Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice23AnimationsList.forEach((name) {
      dice23Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice24AnimationsList.forEach((name) {
      dice24Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice25AnimationsList.forEach((name) {
      dice25Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });

    dice26AnimationsList.forEach((name) {
      dice26Controllers.add(FlutterFlowRiveController(
        name,
        autoplay: false,
      ));
    });
  }

  void dispose() {
    unfocusNode.dispose();
    minusTimerCounter1?.cancel();
    plusTimerCounter1?.cancel();
    diceTimer1?.cancel();
    endDice1?.cancel();
    minusTimerCounter2?.cancel();
    plusTimerCounter2?.cancel();
    diceTimer2?.cancel();
    endDice2?.cancel();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
