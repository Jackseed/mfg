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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'c2_game_list_model.dart';
export 'c2_game_list_model.dart';

class C2GameListWidget extends StatefulWidget {
  const C2GameListWidget({
    Key? key,
    required this.filteredDeckList,
    required this.deckId,
  }) : super(key: key);

  final List<String>? filteredDeckList;
  final String? deckId;

  @override
  _C2GameListWidgetState createState() => _C2GameListWidgetState();
}

class _C2GameListWidgetState extends State<C2GameListWidget> {
  late C2GameListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => C2GameListModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'C2_GameList'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('C2_GAME_LIST_C2_GameList_ON_INIT_STATE');
      // Get deck
      logFirebaseEvent('C2_GameList_Getdeck');
      _model.deck = await queryDecksRecordOnce(
        queryBuilder: (decksRecord) => decksRecord.where(
          'deckId',
          isEqualTo: widget.deckId,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      // Get crewmate owner
      logFirebaseEvent('C2_GameList_Getcrewmateowner');
      _model.crewmateOwner =
          await CrewmatesRecord.getDocumentOnce(_model.deck!.crewmateRef!);
      // Set filter as closed
      logFirebaseEvent('C2_GameList_Setfilterasclosed');
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
          List<DecksRecord> c2GameListDecksRecordList = snapshot.data!;
          return GestureDetector(
            onTap: () => _model.unfocusNode.canRequestFocus
                ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                : FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  logFirebaseEvent('C2_GAME_LIST_FloatingActionButton_0o5bg5');
                  logFirebaseEvent('FloatingActionButton_navigate_to');

                  context.pushNamed(
                    'B2_AddMatchup',
                    queryParameters: {
                      'playerName1': serializeParam(
                        _model.crewmateOwner?.name,
                        ParamType.String,
                      ),
                      'deckName1': serializeParam(
                        _model.deck?.name,
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
                    '14kzysds' /* Add match */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: true,
                title: Text(
                  valueOrDefault<String>(
                    _model.deck?.name,
                    'Matchs',
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
                child: Stack(
                  children: [
                    StreamBuilder<List<GamesRecord>>(
                      stream: queryGamesRecord(
                        queryBuilder: (gamesRecord) => gamesRecord
                            .where(
                              'crewId',
                              isEqualTo: valueOrDefault(
                                          currentUserDocument?.crewId, '') !=
                                      ''
                                  ? valueOrDefault(
                                      currentUserDocument?.crewId, '')
                                  : null,
                            )
                            .where(
                              'deckIds',
                              arrayContains:
                                  widget.deckId != '' ? widget.deckId : null,
                            )
                            .orderBy('date', descending: true),
                      ),
                      builder: (context, snapshot) {
                        // Customize what your widget looks like when it's loading.
                        if (!snapshot.hasData) {
                          return Center(
                            child: SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: SpinKitFoldingCube(
                                color: FlutterFlowTheme.of(context).primary,
                                size: 40.0,
                              ),
                            ),
                          );
                        }
                        List<GamesRecord> gameListGamesRecordList =
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
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 60.0, 0.0, 20.0),
                            child: Builder(
                              builder: (context) {
                                final gameDates = gameListGamesRecordList
                                    .where((e) => (String opponentDeckId,
                                                List<String> filteredDeckIds) {
                                          return (filteredDeckIds.length == 0
                                              ? true
                                              : (filteredDeckIds
                                                          .where((id) =>
                                                              id ==
                                                              opponentDeckId)
                                                          .toList()
                                                          .length >
                                                      0
                                                  ? true
                                                  : false));
                                        }(
                                            ((String deckId,
                                                    List<String> gameDeckIds) {
                                              return gameDeckIds
                                                  .where((id) => id != deckId)
                                                  .toList()[0];
                                            }(widget.deckId!,
                                                e.deckIds.toList())),
                                            functions
                                                .fromDeckNamesToIds(
                                                    _model.checkboxGroupValues
                                                        ?.toList(),
                                                    c2GameListDecksRecordList
                                                        .toList())
                                                .toList()))
                                    .toList()
                                    .map((e) => e.date)
                                    .withoutNulls
                                    .toList();
                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: gameDates.length,
                                  itemBuilder: (context, gameDatesIndex) {
                                    final gameDatesItem =
                                        gameDates[gameDatesIndex];
                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 20.0, 0.0, 0.0),
                                          child: Text(
                                            dateTimeFormat(
                                              'MMMMEEEEd',
                                              gameDatesItem,
                                              locale:
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            ),
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .headlineSmall
                                                .override(
                                                  fontFamily:
                                                      'Cinzel Decorative',
                                                  color: FlutterFlowTheme.of(
                                                          context)
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
                                                          (String opponentDeckId,
                                                                  List<String>
                                                                      filteredDeckIds,
                                                                  String
                                                                      gameDate,
                                                                  String
                                                                      listDate) {
                                                            return (filteredDeckIds
                                                                            .length ==
                                                                        0
                                                                    ? true
                                                                    : (filteredDeckIds.where((id) => id == opponentDeckId).toList().length >
                                                                            0
                                                                        ? true
                                                                        : false)) &&
                                                                (gameDate ==
                                                                    listDate);
                                                          }(
                                                              ((String deckId,
                                                                      List<String>
                                                                          gameDeckIds) {
                                                                return gameDeckIds
                                                                    .where((id) =>
                                                                        id !=
                                                                        deckId)
                                                                    .toList()[0];
                                                              }(
                                                                  widget
                                                                      .deckId!,
                                                                  e.deckIds
                                                                      .toList())),
                                                              functions
                                                                  .fromDeckNamesToIds(
                                                                      _model
                                                                          .checkboxGroupValues
                                                                          ?.toList(),
                                                                      c2GameListDecksRecordList
                                                                          .toList())
                                                                  .toList(),
                                                              e.date!
                                                                  .toString(),
                                                              gameDatesItem
                                                                  .toString()))
                                                      .toList();
                                              return ListView.builder(
                                                padding: EdgeInsets.zero,
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: games.length,
                                                itemBuilder:
                                                    (context, gamesIndex) {
                                                  final gamesItem =
                                                      games[gamesIndex];
                                                  return Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 8.0),
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
                                                                              constraints: BoxConstraints(
                                                                                maxHeight: 130.0,
                                                                              ),
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
                                                                        child: FutureBuilder<
                                                                            DecksRecord>(
                                                                          future: DecksRecord.getDocumentOnce(playersWrapperPlayersRecordList
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
                                                                              constraints: BoxConstraints(
                                                                                maxHeight: 130.0,
                                                                              ),
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
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FFButtonWidget(
                              onPressed: () async {
                                logFirebaseEvent(
                                    'C2_GAME_LIST_PAGE_DECKS_BTN_ON_TAP');
                                logFirebaseEvent('Button_update_page_state');
                                setState(() {
                                  _model.isDeckFilterOpen =
                                      valueOrDefault<bool>(
                                    !_model.isDeckFilterOpen,
                                    false,
                                  );
                                });
                              },
                              text: FFLocalizations.of(context).getText(
                                'iw7cix4e' /* Decks */,
                              ),
                              icon: Icon(
                                Icons.filter_list,
                                size: 15.0,
                              ),
                              options: FFButtonOptions(
                                width: 150.0,
                                height: 50.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: Color(0xFF645D5D),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Cinzel Decorative',
                                      color: Colors.white,
                                      fontSize: 18.0,
                                    ),
                                elevation: 3.0,
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            if (_model.isDeckFilterOpen)
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF645D5D),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      FlutterFlowCheckboxGroup(
                                        options: c2GameListDecksRecordList
                                            .map((e) => valueOrDefault<String>(
                                                  e.name,
                                                  '--',
                                                ))
                                            .toList(),
                                        onChanged: (val) => setState(() =>
                                            _model.checkboxGroupValues = val),
                                        controller: _model
                                                .checkboxGroupValueController ??=
                                            FormFieldController<List<String>>(
                                          [],
                                        ),
                                        activeColor:
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                        checkColor: FlutterFlowTheme.of(context)
                                            .primary,
                                        checkboxBorderColor:
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              fontSize: 18.0,
                                            ),
                                        checkboxBorderRadius:
                                            BorderRadius.circular(4.0),
                                        initialized:
                                            _model.checkboxGroupValues != null,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
