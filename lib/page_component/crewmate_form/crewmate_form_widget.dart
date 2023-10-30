import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/custom_snackbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'crewmate_form_model.dart';
export 'crewmate_form_model.dart';

class CrewmateFormWidget extends StatefulWidget {
  const CrewmateFormWidget({
    Key? key,
    required this.formTitle,
    String? existingName,
    this.crewmateRef,
    required this.crewRef,
  })  : this.existingName = existingName ?? 'empty',
        super(key: key);

  final String? formTitle;
  final String existingName;
  final DocumentReference? crewmateRef;
  final DocumentReference? crewRef;

  @override
  _CrewmateFormWidgetState createState() => _CrewmateFormWidgetState();
}

class _CrewmateFormWidgetState extends State<CrewmateFormWidget> {
  late CrewmateFormModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrewmateFormModel());

    _model.nameInputController ??= TextEditingController(
        text: (String existingName) {
      return existingName == 'empty' ? '' : existingName;
    }(widget.existingName));
    _model.nameInputFocusNode ??= FocusNode();
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
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
            child: Form(
              key: _model.formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(28.0, 0.0, 20.0, 12.0),
                child: TextFormField(
                  controller: _model.nameInputController,
                  focusNode: _model.nameInputFocusNode,
                  autofocus: true,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelStyle: FlutterFlowTheme.of(context).labelMedium,
                    hintText: FFLocalizations.of(context).getText(
                      'ca58hcsu' /* Type your crewmate name */,
                    ),
                    hintStyle:
                        FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Noto Sans',
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w500,
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
                  validator:
                      _model.nameInputControllerValidator.asValidator(context),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
            child: FFButtonWidget(
              onPressed: () async {
                logFirebaseEvent('CREWMATE_FORM_COMP_SAVE_BTN_ON_TAP');
                if (_model.formKey.currentState == null ||
                    !_model.formKey.currentState!.validate()) {
                  return;
                }
                _model.crewmates = await queryCrewmatesRecordOnce(
                  parent: currentUserDocument?.crewRef,
                );
                if (_model.crewmates!
                    .map((e) => e.name)
                    .toList()
                    .contains(_model.nameInputController.text)) {
                  // Name already taken
                  setState(() {
                    _model.showSnackbar = true;
                    _model.snackbarMessage = 'Name already taken';
                  });
                  await Future.delayed(const Duration(milliseconds: 4000));
                  setState(() {
                    _model.showSnackbar = false;
                  });
                } else {
                  if (widget.existingName != 'empty') {
                    // Get existing crewmate
                    _model.crewmateDocBeforeNameChange =
                        await queryCrewmatesRecordOnce(
                      parent: widget.crewRef,
                      queryBuilder: (crewmatesRecord) => crewmatesRecord.where(
                        'name',
                        isEqualTo: widget.existingName,
                      ),
                      singleRecord: true,
                    ).then((s) => s.firstOrNull);
                    // Update crewmate name

                    await widget.crewmateRef!.update(createCrewmatesRecordData(
                      name: _model.nameInputController.text,
                    ));
                    if (_model.crewmateDocBeforeNameChange?.userId != null &&
                        _model.crewmateDocBeforeNameChange?.userId != '') {
                      // Update user name

                      await _model.crewmateDocBeforeNameChange!.userReference!
                          .update(createUsersRecordData(
                        name: _model.nameInputController.text,
                      ));
                    }
                    // Crewmate updated!
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Crewmate updated!',
                          style: GoogleFonts.getFont(
                            'Noto Sans',
                            color: FlutterFlowTheme.of(context).primary,
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0,
                          ),
                        ),
                        duration: Duration(milliseconds: 4000),
                        backgroundColor: FlutterFlowTheme.of(context).tertiary,
                      ),
                    );
                  } else {
                    // Create crewmate

                    await CrewmatesRecord.createDoc(widget.crewRef!)
                        .set(createCrewmatesRecordData(
                      name: _model.nameInputController.text,
                    ));
                    // Crewmate created!
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Crewmate created!',
                          style: GoogleFonts.getFont(
                            'Noto Sans',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 16.0,
                          ),
                        ),
                        duration: Duration(milliseconds: 4000),
                        backgroundColor: FlutterFlowTheme.of(context).tertiary,
                      ),
                    );
                  }

                  Navigator.pop(context);
                }

                setState(() {});
              },
              text: FFLocalizations.of(context).getText(
                'elbpjfvc' /* Save */,
              ),
              icon: Icon(
                Icons.save,
                size: 24.0,
              ),
              options: FFButtonOptions(
                width: 280.0,
                height: 56.0,
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleLarge,
                elevation: 3.0,
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          if (_model.showSnackbar)
            Expanded(
              child: Align(
                alignment: AlignmentDirectional(0.00, 1.00),
                child: wrapWithModel(
                  model: _model.customSnackbarModel,
                  updateCallback: () => setState(() {}),
                  child: CustomSnackbarWidget(
                    message: _model.snackbarMessage!,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
