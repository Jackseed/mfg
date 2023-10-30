import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'b4_matchup_view_widget.dart' show B4MatchupViewWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class B4MatchupViewModel extends FlutterFlowModel<B4MatchupViewWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Stores action output result for [Firestore Query - Query a collection] action in B4_MatchupView widget.
  List<GamesRecord>? gamess;
  // Stores action output result for [Firestore Query - Query a collection] action in B4_MatchupView widget.
  List<PlayersRecord>? players;
  // Stores action output result for [Backend Call - Read Document] action in B4_MatchupView widget.
  DecksRecord? deck1;
  // Stores action output result for [Backend Call - Read Document] action in B4_MatchupView widget.
  CrewmatesRecord? crewmate1;
  // Stores action output result for [Backend Call - Read Document] action in B4_MatchupView widget.
  DecksRecord? deck2;
  // Stores action output result for [Backend Call - Read Document] action in B4_MatchupView widget.
  CrewmatesRecord? crewmate2;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
