import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_snackbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/select_crewmate/select_crewmate_widget.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'join_crew_model.dart';
export 'join_crew_model.dart';

class JoinCrewWidget extends StatefulWidget {
  const JoinCrewWidget({Key? key}) : super(key: key);

  @override
  _JoinCrewWidgetState createState() => _JoinCrewWidgetState();
}

class _JoinCrewWidgetState extends State<JoinCrewWidget> {
  late JoinCrewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JoinCrewModel());

    _model.codeInputController ??= TextEditingController();
    _model.codeInputFocusNode ??= FocusNode();

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

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF323236), Color(0xFFE6486F)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          wrapWithModel(
            model: _model.dialogTitleModel,
            updateCallback: () => setState(() {}),
            child: DialogTitleWidget(
              formTitle: FFLocalizations.of(context).getText(
                'w6nopoq7' /* Join a crew */,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
              child: RichText(
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: FFLocalizations.of(context).getText(
                        'wm86oe7s' /* Ask your crewmate for the code... */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Noto Sans',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    TextSpan(
                      text: FFLocalizations.of(context).getText(
                        'm23n7sf0' /* paste it here. */,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.0,
                        fontStyle: FontStyle.normal,
                      ),
                    )
                  ],
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Noto Sans',
                        fontSize: 16.0,
                      ),
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextFormField(
              controller: _model.codeInputController,
              focusNode: _model.codeInputFocusNode,
              autofocus: true,
              obscureText: false,
              decoration: InputDecoration(
                labelStyle: FlutterFlowTheme.of(context).labelLarge.override(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 16.0,
                    ),
                hintText: FFLocalizations.of(context).getText(
                  '35s3nc73' /* Paste your crew code */,
                ),
                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 16.0,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).primaryText,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).tertiary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).tertiary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).tertiary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).primaryText,
                prefixIcon: Icon(
                  Icons.lock_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Noto Sans',
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
              validator:
                  _model.codeInputControllerValidator.asValidator(context),
            ),
          ),
          Builder(
            builder: (context) => Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  logFirebaseEvent('JOIN_CREW_COMP_JOIN_BTN_ON_TAP');
                  logFirebaseEvent('Button_firestore_query');
                  _model.crewList = await queryCrewsRecordOnce();
                  if (_model.crewList!
                      .map((e) => valueOrDefault<String>(
                            e.reference.id,
                            'id',
                          ))
                      .toList()
                      .contains(_model.codeInputController.text)) {
                    logFirebaseEvent('Button_alert_dialog');
                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: AlignmentDirectional(0.0, 0.0)
                              .resolve(Directionality.of(context)),
                          child: SelectCrewmateWidget(
                            crewId: _model.codeInputController.text,
                          ),
                        );
                      },
                    ).then((value) => setState(() {}));
                  } else {
                    logFirebaseEvent('Button_update_component_state');
                    setState(() {
                      _model.showSnackbar = true;
                      _model.snackbarMessage = valueOrDefault<String>(
                        FFLocalizations.of(context).getVariableText(
                          enText: 'Incorrect code',
                          frText: 'Code incorrect ',
                        ),
                        'Incorrect code',
                      );
                    });
                    logFirebaseEvent('Button_wait__delay');
                    await Future.delayed(const Duration(milliseconds: 4000));
                    logFirebaseEvent('Button_update_component_state');
                    setState(() {
                      _model.showSnackbar = false;
                    });
                  }

                  setState(() {});
                },
                text: FFLocalizations.of(context).getText(
                  '39jlts1j' /* Join */,
                ),
                icon: Icon(
                  FFIcons.kcrewmates,
                  size: 32.0,
                ),
                options: FFButtonOptions(
                  width: 280.0,
                  height: 56.0,
                  padding: EdgeInsets.all(0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Cinzel Decorative',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      ),
                  elevation: 3.0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          if (_model.showSnackbar)
            Flexible(
              child: Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.customSnackbarModel,
                  updateCallback: () => setState(() {}),
                  child: CustomSnackbarWidget(
                    message: _model.snackbarMessage!,
                  ),
                ),
              ),
            ),
        ].divide(SizedBox(height: 8.0)),
      ),
    );
  }
}
