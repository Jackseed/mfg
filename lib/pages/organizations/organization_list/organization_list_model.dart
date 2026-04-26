import '/flutter_flow/flutter_flow_model.dart';
import 'package:flutter/material.dart';
import 'organization_list_widget.dart' show OrganizationListWidget;

class OrganizationListModel extends FlutterFlowModel<OrganizationListWidget> {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
