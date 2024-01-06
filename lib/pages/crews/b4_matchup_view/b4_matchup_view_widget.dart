import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'b4_matchup_view_model.dart';
export 'b4_matchup_view_model.dart';

class B4MatchupViewWidget extends StatefulWidget {
  const B4MatchupViewWidget({
    Key? key,
    required this.matchupId,
  }) : super(key: key);

  final String? matchupId;

  @override
  _B4MatchupViewWidgetState createState() => _B4MatchupViewWidgetState();
}

class _B4MatchupViewWidgetState extends State<B4MatchupViewWidget> {
  late B4MatchupViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => B4MatchupViewModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'B4_MatchupView'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('B4_MATCHUP_VIEW_B4_MatchupView_ON_INIT_S');
      // Get games
      logFirebaseEvent('B4_MatchupView_Getgames');
      _model.gamess = await queryGamesRecordOnce(
        queryBuilder: (gamesRecord) => gamesRecord
            .where(
              'matchupId',
              isEqualTo: widget.matchupId,
            )
            .orderBy('date', descending: true),
      );
      // Get players
      logFirebaseEvent('B4_MatchupView_Getplayers');
      _model.players = await queryPlayersRecordOnce(
        parent: _model.gamess?.first?.reference,
      );
      // Get deck1
      logFirebaseEvent('B4_MatchupView_Getdeck1');
      _model.deck1 =
          await DecksRecord.getDocumentOnce(_model.players!.first.deckRef!);
      // Get crewmate1
      logFirebaseEvent('B4_MatchupView_Getcrewmate1');
      _model.crewmate1 = await CrewmatesRecord.getDocumentOnce(
          _model.players!.first.crewmateRef!);
      // Get deck2
      logFirebaseEvent('B4_MatchupView_Getdeck2');
      _model.deck2 =
          await DecksRecord.getDocumentOnce(_model.players!.last.deckRef!);
      // Get crewmate2
      logFirebaseEvent('B4_MatchupView_Getcrewmate2');
      _model.crewmate2 = await CrewmatesRecord.getDocumentOnce(
          _model.players!.last.crewmateRef!);
      // Rebuild page
      logFirebaseEvent('B4_MatchupView_Rebuildpage');
      setState(() {});
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

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            logFirebaseEvent('B4_MATCHUP_VIEW_FloatingActionButton_0ff');
            logFirebaseEvent('FloatingActionButton_navigate_to');

            context.pushNamed(
              'B2_AddMatchup',
              queryParameters: {
                'matchupId': serializeParam(
                  widget.matchupId,
                  ParamType.String,
                ),
                'playerName1': serializeParam(
                  _model.crewmate1?.name,
                  ParamType.String,
                ),
                'deckName1': serializeParam(
                  _model.deck1?.name,
                  ParamType.String,
                ),
                'playerName2': serializeParam(
                  _model.crewmate2?.name,
                  ParamType.String,
                ),
                'deckName2': serializeParam(
                  _model.deck2?.name,
                  ParamType.String,
                ),
              }.withoutNulls,
            );
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          icon: Icon(
            Icons.add,
          ),
          elevation: 8.0,
          label: Text(
            FFLocalizations.of(context).getText(
              'b4plnj9y' /* Add match */,
            ),
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            valueOrDefault<String>(
              (String? deckName1, String? deckName2) {
                return (deckName1 != null && deckName2 != null)
                    ? '$deckName1 - $deckName2'
                    : 'Matchup History';
              }(_model.deck1?.name, _model.deck2?.name),
              'Matchup History',
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
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeIn,
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF323236), Color(0xFFE6486F)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: StreamBuilder<List<GamesRecord>>(
                stream: queryGamesRecord(
                  queryBuilder: (gamesRecord) => gamesRecord
                      .where(
                        'matchupId',
                        isEqualTo:
                            widget.matchupId != '' ? widget.matchupId : null,
                      )
                      .orderBy('date', descending: true),
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
                  List<GamesRecord> gameListGamesRecordList = snapshot.data!;
                  return Container(
                    decoration: BoxDecoration(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Builder(
                            builder: (context) {
                              final gameDates = gameListGamesRecordList
                                  .map((e) => e.date)
                                  .withoutNulls
                                  .toList();
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: gameDates.length,
                                itemBuilder: (context, gameDatesIndex) {
                                  final gameDatesItem =
                                      gameDates[gameDatesIndex];
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 20.0, 0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              dateTimeFormat(
                                                'MMMMEEEEd',
                                                gameDatesItem,
                                                locale:
                                                    FFLocalizations.of(context)
                                                        .languageCode,
                                              ),
                                              textAlign: TextAlign.start,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineSmall
                                                      .override(
                                                        fontFamily:
                                                            'Cinzel Decorative',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                      ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 12.0, 0.0, 0.0),
                                            child: Builder(
                                              builder: (context) {
                                                final games =
                                                    gameListGamesRecordList
                                                        .where((e) =>
                                                            e.date ==
                                                            gameDatesItem)
                                                        .toList();
                                                return ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: games.length,
                                                  itemBuilder:
                                                      (context, gamesIndex) {
                                                    final gamesItem =
                                                        games[gamesIndex];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  20.0,
                                                                  0.0,
                                                                  20.0,
                                                                  20.0),
                                                      child: FutureBuilder<
                                                          List<PlayersRecord>>(
                                                        future:
                                                            queryPlayersRecordOnce(
                                                          parent: gamesItem
                                                              .reference,
                                                          queryBuilder:
                                                              (playersRecord) =>
                                                                  playersRecord.orderBy(
                                                                      'score',
                                                                      descending:
                                                                          true),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    SpinKitFadingFour(
                                                                  color: Color(
                                                                      0xFFE6486F),
                                                                  size: 50.0,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          List<PlayersRecord>
                                                              playersWrapperPlayersRecordList =
                                                              snapshot.data!;
                                                          return Material(
                                                            color: Colors
                                                                .transparent,
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
                                                                    blurRadius:
                                                                        4.0,
                                                                    color: Color(
                                                                        0x00323236),
                                                                    offset:
                                                                        Offset(
                                                                            0.0,
                                                                            2.0),
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
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            8.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child: FutureBuilder<
                                                                            DecksRecord>(
                                                                          future: DecksRecord.getDocumentOnce(playersWrapperPlayersRecordList
                                                                              .first
                                                                              .deckRef!),
                                                                          builder:
                                                                              (context, snapshot) {
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
                                                                            final player1DecksRecord =
                                                                                snapshot.data!;
                                                                            return Container(
                                                                              width: MediaQuery.sizeOf(context).width * 0.4,
                                                                              height: MediaQuery.sizeOf(context).height * 0.2,
                                                                              decoration: BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                                                                    child: AutoSizeText(
                                                                                      player1DecksRecord.name,
                                                                                      maxLines: 1,
                                                                                      style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                            fontFamily: 'Cinzel Decorative',
                                                                                            fontSize: 32.0,
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
                                                                                            playersWrapperPlayersRecordList.first.score.toString(),
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
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            8.0,
                                                                            0.0,
                                                                            8.0,
                                                                            0.0),
                                                                        child: StreamBuilder<
                                                                            DecksRecord>(
                                                                          stream: DecksRecord.getDocument(playersWrapperPlayersRecordList
                                                                              .last
                                                                              .deckRef!),
                                                                          builder:
                                                                              (context, snapshot) {
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
                                                                            final player2DecksRecord =
                                                                                snapshot.data!;
                                                                            return Container(
                                                                              width: MediaQuery.sizeOf(context).width * 0.4,
                                                                              height: MediaQuery.sizeOf(context).height * 0.2,
                                                                              decoration: BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                                                                    child: AutoSizeText(
                                                                                      player2DecksRecord.name,
                                                                                      maxLines: 1,
                                                                                      style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                            fontFamily: 'Cinzel Decorative',
                                                                                            fontSize: 32.0,
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
                                                                                            playersWrapperPlayersRecordList.last.score.toString(),
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
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
