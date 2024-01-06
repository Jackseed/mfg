import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/page_component/crewmate_form/crewmate_form_widget.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'select_crewmate_model.dart';
export 'select_crewmate_model.dart';

class SelectCrewmateWidget extends StatefulWidget {
  const SelectCrewmateWidget({
    Key? key,
    required this.crewId,
  }) : super(key: key);

  final String? crewId;

  @override
  _SelectCrewmateWidgetState createState() => _SelectCrewmateWidgetState();
}

class _SelectCrewmateWidgetState extends State<SelectCrewmateWidget> {
  late SelectCrewmateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectCrewmateModel());

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

    return StreamBuilder<List<CrewmatesRecord>>(
      stream: queryCrewmatesRecord(
        parent: functions.fromCrewIdToRef(widget.crewId!),
        queryBuilder: (crewmatesRecord) => crewmatesRecord.orderBy('name'),
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: SpinKitFadingFour(
                color: Color(0xFFE6486F),
                size: 50.0,
              ),
            ),
          );
        }
        List<CrewmatesRecord> containerCrewmatesRecordList = snapshot.data!;
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.dialogTitleModel,
                updateCallback: () => setState(() {}),
                child: DialogTitleWidget(
                  formTitle: FFLocalizations.of(context).getText(
                    'twpp7myp' /* Crewmate selection */,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 4.0),
                  child: Text(
                    FFLocalizations.of(context).getText(
                      'jykel7yl' /* Select your player */,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Noto Sans',
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 12.0),
                  child: Text(
                    FFLocalizations.of(context).getText(
                      'txbsr4g3' /* (you can change your nickname ... */,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Noto Sans',
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ),
              ),
              if (containerCrewmatesRecordList
                      .where((e) => e.userId == null || e.userId == '')
                      .toList()
                      .length >
                  0)
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                    child: FlutterFlowRadioButton(
                      options: containerCrewmatesRecordList
                          .where((e) => e.userId == null || e.userId == '')
                          .toList()
                          .map((e) => e.name)
                          .toList()
                          .toList(),
                      onChanged: (val) => setState(() {}),
                      controller: _model.radioButtonValueController ??=
                          FormFieldController<String>(null),
                      optionHeight: 40.0,
                      textStyle: FlutterFlowTheme.of(context).labelMedium,
                      selectedTextStyle:
                          FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Noto Sans',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w800,
                              ),
                      buttonPosition: RadioButtonPosition.left,
                      direction: Axis.vertical,
                      radioButtonColor: FlutterFlowTheme.of(context).tertiary,
                      inactiveRadioButtonColor:
                          FlutterFlowTheme.of(context).primaryBackground,
                      toggleable: false,
                      horizontalAlignment: WrapAlignment.start,
                      verticalAlignment: WrapCrossAlignment.start,
                    ),
                  ),
                ),
              if (containerCrewmatesRecordList
                      .where((e) => e.userId == null || e.userId == '')
                      .toList()
                      .length ==
                  0)
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 4.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'orrnpuii' /* No option */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Noto Sans',
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ),
              Divider(
                thickness: 1.0,
                color: FlutterFlowTheme.of(context).accent4,
              ),
              Builder(
                builder: (context) => Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      logFirebaseEvent(
                          'SELECT_CREWMATE_Container_1w00ccox_ON_TA');
                      logFirebaseEvent('Container_alert_dialog');
                      await showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return Dialog(
                            insetPadding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            alignment: AlignmentDirectional(0.0, 0.0)
                                .resolve(Directionality.of(context)),
                            child: CrewmateFormWidget(
                              formTitle: FFLocalizations.of(context).getText(
                                '019o280q' /* New Crewmate */,
                              ),
                              crewRef:
                                  functions.fromCrewIdToRef(widget.crewId!),
                            ),
                          );
                        },
                      ).then((value) => setState(() {}));
                    },
                    child: Material(
                      color: Colors.transparent,
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x00323236),
                              offset: Offset(0.0, 2.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 20.0, 0.0, 20.0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'l4xd3pmn' /* Or add it if it's missing */,
                                  ),
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: 'Noto Sans',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  5.0, 0.0, 12.0, 0.0),
                              child: FlutterFlowIconButton(
                                borderRadius: 20.0,
                                borderWidth: 1.0,
                                buttonSize: 48.0,
                                icon: Icon(
                                  Icons.add,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  size: 34.0,
                                ),
                                onPressed: () {
                                  print('AddButton pressed ...');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.6),
                  child: FFButtonWidget(
                    onPressed: (_model.radioButtonValue == null ||
                            _model.radioButtonValue == '')
                        ? null
                        : () async {
                            logFirebaseEvent(
                                'SELECT_CREWMATE_ALL_GOOD!_BTN_ON_TAP');
                            // Get selected Crewmate
                            logFirebaseEvent('Button_GetselectedCrewmate');
                            _model.selectedCrewmate =
                                await queryCrewmatesRecordOnce(
                              parent: currentUserDocument?.crewRef,
                              queryBuilder: (crewmatesRecord) =>
                                  crewmatesRecord.where(
                                'name',
                                isEqualTo: containerCrewmatesRecordList
                                    .where((e) =>
                                        e.name == _model.radioButtonValue)
                                    .toList()
                                    .first
                                    .name,
                              ),
                              singleRecord: true,
                            ).then((s) => s.firstOrNull);
                            // Update crewmate
                            logFirebaseEvent('Button_Updatecrewmate');

                            await _model.selectedCrewmate!.reference
                                .update(createCrewmatesRecordData(
                              userId: currentUserUid,
                            ));
                            // Update user
                            logFirebaseEvent('Button_Updateuser');

                            await currentUserReference!
                                .update(createUsersRecordData(
                              name: _model.selectedCrewmate?.name,
                              crewId: widget.crewId,
                              crewmateRef: _model.selectedCrewmate?.reference,
                            ));
                            // Get crewmate Decks
                            logFirebaseEvent('Button_GetcrewmateDecks');
                            _model.crewmateDecks = await queryDecksRecordOnce(
                              queryBuilder: (decksRecord) => decksRecord.where(
                                'crewmateId',
                                isEqualTo:
                                    _model.selectedCrewmate?.reference.id,
                              ),
                              limit: 100,
                            );
                            if (_model.crewmateDecks!.length > 0) {
                              while (_model.loopCount <
                                  _model.crewmateDecks!.length) {
                                // Update decks with userId
                                logFirebaseEvent(
                                    'Button_UpdatedeckswithuserId');

                                await containerCrewmatesRecordList[
                                        _model.loopCount]
                                    .reference
                                    .update(createCrewmatesRecordData(
                                      userId: currentUserUid,
                                    ));
                                logFirebaseEvent(
                                    'Button_update_component_state');
                                setState(() {
                                  _model.loopCount = _model.loopCount + 1;
                                });
                              }
                            }
                            logFirebaseEvent(
                                'Button_close_dialog,_drawer,_etc');
                            Navigator.pop(context);
                            logFirebaseEvent(
                                'Button_close_dialog,_drawer,_etc');
                            Navigator.pop(context);
                            // Added to crew!
                            logFirebaseEvent('Button_Addedtocrew!');
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  valueOrDefault<String>(
                                    FFLocalizations.of(context).getVariableText(
                                      enText: 'Welcome to your Crew!',
                                      frText: 'Bienvenue dans votre crew !',
                                    ),
                                    'Welcome to your Crew!',
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
                      '8ul4j5vv' /* All good! */,
                    ),
                    icon: Icon(
                      FFIcons.kblue,
                      size: 24.0,
                    ),
                    options: FFButtonOptions(
                      width: 280.0,
                      height: 56.0,
                      padding: EdgeInsets.all(0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Montserrat',
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      disabledColor: FlutterFlowTheme.of(context).primary,
                      disabledTextColor:
                          FlutterFlowTheme.of(context).disabledText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
