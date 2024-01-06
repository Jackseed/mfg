import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_checkbox_group.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'b3_matchup_list_model.dart';
export 'b3_matchup_list_model.dart';

class B3MatchupListWidget extends StatefulWidget {
  const B3MatchupListWidget({
    Key? key,
    required this.filteredDeckList,
  }) : super(key: key);

  final List<String>? filteredDeckList;

  @override
  _B3MatchupListWidgetState createState() => _B3MatchupListWidgetState();
}

class _B3MatchupListWidgetState extends State<B3MatchupListWidget> {
  late B3MatchupListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => B3MatchupListModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'B3_MatchupList'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('B3_MATCHUP_LIST_B3_MatchupList_ON_INIT_S');
      logFirebaseEvent('B3_MatchupList_update_page_state');
      setState(() {
        _model.isDeckFilterOpen = false;
        _model.filteredDeckList = ['demigod'].toList().cast<String>();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    context.watch<FFAppState>();

    return AuthUserStreamWidget(
      builder: (context) => FutureBuilder<List<DecksRecord>>(
        future: queryDecksRecordOnce(
          queryBuilder: (decksRecord) => decksRecord
              .where(
                'crewId',
                isEqualTo: valueOrDefault(currentUserDocument?.crewId, '') != ''
                    ? valueOrDefault(currentUserDocument?.crewId, '')
                    : null,
              )
              .orderBy('name'),
        ),
        builder: (context, snapshot) {
          // Customize what your widget looks like when it's loading.
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              body: Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SpinKitFadingFour(
                    color: Color(0xFFE6486F),
                    size: 50.0,
                  ),
                ),
              ),
            );
          }
          List<DecksRecord> b3MatchupListDecksRecordList = snapshot.data!;
          return GestureDetector(
            onTap: () => _model.unfocusNode.canRequestFocus
                ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                : FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  logFirebaseEvent('B3_MATCHUP_LIST_FloatingActionButton_0c2');
                  logFirebaseEvent('FloatingActionButton_navigate_to');

                  context.pushNamed('B2_AddMatchup');
                },
                backgroundColor: FlutterFlowTheme.of(context).primary,
                icon: Icon(
                  Icons.add,
                ),
                elevation: 8.0,
                label: Text(
                  FFLocalizations.of(context).getText(
                    'kpx4xw60' /* Add match */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: true,
                title: Text(
                  FFLocalizations.of(context).getText(
                    '1q1aupjz' /* Matchups */,
                  ),
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Cinzel Decorative',
                        fontSize: 24.0,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                actions: [],
                centerTitle: true,
                elevation: 4.0,
              ),
              body: SafeArea(
                top: true,
                child: StreamBuilder<List<MatchupsRecord>>(
                  stream: queryMatchupsRecord(
                    queryBuilder: (matchupsRecord) => matchupsRecord
                        .where(
                          'crewId',
                          isEqualTo: valueOrDefault(
                                      currentUserDocument?.crewId, '') !=
                                  ''
                              ? valueOrDefault(currentUserDocument?.crewId, '')
                              : null,
                        )
                        .whereArrayContainsAny(
                            'deckIds',
                            functions.fromDeckNamesToIds(
                                        _model.checkboxGroupValues?.toList(),
                                        b3MatchupListDecksRecordList
                                            .toList()) !=
                                    ''
                                ? functions.fromDeckNamesToIds(
                                    _model.checkboxGroupValues?.toList(),
                                    b3MatchupListDecksRecordList.toList())
                                : null),
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
                    List<MatchupsRecord> queryWrapperMatchupsRecordList =
                        snapshot.data!;
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
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (queryWrapperMatchupsRecordList.length > 0)
                            Stack(
                              children: [
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height:
                                      MediaQuery.sizeOf(context).height * 1.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF323236),
                                        Color(0xFFE6486F)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final matchups =
                                                queryWrapperMatchupsRecordList
                                                    .toList();
                                            return ListView.separated(
                                              padding: EdgeInsets.fromLTRB(
                                                0,
                                                72.0,
                                                0,
                                                110.0,
                                              ),
                                              primary: false,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: matchups.length,
                                              separatorBuilder: (_, __) =>
                                                  SizedBox(height: 20.0),
                                              itemBuilder:
                                                  (context, matchupsIndex) {
                                                final matchupsItem =
                                                    matchups[matchupsIndex];
                                                return Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 0.0, 20.0, 0.0),
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      logFirebaseEvent(
                                                          'B3_MATCHUP_LIST_PAGE_GameItem_ON_TAP');
                                                      logFirebaseEvent(
                                                          'GameItem_navigate_to');

                                                      context.pushNamed(
                                                        'B4_MatchupView',
                                                        queryParameters: {
                                                          'matchupId':
                                                              serializeParam(
                                                            matchupsItem
                                                                .matchupId,
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            blurRadius: 3.0,
                                                            color: Color(
                                                                0x411D2429),
                                                            offset: Offset(
                                                                0.0, 1.0),
                                                          )
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30.0),
                                                      ),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        elevation: 1.0,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.0),
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 4.0,
                                                                color: Color(
                                                                    0x00323236),
                                                                offset: Offset(
                                                                    0.0, 2.0),
                                                              )
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                          ),
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            8.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child: FutureBuilder<
                                                                        DecksRecord>(
                                                                      future: DecksRecord.getDocumentOnce(matchupsItem
                                                                          .scores
                                                                          .first
                                                                          .deckRef!),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        // Customize what your widget looks like when it's loading.
                                                                        if (!snapshot
                                                                            .hasData) {
                                                                          return Center(
                                                                            child:
                                                                                SizedBox(
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                              child: SpinKitFadingFour(
                                                                                color: Color(0xFFE6486F),
                                                                                size: 50.0,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }
                                                                        final player1DecksRecord =
                                                                            snapshot.data!;
                                                                        return Container(
                                                                          width:
                                                                              MediaQuery.sizeOf(context).width * 0.4,
                                                                          height:
                                                                              MediaQuery.sizeOf(context).height * 0.2,
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                                                                child: AutoSizeText(
                                                                                  player1DecksRecord.name,
                                                                                  maxLines: 1,
                                                                                  style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                        fontFamily: 'Cinzel Decorative',
                                                                                        fontSize: 30.0,
                                                                                        lineHeight: 0.8,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Container(
                                                                                      width: MediaQuery.sizeOf(context).width * 0.15,
                                                                                      height: MediaQuery.sizeOf(context).width * 0.15,
                                                                                      clipBehavior: Clip.antiAlias,
                                                                                      decoration: BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                      ),
                                                                                      child: CachedNetworkImage(
                                                                                        fadeInDuration: Duration(milliseconds: 500),
                                                                                        fadeOutDuration: Duration(milliseconds: 500),
                                                                                        imageUrl: player1DecksRecord.avatarUrl,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                                                                                      child: Text(
                                                                                        matchupsItem.scores.first.score.toString(),
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: 'Noto Sans',
                                                                                              fontSize: 32.0,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            8.0,
                                                                            0.0,
                                                                            8.0,
                                                                            0.0),
                                                                    child: FutureBuilder<
                                                                        DecksRecord>(
                                                                      future: DecksRecord.getDocumentOnce(matchupsItem
                                                                          .scores
                                                                          .last
                                                                          .deckRef!),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        // Customize what your widget looks like when it's loading.
                                                                        if (!snapshot
                                                                            .hasData) {
                                                                          return Center(
                                                                            child:
                                                                                SizedBox(
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                              child: SpinKitFadingFour(
                                                                                color: Color(0xFFE6486F),
                                                                                size: 50.0,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }
                                                                        final player2DecksRecord =
                                                                            snapshot.data!;
                                                                        return Container(
                                                                          width:
                                                                              MediaQuery.sizeOf(context).width * 0.4,
                                                                          height:
                                                                              MediaQuery.sizeOf(context).height * 0.2,
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                                                                child: AutoSizeText(
                                                                                  player2DecksRecord.name,
                                                                                  maxLines: 1,
                                                                                  style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                        fontFamily: 'Cinzel Decorative',
                                                                                        fontSize: 30.0,
                                                                                        lineHeight: 0.8,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                                                                                      child: Text(
                                                                                        matchupsItem.scores.last.score.toString(),
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: 'Noto Sans',
                                                                                              fontSize: 32.0,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      width: MediaQuery.sizeOf(context).width * 0.15,
                                                                                      height: MediaQuery.sizeOf(context).width * 0.15,
                                                                                      clipBehavior: Clip.antiAlias,
                                                                                      decoration: BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                      ),
                                                                                      child: CachedNetworkImage(
                                                                                        fadeInDuration: Duration(milliseconds: 500),
                                                                                        fadeOutDuration: Duration(milliseconds: 500),
                                                                                        imageUrl: player2DecksRecord.avatarUrl,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0, 8.0, 0.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FFButtonWidget(
                                          onPressed: () async {
                                            logFirebaseEvent(
                                                'B3_MATCHUP_LIST_PAGE_DECKS_BTN_ON_TAP');
                                            logFirebaseEvent(
                                                'Button_update_page_state');
                                            setState(() {
                                              _model.isDeckFilterOpen =
                                                  valueOrDefault<bool>(
                                                !_model.isDeckFilterOpen,
                                                false,
                                              );
                                            });
                                          },
                                          text: FFLocalizations.of(context)
                                              .getText(
                                            'f5s9h70j' /* Decks */,
                                          ),
                                          icon: Icon(
                                            Icons.filter_list,
                                            size: 15.0,
                                          ),
                                          options: FFButtonOptions(
                                            width: 150.0,
                                            height: 50.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: Color(0xFF645D5D),
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily:
                                                          'Cinzel Decorative',
                                                      color: Colors.white,
                                                      fontSize: 18.0,
                                                    ),
                                            elevation: 3.0,
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                        if (_model.isDeckFilterOpen)
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFF645D5D),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Stack(
                                                children: [
                                                  FlutterFlowCheckboxGroup(
                                                    options:
                                                        b3MatchupListDecksRecordList
                                                            .map((e) =>
                                                                valueOrDefault<
                                                                    String>(
                                                                  e.name,
                                                                  '--',
                                                                ))
                                                            .toList(),
                                                    onChanged: (val) =>
                                                        setState(() => _model
                                                                .checkboxGroupValues =
                                                            val),
                                                    controller: _model
                                                            .checkboxGroupValueController ??=
                                                        FormFieldController<
                                                            List<String>>(
                                                      [],
                                                    ),
                                                    activeColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                    checkColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    checkboxBorderColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge
                                                            .override(
                                                              fontFamily:
                                                                  'Noto Sans',
                                                              fontSize: 18.0,
                                                            ),
                                                    checkboxBorderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    initialized: _model
                                                            .checkboxGroupValues !=
                                                        null,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (queryWrapperMatchupsRecordList.length == 0)
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    28.0, 0.0, 28.0, 40.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FFIcons.kred,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 90.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 24.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'wxo7v8rv' /* You don't have any matchup yet */,
                                        ),
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Cinzel Decorative',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 4.0, 0.0, 0.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'bikscpls' /* Create your first match with t... */,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Noto Sans',
                                                fontSize: 12.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
