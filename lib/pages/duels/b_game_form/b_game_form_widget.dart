import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/player_form/player_form_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'b_game_form_model.dart';
export 'b_game_form_model.dart';

class BGameFormWidget extends StatefulWidget {
  const BGameFormWidget({Key? key}) : super(key: key);

  @override
  _BGameFormWidgetState createState() => _BGameFormWidgetState();
}

class _BGameFormWidgetState extends State<BGameFormWidget> {
  late BGameFormModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BGameFormModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'B_GameForm'});
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
          List<CrewmatesRecord> bGameFormCrewmatesRecordList = snapshot.data!;
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
                    'o662oct6' /* New Game */,
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        wrapWithModel(
                          model: _model.playerForm1Model,
                          updateCallback: () => setState(() {}),
                          updateOnChange: true,
                          child: PlayerFormWidget(
                            formTitle: FFLocalizations.of(context).getText(
                              '7f8twg17' /* Player 1 */,
                            ),
                            crewmateList: bGameFormCrewmatesRecordList
                                .map((e) => e.name)
                                .toList(),
                            deckNumber: 1,
                            playerNameToRemoveFromList: (String? playerSelect) {
                              return playerSelect == null ? '' : playerSelect;
                            }(_model.playerForm2Model.crewmateSelectModel
                                .playerSelectValue),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 20.0),
                          child: Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: AlignmentDirectional(0.00, 0.00),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 8.0, 0.0, 0.0),
                              child: Text(
                                FFLocalizations.of(context).getText(
                                  'i82gvk1q' /* VS */,
                                ),
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: 'Cinzel Decorative',
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      fontSize: 60.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.playerForm2Model,
                          updateCallback: () => setState(() {}),
                          updateOnChange: true,
                          child: PlayerFormWidget(
                            formTitle: FFLocalizations.of(context).getText(
                              'kasj223y' /* Player 2 */,
                            ),
                            crewmateList: bGameFormCrewmatesRecordList
                                .map((e) => e.name)
                                .toList(),
                            deckNumber: 2,
                            playerNameToRemoveFromList: (String? playerSelect) {
                              return playerSelect == null ? '' : playerSelect;
                            }(_model.playerForm1Model.crewmateSelectModel
                                .playerSelectValue),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.00, 1.00),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 20.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                logFirebaseEvent(
                                    'B_GAME_FORM_PAGE_StartButton_ON_TAP');
                                if (FFAppState().deck1Selected &
                                    FFAppState().deck2Selected) {
                                  // Get all decks
                                  _model.crewDecks = await queryDecksRecordOnce(
                                    queryBuilder: (decksRecord) =>
                                        decksRecord.where(
                                      'crewId',
                                      isEqualTo: valueOrDefault(
                                          currentUserDocument?.crewId, ''),
                                    ),
                                  );
                                  // Save app-wise Deck 1 & 2
                                  setState(() {
                                    FFAppState().currentGameDeckRef1 =
                                        _model.crewDecks
                                            ?.where((e) => valueOrDefault<bool>(
                                                  e.name ==
                                                      _model
                                                          .playerForm1Model
                                                          .deckSelectModel
                                                          .deckSelectValue,
                                                  false,
                                                ))
                                            .toList()
                                            ?.first
                                            ?.reference;
                                    FFAppState().currentGameDeckRef2 =
                                        _model.crewDecks
                                            ?.where((e) => valueOrDefault<bool>(
                                                  e.name ==
                                                      _model
                                                          .playerForm2Model
                                                          .deckSelectModel
                                                          .deckSelectValue,
                                                  false,
                                                ))
                                            .toList()
                                            ?.first
                                            ?.reference;
                                  });

                                  context.pushNamed(
                                    'C_GameView',
                                    queryParameters: {
                                      'isRanked': serializeParam(
                                        true,
                                        ParamType.bool,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  // You need to select both decks
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'You need to select both decks',
                                        style: GoogleFonts.getFont(
                                          'Noto Sans',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryText,
                                    ),
                                  );
                                }

                                setState(() {});
                              },
                              text: FFLocalizations.of(context).getText(
                                'b7er5pp3' /* Start */,
                              ),
                              icon: Icon(
                                FFIcons.kcards,
                                size: 24.0,
                              ),
                              options: FFButtonOptions(
                                width: 280.0,
                                height: 56.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
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
                              ),
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
