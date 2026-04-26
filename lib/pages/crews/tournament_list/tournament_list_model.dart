import '/flutter_flow/flutter_flow_util.dart';
import 'tournament_list_widget.dart' show TournamentListWidget;
import 'package:flutter/material.dart';

class TournamentListModel extends FlutterFlowModel<TournamentListWidget> {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
