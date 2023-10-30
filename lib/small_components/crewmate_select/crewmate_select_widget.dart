import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/page_component/crewmate_form/crewmate_form_widget.dart';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'crewmate_select_model.dart';
export 'crewmate_select_model.dart';

class CrewmateSelectWidget extends StatefulWidget {
  const CrewmateSelectWidget({
    Key? key,
    this.playerList,
    String? selectedPlayer,
    required this.playerToRemoveFromList,
  })  : this.selectedPlayer = selectedPlayer ?? 'empty',
        super(key: key);

  final List<String>? playerList;
  final String selectedPlayer;
  final String? playerToRemoveFromList;

  @override
  _CrewmateSelectWidgetState createState() => _CrewmateSelectWidgetState();
}

class _CrewmateSelectWidgetState extends State<CrewmateSelectWidget> {
  late CrewmateSelectModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrewmateSelectModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FlutterFlowDropDown<String>(
          controller: _model.playerSelectValueController ??=
              FormFieldController<String>(
            _model.playerSelectValue ??= (String selectedPlayer) {
              return selectedPlayer == 'empty' ? null : selectedPlayer;
            }(widget.selectedPlayer),
          ),
          options: widget.playerList!
              .where((e) => e != widget.playerToRemoveFromList)
              .toList(),
          onChanged: (val) => setState(() => _model.playerSelectValue = val),
          width: 300.0,
          height: 50.0,
          textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                fontFamily: 'Noto Sans',
                color: valueOrDefault<Color>(
                  (String initiallySelectedPlayer) {
                    return initiallySelectedPlayer != 'empty';
                  }(widget.selectedPlayer)
                      ? Color(0xFFBDBDBD)
                      : FlutterFlowTheme.of(context).primary,
                  FlutterFlowTheme.of(context).primary,
                ),
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
          hintText: FFLocalizations.of(context).getText(
            'pfd6rjvo' /* Select a player */,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 2.0,
          borderColor: FlutterFlowTheme.of(context).primaryBackground,
          borderWidth: 2.0,
          borderRadius: 8.0,
          margin: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
          hidesUnderline: true,
          disabled: widget.selectedPlayer != 'empty',
          isSearchable: false,
          isMultiSelect: false,
        ),
        if (widget.selectedPlayer == 'empty')
          Builder(
            builder: (context) => Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: FlutterFlowTheme.of(context).primary,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                fillColor: FlutterFlowTheme.of(context).primary,
                icon: Icon(
                  Icons.add,
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  size: 24.0,
                ),
                onPressed: () async {
                  logFirebaseEvent('CREWMATE_SELECT_COMP_add_ICN_ON_TAP');
                  await showAlignedDialog(
                    context: context,
                    isGlobal: true,
                    avoidOverflow: false,
                    targetAnchor: AlignmentDirectional(0.0, 0.0)
                        .resolve(Directionality.of(context)),
                    followerAnchor: AlignmentDirectional(0.0, 0.0)
                        .resolve(Directionality.of(context)),
                    builder: (dialogContext) {
                      return Material(
                        color: Colors.transparent,
                        child: CrewmateFormWidget(
                          formTitle: FFLocalizations.of(context).getText(
                            'xn2lrhzj' /* Add a Crewmate */,
                          ),
                          crewRef: currentUserDocument!.crewRef!,
                        ),
                      );
                    },
                  ).then((value) => setState(() {}));
                },
              ),
            ),
          ),
      ],
    );
  }
}
