import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'crew_form_model.dart';
export 'crew_form_model.dart';

class CrewFormWidget extends StatefulWidget {
  const CrewFormWidget({
    Key? key,
    required this.formTitle,
  }) : super(key: key);

  final String? formTitle;

  @override
  _CrewFormWidgetState createState() => _CrewFormWidgetState();
}

class _CrewFormWidgetState extends State<CrewFormWidget> {
  late CrewFormModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrewFormModel());

    _model.crewNameFieldController ??= TextEditingController();
    _model.crewNameFieldFocusNode ??= FocusNode();

    _model.userNameFieldController ??= TextEditingController();
    _model.userNameFieldFocusNode ??= FocusNode();

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
              formTitle: widget.formTitle,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              decoration: BoxDecoration(),
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Form(
                key: _model.formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextFormField(
                      controller: _model.crewNameFieldController,
                      focusNode: _model.crewNameFieldFocusNode,
                      autofocus: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelStyle:
                            FlutterFlowTheme.of(context).labelLarge.override(
                                  fontFamily: 'Noto Sans',
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                        hintText: FFLocalizations.of(context).getText(
                          'j7yh8p6k' /* What's your crew name? */,
                        ),
                        hintStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Noto Sans',
                                  color: FlutterFlowTheme.of(context).primary,
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
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        prefixIcon: Icon(
                          FFIcons.kcrewmates,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Noto Sans',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                      validator: _model.crewNameFieldControllerValidator
                          .asValidator(context),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                      child: TextFormField(
                        controller: _model.userNameFieldController,
                        focusNode: _model.userNameFieldFocusNode,
                        autofocus: true,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                          hintText: FFLocalizations.of(context).getText(
                            'xcd8pnzr' /* What's your pseudo? */,
                          ),
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Noto Sans',
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
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
                            Icons.person,
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Noto Sans',
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                        validator: _model.userNameFieldControllerValidator
                            .asValidator(context),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          logFirebaseEvent(
                              'CREW_FORM_COMP_LET\'S_GO!_BTN_ON_TAP');
                          logFirebaseEvent('Button_validate_form');
                          if (_model.formKey.currentState == null ||
                              !_model.formKey.currentState!.validate()) {
                            return;
                          }
                          // Create Crew
                          logFirebaseEvent('Button_CreateCrew');

                          var crewsRecordReference =
                              CrewsRecord.collection.doc();
                          await crewsRecordReference.set(createCrewsRecordData(
                            name: _model.crewNameFieldController.text,
                          ));
                          _model.crewDoc = CrewsRecord.getDocumentFromData(
                              createCrewsRecordData(
                                name: _model.crewNameFieldController.text,
                              ),
                              crewsRecordReference);
                          // Create Crewmate
                          logFirebaseEvent('Button_CreateCrewmate');

                          var crewmatesRecordReference =
                              CrewmatesRecord.createDoc(
                                  _model.crewDoc!.reference);
                          await crewmatesRecordReference
                              .set(createCrewmatesRecordData(
                            userId: currentUserUid,
                            name: _model.userNameFieldController.text,
                          ));
                          _model.crewmateDoc =
                              CrewmatesRecord.getDocumentFromData(
                                  createCrewmatesRecordData(
                                    userId: currentUserUid,
                                    name: _model.userNameFieldController.text,
                                  ),
                                  crewmatesRecordReference);
                          // Update User
                          logFirebaseEvent('Button_UpdateUser');

                          await currentUserReference!
                              .update(createUsersRecordData(
                            crewId: _model.crewDoc?.reference.id,
                            name: _model.userNameFieldController.text,
                            crewmateRef: _model.crewmateDoc?.reference,
                          ));
                          // Back to home
                          logFirebaseEvent('Button_Backtohome');
                          context.safePop();
                          // Crew created!
                          logFirebaseEvent('Button_Crewcreated!');
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                valueOrDefault<String>(
                                  FFLocalizations.of(context).getVariableText(
                                    enText: 'Crew created!',
                                    frText: 'Crew créé !',
                                  ),
                                  'Crew created!',
                                ),
                                style: GoogleFonts.getFont(
                                  'Noto Sans',
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                ),
                              ),
                              duration: Duration(milliseconds: 4000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).tertiary,
                            ),
                          );

                          setState(() {});
                        },
                        text: FFLocalizations.of(context).getText(
                          'dpwcurjk' /* Let's go! */,
                        ),
                        icon: Icon(
                          FFIcons.kgreen,
                          size: 24.0,
                        ),
                        options: FFButtonOptions(
                          width: 280.0,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 4.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Cinzel Decorative',
                                    color: Colors.white,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
