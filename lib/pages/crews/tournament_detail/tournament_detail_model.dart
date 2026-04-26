import '/flutter_flow/flutter_flow_util.dart';
import 'tournament_detail_widget.dart' show TournamentDetailWidget;
import 'package:flutter/material.dart';

class TournamentDetailModel extends FlutterFlowModel<TournamentDetailWidget> {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
