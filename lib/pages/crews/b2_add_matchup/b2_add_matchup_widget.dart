import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_count_controller.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/player_form/player_form_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'b2_add_matchup_model.dart';
export 'b2_add_matchup_model.dart';

class B2AddMatchupWidget extends StatefulWidget {
  const B2AddMatchupWidget({
    Key? key,
    String? matchupId,
    String? playerName1,
    String? deckName1,
    String? playerName2,
    String? deckName2,
  })  : this.matchupId = matchupId ?? 'empty',
        this.playerName1 = playerName1 ?? 'empty',
        this.deckName1 = deckName1 ?? 'empty',
        this.playerName2 = playerName2 ?? 'empty',
        this.deckName2 = deckName2 ?? 'empty',
        super(key: key);

  final String matchupId;
  final String playerName1;
  final String deckName1;
  final String playerName2;
  final String deckName2;

  @override
  _B2AddMatchupWidgetState createState() => _B2AddMatchupWidgetState();
}

class _B2AddMatchupWidgetState extends State<B2AddMatchupWidget> {
  late B2AddMatchupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => B2AddMatchupModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'B2_AddMatchup'});
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
      builder: (context) => StreamBuilder<List<CrewmatesRecord>>(
        stream: queryCrewmatesRecord(
          parent: currentUserDocument?.crewRef,
          queryBuilder: (crewmatesRecord) => crewmatesRecord.orderBy('name'),
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
          List<CrewmatesRecord> b2AddMatchupCrewmatesRecordList =
              snapshot.data!;
          return GestureDetector(
            onTap: () => _model.unfocusNode.canRequestFocus
                ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                : FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: true,
                title: Text(
                  FFLocalizations.of(context).getText(
                    'risdwrnn' /* ADD A GAME */,
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
                child: Container(
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 20.0, 0.0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 52.0,
                                  icon: Icon(
                                    FFIcons.knounCalendar466130FFFFFF,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 30.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'B2_ADD_MATCHUP_PAGE_DateButton_ON_TAP');
                                    logFirebaseEvent(
                                        'DateButton_date_time_picker');
                                    final _datePickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: getCurrentTimestamp,
                                      firstDate: DateTime(1900),
                                      lastDate: getCurrentTimestamp,
                                    );

                                    if (_datePickedDate != null) {
                                      safeSetState(() {
                                        _model.datePicked = DateTime(
                                          _datePickedDate.year,
                                          _datePickedDate.month,
                                          _datePickedDate.day,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        wrapWithModel(
                          model: _model.player1Model,
                          updateCallback: () => setState(() {}),
                          updateOnChange: true,
                          child: PlayerFormWidget(
                            formTitle: FFLocalizations.of(context).getText(
                              'd9ayc0tq' /* Player 1 */,
                            ),
                            crewmateList: b2AddMatchupCrewmatesRecordList
                                .map((e) => e.name)
                                .toList(),
                            deckNumber: 1,
                            playerName: widget.playerName1,
                            deckName: widget.deckName1,
                            playerNameToRemoveFromList: (String? playerSelect) {
                              return playerSelect == null ? '' : playerSelect;
                            }(_model.player2Model.crewmateSelectModel
                                .playerSelectValue),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 20.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
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
                              alignment: AlignmentDirectional(1.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'fggxmxjw' /* Score */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Noto Sans',
                                                fontSize: 18.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 0.0, 0.0),
                                    child: Container(
                                      width: 160.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: Colors.transparent,
                                          width: 0.0,
                                        ),
                                      ),
                                      child: FlutterFlowCountController(
                                        decrementIconBuilder: (enabled) =>
                                            FaIcon(
                                          FontAwesomeIcons.minus,
                                          color: enabled
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryText
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          size: 20.0,
                                        ),
                                        incrementIconBuilder: (enabled) =>
                                            FaIcon(
                                          FontAwesomeIcons.plus,
                                          color: enabled
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryText
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          size: 20.0,
                                        ),
                                        countBuilder: (count) => Text(
                                          count.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                        ),
                                        count: _model.player1CountScoreValue ??=
                                            0,
                                        updateCount: (count) => setState(() =>
                                            _model.player1CountScoreValue =
                                                count),
                                        stepSize: 1,
                                        minimum: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: Color(0x34FFFFFF),
                            shape: BoxShape.circle,
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'cavg68at' /* VS */,
                              ),
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    fontFamily: 'Cinzel Decorative',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 42.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.player2Model,
                          updateCallback: () => setState(() {}),
                          updateOnChange: true,
                          child: PlayerFormWidget(
                            formTitle: FFLocalizations.of(context).getText(
                              'ozjsfqhl' /* Player 2 */,
                            ),
                            crewmateList: b2AddMatchupCrewmatesRecordList
                                .map((e) => e.name)
                                .toList(),
                            deckNumber: 2,
                            playerName: widget.playerName2,
                            deckName: widget.deckName2,
                            playerNameToRemoveFromList: (String? playerSelect) {
                              return playerSelect == null ? '' : playerSelect;
                            }(_model.player1Model.crewmateSelectModel
                                .playerSelectValue),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 20.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
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
                              alignment: AlignmentDirectional(1.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'eyh6tn4g' /* Score */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Noto Sans',
                                                fontSize: 18.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 0.0, 0.0),
                                    child: Container(
                                      width: 160.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: Colors.transparent,
                                          width: 0.0,
                                        ),
                                      ),
                                      child: FlutterFlowCountController(
                                        decrementIconBuilder: (enabled) =>
                                            FaIcon(
                                          FontAwesomeIcons.minus,
                                          color: enabled
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryText
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          size: 20.0,
                                        ),
                                        incrementIconBuilder: (enabled) =>
                                            FaIcon(
                                          FontAwesomeIcons.plus,
                                          color: enabled
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryText
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          size: 20.0,
                                        ),
                                        countBuilder: (count) => Text(
                                          count.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                        ),
                                        count: _model.player2CountScoreValue ??=
                                            0,
                                        updateCount: (count) => setState(() =>
                                            _model.player2CountScoreValue =
                                                count),
                                        stepSize: 1,
                                        minimum: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 20.0),
                          child: FFButtonWidget(
                            onPressed: !(FFAppState().deck1Selected &
                                    FFAppState().deck2Selected)
                                ? null
                                : () async {
                                    logFirebaseEvent(
                                        'B2_ADD_MATCHUP_PAGE_SaveButton_ON_TAP');
                                    final firestoreBatch =
                                        FirebaseFirestore.instance.batch();
                                    try {
                                      // Get deck1
                                      logFirebaseEvent('SaveButton_Getdeck1');
                                      _model.deck1 = await queryDecksRecordOnce(
                                        queryBuilder: (decksRecord) =>
                                            decksRecord
                                                .where(
                                                  'crewId',
                                                  isEqualTo: valueOrDefault(
                                                      currentUserDocument
                                                          ?.crewId,
                                                      ''),
                                                )
                                                .where(
                                                  'name',
                                                  isEqualTo: _model
                                                      .player1Model
                                                      .deckSelectModel
                                                      .deckSelectValue,
                                                ),
                                        singleRecord: true,
                                      ).then((s) => s.firstOrNull);
                                      // Get deck2
                                      logFirebaseEvent('SaveButton_Getdeck2');
                                      _model.deck2 = await queryDecksRecordOnce(
                                        queryBuilder: (decksRecord) =>
                                            decksRecord
                                                .where(
                                                  'crewId',
                                                  isEqualTo: valueOrDefault(
                                                      currentUserDocument
                                                          ?.crewId,
                                                      ''),
                                                )
                                                .where(
                                                  'name',
                                                  isEqualTo: _model
                                                      .player2Model
                                                      .deckSelectModel
                                                      .deckSelectValue,
                                                ),
                                        singleRecord: true,
                                      ).then((s) => s.firstOrNull);
                                      // Create a MatchupId
                                      logFirebaseEvent(
                                          'SaveButton_CreateaMatchupId');
                                      _model.matchupId =
                                          await actions.createsMatchupid(
                                        _model.deck1!.reference.id,
                                        _model.deck2!.reference.id,
                                      );
                                      // Check if new today game
                                      logFirebaseEvent(
                                          'SaveButton_Checkifnewtodaygame');
                                      _model.hasDateGame = await actions
                                          .checkIfDateMatchupGameExists(
                                        _model.matchupId!,
                                        _model.datePicked?.toString() == null
                                            ? functions.getTodayDate()
                                            : _model.datePicked!,
                                      );
                                      if (_model.hasDateGame!) {
                                        // Get existing game
                                        logFirebaseEvent(
                                            'SaveButton_Getexistinggame');
                                        _model.dateGame =
                                            await queryGamesRecordOnce(
                                          queryBuilder: (gamesRecord) =>
                                              gamesRecord
                                                  .where(
                                                    'matchupId',
                                                    isEqualTo: _model.matchupId,
                                                  )
                                                  .where(
                                                    'date',
                                                    isGreaterThanOrEqualTo: _model
                                                                .datePicked
                                                                ?.toString() ==
                                                            null
                                                        ? functions
                                                            .getTodayDate()
                                                        : _model.datePicked,
                                                  )
                                                  .where(
                                                    'date',
                                                    isLessThan: functions
                                                        .getDayAfterDate(_model
                                                                    .datePicked
                                                                    ?.toString() ==
                                                                null
                                                            ? functions
                                                                .getTodayDate()
                                                            : _model
                                                                .datePicked!),
                                                  ),
                                          singleRecord: true,
                                        ).then((s) => s.firstOrNull);
                                        // Get game Players
                                        logFirebaseEvent(
                                            'SaveButton_GetgamePlayers');
                                        _model.dateGamePlayers =
                                            await queryPlayersRecordOnce(
                                          parent: _model.dateGame?.reference,
                                        );
                                        // Update Player1's Score
                                        logFirebaseEvent(
                                            'SaveButton_UpdatePlayer1\'sScore');

                                        firestoreBatch.update(
                                            _model.dateGamePlayers!
                                                .where((e) =>
                                                    e.deckName ==
                                                    _model
                                                        .player1Model
                                                        .deckSelectModel
                                                        .deckSelectValue)
                                                .toList()
                                                .first
                                                .reference,
                                            {
                                              ...mapToFirestore(
                                                {
                                                  'score': FieldValue.increment(
                                                      _model
                                                          .player1CountScoreValue!),
                                                },
                                              ),
                                            });
                                        // Update Player2's Score
                                        logFirebaseEvent(
                                            'SaveButton_UpdatePlayer2\'sScore');

                                        firestoreBatch.update(
                                            _model.dateGamePlayers!
                                                .where((e) =>
                                                    e.deckName ==
                                                    _model
                                                        .player2Model
                                                        .deckSelectModel
                                                        .deckSelectValue)
                                                .toList()
                                                .first
                                                .reference,
                                            {
                                              ...mapToFirestore(
                                                {
                                                  'score': FieldValue.increment(
                                                      _model
                                                          .player2CountScoreValue!),
                                                },
                                              ),
                                            });
                                        // Get related Matchup
                                        logFirebaseEvent(
                                            'SaveButton_GetrelatedMatchup');
                                        _model.matchupDocExistingGame =
                                            await queryMatchupsRecordOnce(
                                          queryBuilder: (matchupsRecord) =>
                                              matchupsRecord.where(
                                            'matchupId',
                                            isEqualTo: _model.matchupId,
                                          ),
                                          singleRecord: true,
                                        ).then((s) => s.firstOrNull);
                                        // Calculate matchup Score
                                        logFirebaseEvent(
                                            'SaveButton_CalculatematchupScore');
                                        _model.updatedMatchupScoreExistingGame =
                                            await actions.updateScores(
                                          _model.deck1!.deckId,
                                          _model.player1CountScoreValue!,
                                          _model.deck2!.deckId,
                                          _model.player2CountScoreValue!,
                                          _model.matchupDocExistingGame!.scores
                                              .toList(),
                                        );
                                        // Update Matchup score
                                        // Update matchup Score
                                        logFirebaseEvent(
                                            'SaveButton_UpdatematchupScore');

                                        firestoreBatch.update(
                                            _model.matchupDocExistingGame!
                                                .reference,
                                            {
                                              ...mapToFirestore(
                                                {
                                                  'scores':
                                                      getScoreListFirestoreData(
                                                    _model
                                                        .updatedMatchupScoreExistingGame,
                                                  ),
                                                },
                                              ),
                                            });
                                        // Clear form values
                                        logFirebaseEvent(
                                            'SaveButton_Clearformvalues');
                                        setState(() {
                                          FFAppState().deck1Selected = false;
                                          FFAppState().deck2Selected = false;
                                        });
                                        // Game updated!
                                        logFirebaseEvent(
                                            'SaveButton_Gameupdated!');
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              valueOrDefault<String>(
                                                (String appLanguage) {
                                                  return appLanguage == 'fr'
                                                      ? 'Partie mise à jour !'
                                                      : 'Game updated!';
                                                }(FFLocalizations.of(context)
                                                    .languageCode),
                                                'Game updated!',
                                              ),
                                              style: GoogleFonts.getFont(
                                                'Noto Sans',
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                      } else {
                                        // Create new Game
                                        logFirebaseEvent(
                                            'SaveButton_CreatenewGame');

                                        var gamesRecordReference =
                                            GamesRecord.collection.doc();
                                        firestoreBatch
                                            .set(gamesRecordReference, {
                                          ...createGamesRecordData(
                                            date:
                                                _model.datePicked?.toString() ==
                                                        null
                                                    ? getCurrentTimestamp
                                                    : _model.datePicked,
                                            crewId: valueOrDefault(
                                                currentUserDocument?.crewId,
                                                ''),
                                          ),
                                          ...mapToFirestore(
                                            {
                                              'deckIds': (String deckId1,
                                                      String deckId2) {
                                                return [deckId1, deckId2];
                                              }(_model.deck1!.deckId,
                                                  _model.deck2!.deckId),
                                            },
                                          ),
                                        });
                                        _model.newGameDoc =
                                            GamesRecord.getDocumentFromData({
                                          ...createGamesRecordData(
                                            date:
                                                _model.datePicked?.toString() ==
                                                        null
                                                    ? getCurrentTimestamp
                                                    : _model.datePicked,
                                            crewId: valueOrDefault(
                                                currentUserDocument?.crewId,
                                                ''),
                                          ),
                                          ...mapToFirestore(
                                            {
                                              'deckIds': (String deckId1,
                                                      String deckId2) {
                                                return [deckId1, deckId2];
                                              }(_model.deck1!.deckId,
                                                  _model.deck2!.deckId),
                                            },
                                          ),
                                        }, gamesRecordReference);
                                        // Create Player1
                                        logFirebaseEvent(
                                            'SaveButton_CreatePlayer1');

                                        var playersRecordReference1 =
                                            PlayersRecord.createDoc(
                                                _model.newGameDoc!.reference);
                                        firestoreBatch.set(
                                            playersRecordReference1,
                                            createPlayersRecordData(
                                              score:
                                                  _model.player1CountScoreValue,
                                              deckName: _model
                                                  .player1Model
                                                  .deckSelectModel
                                                  .deckSelectValue,
                                              deckId: _model.deck1?.deckId,
                                              crewmateId:
                                                  _model.deck1?.crewmateId,
                                              crewId: _model.deck1?.crewId,
                                              deckRef:
                                                  functions.fromDeckIdToRef(
                                                      _model.deck1!.deckId),
                                              crewmateRef:
                                                  functions.fromCrewmateIdToRef(
                                                      _model.deck1!.crewmateId,
                                                      _model.deck1!.crewId),
                                            ));
                                        _model.player1Doc =
                                            PlayersRecord.getDocumentFromData(
                                                createPlayersRecordData(
                                                  score: _model
                                                      .player1CountScoreValue,
                                                  deckName: _model
                                                      .player1Model
                                                      .deckSelectModel
                                                      .deckSelectValue,
                                                  deckId: _model.deck1?.deckId,
                                                  crewmateId:
                                                      _model.deck1?.crewmateId,
                                                  crewId: _model.deck1?.crewId,
                                                  deckRef:
                                                      functions.fromDeckIdToRef(
                                                          _model.deck1!.deckId),
                                                  crewmateRef: functions
                                                      .fromCrewmateIdToRef(
                                                          _model.deck1!
                                                              .crewmateId,
                                                          _model.deck1!.crewId),
                                                ),
                                                playersRecordReference1);
                                        // Create Player2
                                        logFirebaseEvent(
                                            'SaveButton_CreatePlayer2');

                                        var playersRecordReference2 =
                                            PlayersRecord.createDoc(
                                                _model.newGameDoc!.reference);
                                        firestoreBatch.set(
                                            playersRecordReference2,
                                            createPlayersRecordData(
                                              score:
                                                  _model.player2CountScoreValue,
                                              deckName: _model
                                                  .player2Model
                                                  .deckSelectModel
                                                  .deckSelectValue,
                                              deckId: _model.deck2?.deckId,
                                              crewmateId:
                                                  _model.deck2?.crewmateId,
                                              crewId: _model.deck2?.crewId,
                                              deckRef:
                                                  functions.fromDeckIdToRef(
                                                      _model.deck2!.deckId),
                                              crewmateRef:
                                                  functions.fromCrewmateIdToRef(
                                                      _model.deck2!.crewmateId,
                                                      _model.deck2!.crewId),
                                            ));
                                        _model.player2Doc =
                                            PlayersRecord.getDocumentFromData(
                                                createPlayersRecordData(
                                                  score: _model
                                                      .player2CountScoreValue,
                                                  deckName: _model
                                                      .player2Model
                                                      .deckSelectModel
                                                      .deckSelectValue,
                                                  deckId: _model.deck2?.deckId,
                                                  crewmateId:
                                                      _model.deck2?.crewmateId,
                                                  crewId: _model.deck2?.crewId,
                                                  deckRef:
                                                      functions.fromDeckIdToRef(
                                                          _model.deck2!.deckId),
                                                  crewmateRef: functions
                                                      .fromCrewmateIdToRef(
                                                          _model.deck2!
                                                              .crewmateId,
                                                          _model.deck2!.crewId),
                                                ),
                                                playersRecordReference2);
                                        // Check if Matchup exists
                                        logFirebaseEvent(
                                            'SaveButton_CheckifMatchupexists');
                                        _model.hasMatchup =
                                            await actions.checkIfMatchupExists(
                                          _model.matchupId!,
                                        );
                                        if (_model.hasMatchup!) {
                                          // Get existing Matchup
                                          logFirebaseEvent(
                                              'SaveButton_GetexistingMatchup');
                                          _model.matchupDocNewGame =
                                              await queryMatchupsRecordOnce(
                                            queryBuilder: (matchupsRecord) =>
                                                matchupsRecord.where(
                                              'matchupId',
                                              isEqualTo: _model.matchupId,
                                            ),
                                            singleRecord: true,
                                          ).then((s) => s.firstOrNull);
                                          // Calculate matchup Score
                                          logFirebaseEvent(
                                              'SaveButton_CalculatematchupScore');
                                          _model.updatedMatchupScoreNewGame =
                                              await actions.updateScores(
                                            _model.deck1!.deckId,
                                            _model.player1CountScoreValue!,
                                            _model.deck2!.deckId,
                                            _model.player2CountScoreValue!,
                                            _model.matchupDocNewGame!.scores
                                                .toList(),
                                          );
                                          // Update Matchup score
                                          // Update matchup Score
                                          logFirebaseEvent(
                                              'SaveButton_UpdatematchupScore');

                                          firestoreBatch.update(
                                              _model
                                                  .matchupDocNewGame!.reference,
                                              {
                                                ...mapToFirestore(
                                                  {
                                                    'scores':
                                                        getScoreListFirestoreData(
                                                      _model
                                                          .updatedMatchupScoreNewGame,
                                                    ),
                                                  },
                                                ),
                                              });
                                        } else {
                                          // Calculate matchup Score
                                          logFirebaseEvent(
                                              'SaveButton_CalculatematchupScore');
                                          _model.newMatchupScore =
                                              await actions.createScores(
                                            _model.deck1!.deckId,
                                            _model.player1CountScoreValue!,
                                            _model.deck2!.deckId,
                                            _model.player2CountScoreValue!,
                                          );
                                          // Create Matchup
                                          logFirebaseEvent(
                                              'SaveButton_CreateMatchup');

                                          var matchupsRecordReference =
                                              MatchupsRecord.collection.doc();
                                          firestoreBatch
                                              .set(matchupsRecordReference, {
                                            ...createMatchupsRecordData(
                                              matchupId: _model.matchupId,
                                              crewId: valueOrDefault(
                                                  currentUserDocument?.crewId,
                                                  ''),
                                            ),
                                            ...mapToFirestore(
                                              {
                                                'gameIds': [
                                                  _model
                                                      .newGameDoc?.reference.id
                                                ],
                                                'deckIds': (String deckId1,
                                                        String deckId2) {
                                                  return [deckId1, deckId2];
                                                }(_model.deck1!.deckId,
                                                    _model.deck2!.deckId),
                                                'scores':
                                                    getScoreListFirestoreData(
                                                  _model.newMatchupScore,
                                                ),
                                              },
                                            ),
                                          });
                                          _model.newMatchupDoc = MatchupsRecord
                                              .getDocumentFromData({
                                            ...createMatchupsRecordData(
                                              matchupId: _model.matchupId,
                                              crewId: valueOrDefault(
                                                  currentUserDocument?.crewId,
                                                  ''),
                                            ),
                                            ...mapToFirestore(
                                              {
                                                'gameIds': [
                                                  _model
                                                      .newGameDoc?.reference.id
                                                ],
                                                'deckIds': (String deckId1,
                                                        String deckId2) {
                                                  return [deckId1, deckId2];
                                                }(_model.deck1!.deckId,
                                                    _model.deck2!.deckId),
                                                'scores':
                                                    getScoreListFirestoreData(
                                                  _model.newMatchupScore,
                                                ),
                                              },
                                            ),
                                          }, matchupsRecordReference);
                                        }

                                        // Clear form values
                                        logFirebaseEvent(
                                            'SaveButton_Clearformvalues');
                                        setState(() {
                                          FFAppState().deck1Selected = false;
                                          FFAppState().deck2Selected = false;
                                        });
                                        // Game saved!
                                        logFirebaseEvent(
                                            'SaveButton_Gamesaved!');
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              valueOrDefault<String>(
                                                (String appLanguage) {
                                                  return appLanguage == 'fr'
                                                      ? 'Partie sauvegardée !'
                                                      : 'Game saved!';
                                                }(FFLocalizations.of(context)
                                                    .languageCode),
                                                'Game saved!',
                                              ),
                                              style: GoogleFonts.getFont(
                                                'Noto Sans',
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                      }

                                      // Leave form
                                      logFirebaseEvent('SaveButton_Leaveform');
                                      context.safePop();
                                      // Rebuild page
                                      logFirebaseEvent(
                                          'SaveButton_Rebuildpage');
                                      FFAppState().update(() {});
                                    } finally {
                                      await firestoreBatch.commit();
                                    }

                                    setState(() {});
                                  },
                            text: FFLocalizations.of(context).getText(
                              '1r82hx9g' /* Save */,
                            ),
                            icon: Icon(
                              Icons.save,
                              size: 24.0,
                            ),
                            options: FFButtonOptions(
                              width: 280.0,
                              height: 56.0,
                              padding: EdgeInsets.all(0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 8.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle:
                                  FlutterFlowTheme.of(context).titleLarge,
                              elevation: 3.0,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                              disabledTextColor: Color(0x4EF1F4F8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
