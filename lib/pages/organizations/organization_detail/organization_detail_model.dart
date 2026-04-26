import '/flutter_flow/flutter_flow_model.dart';
import 'package:flutter/material.dart';
import 'organization_detail_widget.dart' show OrganizationDetailWidget;

class OrganizationDetailModel
    extends FlutterFlowModel<OrganizationDetailWidget> {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
