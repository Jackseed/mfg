import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/empty_component_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/page_component/crewmate_form/crewmate_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'crewmate_list_model.dart';
export 'crewmate_list_model.dart';

class CrewmateListWidget extends StatefulWidget {
  const CrewmateListWidget({Key? key}) : super(key: key);

  @override
  _CrewmateListWidgetState createState() => _CrewmateListWidgetState();
}

class _CrewmateListWidgetState extends State<CrewmateListWidget> {
  late CrewmateListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrewmateListModel());

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

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: 350.0,
        ),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
              alignment: AlignmentDirectional(-1.0, 0.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 8.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '7egxaj1d' /* Your crewmates */,
                  ),
                  textAlign: TextAlign.start,
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                        fontFamily: 'Cinzel Decorative',
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 18.0,
                      ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        '068litq8' /* Add a Crewmate */,
                      ),
                      textAlign: TextAlign.start,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Noto Sans',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
                Builder(
                  builder: (context) => Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 12.0, 0.0),
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
                        logFirebaseEvent(
                            'CREWMATE_LIST_COMP_AddCrewmate_ON_TAP');
                        logFirebaseEvent('AddCrewmate_alert_dialog');
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
                                  'gqe6012i' /* New Crewmate */,
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
            ),
            Divider(
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).accent4,
            ),
            Expanded(
              child: AuthUserStreamWidget(
                builder: (context) => StreamBuilder<List<CrewmatesRecord>>(
                  stream: queryCrewmatesRecord(
                    parent: currentUserDocument?.crewRef,
                    queryBuilder: (crewmatesRecord) => crewmatesRecord.where(
                      'name',
                      isNotEqualTo:
                          valueOrDefault(currentUserDocument?.name, '') != ''
                              ? valueOrDefault(currentUserDocument?.name, '')
                              : null,
                    ),
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
                    List<CrewmatesRecord> cremateListCrewmatesRecordList =
                        snapshot.data!;
                    if (cremateListCrewmatesRecordList.isEmpty) {
                      return Center(
                        child: EmptyComponentWidget(),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: cremateListCrewmatesRecordList.length,
                      itemBuilder: (context, cremateListIndex) {
                        final cremateListCrewmatesRecord =
                            cremateListCrewmatesRecordList[cremateListIndex];
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 12.0, 8.0, 0.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
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
                                          20.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        cremateListCrewmatesRecord.name,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(1.0, 0.0),
                                    child: Builder(
                                      builder: (context) => Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 2.0, 0.0, 0.0),
                                        child: FlutterFlowIconButton(
                                          borderRadius: 20.0,
                                          borderWidth: 1.0,
                                          buttonSize: 40.0,
                                          icon: Icon(
                                            Icons.mode_edit,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            logFirebaseEvent(
                                                'CREWMATE_LIST_COMP_Edit_ON_TAP');
                                            logFirebaseEvent(
                                                'Edit_alert_dialog');
                                            await showDialog(
                                              context: context,
                                              builder: (dialogContext) {
                                                return Dialog(
                                                  insetPadding: EdgeInsets.zero,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  alignment:
                                                      AlignmentDirectional(
                                                              0.0, 0.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  child: CrewmateFormWidget(
                                                    formTitle:
                                                        FFLocalizations.of(
                                                                context)
                                                            .getText(
                                                      'l8drops2' /* Edit crewmate */,
                                                    ),
                                                    existingName:
                                                        cremateListCrewmatesRecord
                                                            .name,
                                                    crewmateRef:
                                                        cremateListCrewmatesRecord
                                                            .reference,
                                                    crewRef:
                                                        currentUserDocument!
                                                            .crewRef!,
                                                  ),
                                                );
                                              },
                                            ).then((value) => setState(() {}));
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(1.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 2.0, 4.0, 0.0),
                                      child: FlutterFlowIconButton(
                                        borderColor: Colors.transparent,
                                        borderRadius: 20.0,
                                        borderWidth: 1.0,
                                        buttonSize: 40.0,
                                        icon: Icon(
                                          Icons.close,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          logFirebaseEvent(
                                              'CREWMATE_LIST_COMP_Delete_ON_TAP');
                                          logFirebaseEvent(
                                              'Delete_backend_call');
                                          await cremateListCrewmatesRecord
                                              .reference
                                              .delete();
                                          logFirebaseEvent(
                                              'Delete_show_snack_bar');
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                valueOrDefault<String>(
                                                  FFLocalizations.of(context)
                                                      .getVariableText(
                                                    enText: 'Crewmate deleted!',
                                                    frText:
                                                        'Crewmate supprimé !',
                                                  ),
                                                  'Crewmate deleted!',
                                                ),
                                                style: GoogleFonts.getFont(
                                                  'Noto Sans',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 4000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
