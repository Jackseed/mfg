import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_rive_controller.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'c_game_view_model.dart';
export 'c_game_view_model.dart';

class CGameViewWidget extends StatefulWidget {
  const CGameViewWidget({
    Key? key,
    required this.isRanked,
  }) : super(key: key);

  final bool? isRanked;

  @override
  _CGameViewWidgetState createState() => _CGameViewWidgetState();
}

class _CGameViewWidgetState extends State<CGameViewWidget>
    with TickerProviderStateMixin {
  late CGameViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasRowTriggered1 = false;
  var hasRowTriggered2 = false;
  final animationsMap = {
    'rowOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      applyInitialState: false,
      effects: [
        VisibilityEffect(duration: 1.ms),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(-100.0, 0.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
    'rowOnActionTriggerAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onActionTrigger,
      applyInitialState: false,
      effects: [
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(-100.0, 0.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
    'rowOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      applyInitialState: false,
      effects: [
        VisibilityEffect(duration: 1.ms),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(-100.0, 0.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
    'rowOnActionTriggerAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onActionTrigger,
      applyInitialState: false,
      effects: [
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(-100.0, 0.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CGameViewModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'C_GameView'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('C_GAME_VIEW_C_GameView_ON_INIT_STATE');
      if (widget.isRanked!) {
        // Get Deck1
        logFirebaseEvent('C_GameView_GetDeck1');
        _model.deck1 = await queryDecksRecordOnce(
          queryBuilder: (decksRecord) => decksRecord.where(
            'deckId',
            isEqualTo: FFAppState().currentGameDeckRef1?.id,
          ),
          singleRecord: true,
        ).then((s) => s.firstOrNull);
        // Get Deck2
        logFirebaseEvent('C_GameView_GetDeck2');
        _model.deck2 = await queryDecksRecordOnce(
          queryBuilder: (decksRecord) => decksRecord.where(
            'deckId',
            isEqualTo: FFAppState().currentGameDeckRef2?.id,
          ),
          singleRecord: true,
        ).then((s) => s.firstOrNull);
        // Rebuild Component
        logFirebaseEvent('C_GameView_RebuildComponent');
        setState(() {});
      } else {
        // Query all Avatars
        logFirebaseEvent('C_GameView_QueryallAvatars');
        _model.images = await queryImagesRecordOnce(
          queryBuilder: (imagesRecord) => imagesRecord.where(
            'type',
            isEqualTo: 'avatar',
          ),
        );
        // Randomize Avatars 1 & 2
        logFirebaseEvent('C_GameView_RandomizeAvatars1&2');
        _model.randomAvatar1 = valueOrDefault<int>(
          random_data.randomInteger(
              0,
              _model.images!.where((e) => e.type == 'avatar').toList().length -
                  1),
          0,
        );
        _model.randomAvatar2 = valueOrDefault<int>(
          random_data.randomInteger(
              0,
              _model.images!.where((e) => e.type == 'avatar').toList().length -
                  1),
          0,
        );
        // Ensure different avatars
        logFirebaseEvent('C_GameView_Ensuredifferentavatars');
        _model.randomAvatar1 = valueOrDefault<int>(
          (int randomAvatar1, int randomAvatar2) {
            return randomAvatar1 == randomAvatar2
                ? (randomAvatar1 == 0)
                    ? 1
                    : 0
                : randomAvatar1;
          }(_model.randomAvatar1, _model.randomAvatar2),
          0,
        );
        // Set avatar values
        logFirebaseEvent('C_GameView_Setavatarvalues');
        setState(() {
          _model.avatar1 =
              _model.images![_model.randomAvatar1].image.first.downloadURL;
          _model.avatar2 =
              _model.images![_model.randomAvatar2].image.first.downloadURL;
        });
      }
    });

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      animationsMap['rowOnPageLoadAnimation1']!.controller.forward(from: 0.0);
      animationsMap['rowOnPageLoadAnimation2']!.controller.forward(from: 0.0);
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
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Transform.rotate(
                angle: 3.1416,
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.network(
                        valueOrDefault<String>(
                          widget.isRanked!
                              ? valueOrDefault<String>(
                                  _model.deck1?.avatarUrl,
                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/magic-6zjv9f/assets/9e5l347v0vwn/output-onlinegiftools.gif',
                                )
                              : _model.avatar1,
                          'https://cards.scryfall.io/art_crop/front/8/3/833936c6-9381-4c0b-a81c-4a938be95040.jpg?1686968640',
                        ),
                      ).image,
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFFCA5052), Colors.white],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.34, -1.0),
                      end: AlignmentDirectional(-0.34, 1.0),
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                    shape: BoxShape.rectangle,
                  ),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    child: Stack(
                      children: [
                        if (_model.isPlayer1Victorious)
                          Align(
                            alignment: AlignmentDirectional(1.0, 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 0.5,
                              child: RiveAnimation.asset(
                                'assets/rive_animations/confetti_mobile_(1).riv',
                                artboard: 'Confetti.svg',
                                fit: BoxFit.fill,
                                controllers: _model.confettiPlayer1Controllers,
                              ),
                            ),
                          ),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          decoration: BoxDecoration(
                            color: Color(0x33323236),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    if (_model.isCounter1)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 0.0),
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            logFirebaseEvent(
                                                                'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                            logFirebaseEvent(
                                                                'Button_update_page_state');
                                                            setState(() {
                                                              _model.counter1 =
                                                                  _model.counter1 +
                                                                      -1;
                                                              _model.deltaCounter1 =
                                                                  _model.deltaCounter1 +
                                                                      -1;
                                                            });
                                                            if (!_model
                                                                .isTimerCounter1Set) {
                                                              logFirebaseEvent(
                                                                  'Button_update_page_state');
                                                              setState(() {
                                                                _model.isTimerCounter1Set =
                                                                    true;
                                                              });
                                                              logFirebaseEvent(
                                                                  'Button_start_periodic_action');
                                                              _model.minusTimerCounter1 =
                                                                  InstantTimer
                                                                      .periodic(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        3000),
                                                                callback:
                                                                    (timer) async {
                                                                  logFirebaseEvent(
                                                                      'Button_update_page_state');
                                                                  setState(() {
                                                                    _model.deltaCounter1 =
                                                                        0;
                                                                    _model.isTimerCounter1Set =
                                                                        false;
                                                                  });
                                                                  logFirebaseEvent(
                                                                      'Button_stop_periodic_action');
                                                                  _model
                                                                      .minusTimerCounter1
                                                                      ?.cancel();
                                                                },
                                                                startImmediately:
                                                                    false,
                                                              );
                                                            }
                                                          },
                                                          text: '',
                                                          icon: Icon(
                                                            Icons
                                                                .remove_rounded,
                                                            size: 70.0,
                                                          ),
                                                          options:
                                                              FFButtonOptions(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: Colors
                                                                .transparent,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Cinzel Decorative',
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: AutoSizeText(
                                                          _model.counter1
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Noto Sans',
                                                                fontSize: 120.0,
                                                                letterSpacing:
                                                                    5.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            logFirebaseEvent(
                                                                'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                            logFirebaseEvent(
                                                                'Button_update_page_state');
                                                            setState(() {
                                                              _model.counter1 =
                                                                  _model.counter1 +
                                                                      1;
                                                              _model.deltaCounter1 =
                                                                  _model.deltaCounter1 +
                                                                      1;
                                                            });
                                                            if (!_model
                                                                .isTimerCounter1Set) {
                                                              logFirebaseEvent(
                                                                  'Button_update_page_state');
                                                              setState(() {
                                                                _model.isTimerCounter1Set =
                                                                    true;
                                                              });
                                                              logFirebaseEvent(
                                                                  'Button_start_periodic_action');
                                                              _model.plusTimerCounter1 =
                                                                  InstantTimer
                                                                      .periodic(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        3000),
                                                                callback:
                                                                    (timer) async {
                                                                  logFirebaseEvent(
                                                                      'Button_update_page_state');
                                                                  setState(() {
                                                                    _model.deltaCounter1 =
                                                                        0;
                                                                    _model.isTimerCounter1Set =
                                                                        false;
                                                                  });
                                                                  logFirebaseEvent(
                                                                      'Button_stop_periodic_action');
                                                                  _model
                                                                      .plusTimerCounter1
                                                                      ?.cancel();
                                                                },
                                                                startImmediately:
                                                                    false,
                                                              );
                                                            }
                                                          },
                                                          text: '',
                                                          icon: Icon(
                                                            Icons.add_rounded,
                                                            size: 70.0,
                                                          ),
                                                          options:
                                                              FFButtonOptions(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: Colors
                                                                .transparent,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Cinzel Decorative',
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          showLoadingIndicator:
                                                              false,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_model.isTimerCounter1Set)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0.0,
                                                                140.0,
                                                                0.0,
                                                                0.0),
                                                    child: Text(
                                                      (int delta) {
                                                        return delta > 0
                                                            ? '+ $delta'
                                                            : '$delta';
                                                      }(_model.deltaCounter1),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Noto Sans',
                                                            fontSize: 30.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              if (!_model.isTimerCounter1Set)
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 140.0, 0.0, 0.0),
                                                  child: Icon(
                                                    Icons.onetwothree,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 30.0,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (!_model.isCounter1)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 0.0),
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            logFirebaseEvent(
                                                                'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                            logFirebaseEvent(
                                                                'Button_update_page_state');
                                                            setState(() {
                                                              _model.startTime1 =
                                                                  getCurrentTimestamp;
                                                              _model.lifeCounter1 =
                                                                  _model.lifeCounter1 +
                                                                      -1;
                                                              _model.lifeCounterDelta1 =
                                                                  _model.lifeCounterDelta1 +
                                                                      -1;
                                                            });
                                                            if (_model
                                                                    .lifeCounterDelta1 ==
                                                                -1) {
                                                              while (_model
                                                                      .startTime1
                                                                      ?.millisecondsSinceEpoch !=
                                                                  null) {
                                                                logFirebaseEvent(
                                                                    'Button_wait__delay');
                                                                await Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            1000));
                                                                if (_model.startTime1!
                                                                            .millisecondsSinceEpoch +
                                                                        _model
                                                                            .showDeltaPeriod <=
                                                                    getCurrentTimestamp
                                                                        .millisecondsSinceEpoch) {
                                                                  // startTime = null & delta = 0
                                                                  logFirebaseEvent(
                                                                      'Button_startTime=null&delta=0');
                                                                  setState(() {
                                                                    _model.startTime1 =
                                                                        null;
                                                                    _model.lifeCounterDelta1 =
                                                                        0;
                                                                  });
                                                                  break;
                                                                }
                                                              }
                                                            }
                                                          },
                                                          text: '',
                                                          icon: Icon(
                                                            Icons
                                                                .remove_rounded,
                                                            size: 70.0,
                                                          ),
                                                          options:
                                                              FFButtonOptions(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: Colors
                                                                .transparent,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Cinzel Decorative',
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          showLoadingIndicator:
                                                              false,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: AutoSizeText(
                                                          _model.lifeCounter1
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Noto Sans',
                                                                fontSize: 120.0,
                                                                letterSpacing:
                                                                    5.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            logFirebaseEvent(
                                                                'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                            logFirebaseEvent(
                                                                'Button_update_page_state');
                                                            setState(() {
                                                              _model.startTime1 =
                                                                  getCurrentTimestamp;
                                                              _model.lifeCounter1 =
                                                                  _model.lifeCounter1 +
                                                                      1;
                                                              _model.lifeCounterDelta1 =
                                                                  _model.lifeCounterDelta1 +
                                                                      1;
                                                            });
                                                            if (_model
                                                                    .lifeCounterDelta1 ==
                                                                1) {
                                                              while (_model
                                                                      .startTime1
                                                                      ?.millisecondsSinceEpoch !=
                                                                  null) {
                                                                logFirebaseEvent(
                                                                    'Button_wait__delay');
                                                                await Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            1000));
                                                                if (_model.startTime1!
                                                                            .millisecondsSinceEpoch +
                                                                        _model
                                                                            .showDeltaPeriod <=
                                                                    getCurrentTimestamp
                                                                        .millisecondsSinceEpoch) {
                                                                  // startTime = null & delta = 0
                                                                  logFirebaseEvent(
                                                                      'Button_startTime=null&delta=0');
                                                                  setState(() {
                                                                    _model.startTime1 =
                                                                        null;
                                                                    _model.lifeCounterDelta1 =
                                                                        0;
                                                                  });
                                                                  break;
                                                                }
                                                              }
                                                            }
                                                          },
                                                          text: '',
                                                          icon: Icon(
                                                            Icons.add_rounded,
                                                            size: 70.0,
                                                          ),
                                                          options:
                                                              FFButtonOptions(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: Colors
                                                                .transparent,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Cinzel Decorative',
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          showLoadingIndicator:
                                                              false,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_model.startTime1
                                                      ?.millisecondsSinceEpoch !=
                                                  null)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0.0,
                                                                140.0,
                                                                0.0,
                                                                0.0),
                                                    child: Text(
                                                      (int delta) {
                                                        return delta > 0
                                                            ? '+ $delta'
                                                            : '$delta';
                                                      }(_model
                                                          .lifeCounterDelta1),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Noto Sans',
                                                            fontSize: 30.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              if (!(_model.startTime1
                                                      ?.millisecondsSinceEpoch !=
                                                  null))
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 140.0, 0.0, 0.0),
                                                  child: Icon(
                                                    Icons.favorite,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 30.0,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, 0.0, 8.0, 8.0),
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              if (_model.hasSettings1)
                                                FlutterFlowIconButton(
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderRadius: 20.0,
                                                  borderWidth: 1.0,
                                                  buttonSize: 64.0,
                                                  icon: Icon(
                                                    Icons
                                                        .remove_red_eye_outlined,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 38.0,
                                                  ),
                                                  onPressed: () async {
                                                    logFirebaseEvent(
                                                        'C_GAME_VIEW_PAGE_Eye_ON_TAP');
                                                    logFirebaseEvent(
                                                        'Eye_update_page_state');
                                                    setState(() {
                                                      _model.hasSettings1 =
                                                          false;
                                                    });
                                                    logFirebaseEvent(
                                                        'Eye_widget_animation');
                                                    if (animationsMap[
                                                            'rowOnActionTriggerAnimation1'] !=
                                                        null) {
                                                      await animationsMap[
                                                              'rowOnActionTriggerAnimation1']!
                                                          .controller
                                                          .reverse();
                                                    }
                                                  },
                                                ),
                                              if (!_model.hasSettings1)
                                                FlutterFlowIconButton(
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderRadius: 20.0,
                                                  borderWidth: 1.0,
                                                  buttonSize: 64.0,
                                                  icon: FaIcon(
                                                    FontAwesomeIcons.eyeSlash,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 38.0,
                                                  ),
                                                  onPressed: () async {
                                                    logFirebaseEvent(
                                                        'C_GAME_VIEW_PAGE_EyeClosed_ON_TAP');
                                                    logFirebaseEvent(
                                                        'EyeClosed_update_page_state');
                                                    setState(() {
                                                      _model.hasSettings1 =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'EyeClosed_widget_animation');
                                                    if (animationsMap[
                                                            'rowOnActionTriggerAnimation1'] !=
                                                        null) {
                                                      setState(() =>
                                                          hasRowTriggered1 =
                                                              true);
                                                      SchedulerBinding.instance
                                                          .addPostFrameCallback((_) async =>
                                                              await animationsMap[
                                                                      'rowOnActionTriggerAnimation1']!
                                                                  .controller
                                                                  .forward(
                                                                      from:
                                                                          0.0));
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (_model.hasSettings1)
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Stack(
                                                children: [
                                                  if (_model.isCounter1)
                                                    FlutterFlowIconButton(
                                                      borderColor:
                                                          Colors.transparent,
                                                      borderRadius: 20.0,
                                                      borderWidth: 1.0,
                                                      buttonSize: 64.0,
                                                      icon: Icon(
                                                        Icons.favorite,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 38.0,
                                                      ),
                                                      onPressed: () async {
                                                        logFirebaseEvent(
                                                            'C_GAME_VIEW_PAGE_LifeButton_ON_TAP');
                                                        logFirebaseEvent(
                                                            'LifeButton_update_page_state');
                                                        setState(() {
                                                          _model.isCounter1 =
                                                              false;
                                                        });
                                                      },
                                                    ),
                                                  if (!_model.isCounter1)
                                                    FlutterFlowIconButton(
                                                      borderColor:
                                                          Colors.transparent,
                                                      borderRadius: 20.0,
                                                      borderWidth: 1.0,
                                                      buttonSize: 64.0,
                                                      icon: Icon(
                                                        Icons.onetwothree,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 48.0,
                                                      ),
                                                      onPressed: () async {
                                                        logFirebaseEvent(
                                                            'C_GAME_VIEW_PAGE_CounterButton_ON_TAP');
                                                        logFirebaseEvent(
                                                            'CounterButton_update_page_state');
                                                        setState(() {
                                                          _model.isCounter1 =
                                                              true;
                                                        });
                                                      },
                                                    ),
                                                ],
                                              ),
                                              if (!widget.isRanked!)
                                                FlutterFlowIconButton(
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderRadius: 20.0,
                                                  borderWidth: 1.0,
                                                  buttonSize: 56.0,
                                                  icon: FaIcon(
                                                    FontAwesomeIcons.random,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 30.0,
                                                  ),
                                                  onPressed: () async {
                                                    logFirebaseEvent(
                                                        'C_GAME_VIEW_PAGE_RandomButton_ON_TAP');
                                                    logFirebaseEvent(
                                                        'RandomButton_update_page_state');
                                                    setState(() {
                                                      _model.randomAvatar1 =
                                                          valueOrDefault<int>(
                                                        random_data.randomInteger(
                                                            0,
                                                            _model.images!
                                                                    .where((e) =>
                                                                        e.type ==
                                                                        'avatar')
                                                                    .toList()
                                                                    .length -
                                                                1),
                                                        0,
                                                      );
                                                    });
                                                    logFirebaseEvent(
                                                        'RandomButton_update_page_state');
                                                    setState(() {
                                                      _model.avatar1 = _model
                                                          .images!
                                                          .where((e) =>
                                                              e.type ==
                                                              'avatar')
                                                          .toList()[_model
                                                              .randomAvatar1]
                                                          .image
                                                          .first
                                                          .downloadURL;
                                                    });
                                                  },
                                                ),
                                              FlutterFlowIconButton(
                                                borderColor: Colors.transparent,
                                                borderRadius: 20.0,
                                                borderWidth: 1.0,
                                                buttonSize: 56.0,
                                                icon: FaIcon(
                                                  FontAwesomeIcons.dice,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 38.0,
                                                ),
                                                onPressed: () async {
                                                  logFirebaseEvent(
                                                      'C_GAME_VIEW_PAGE_DiceButton_ON_TAP');
                                                  logFirebaseEvent(
                                                      'DiceButton_update_page_state');
                                                  setState(() {
                                                    _model.hasDice = true;
                                                  });
                                                  logFirebaseEvent(
                                                      'DiceButton_update_page_state');
                                                  setState(() {
                                                    _model.diceResult2 =
                                                        valueOrDefault<int>(
                                                      random_data.randomInteger(
                                                          1, 6),
                                                      1,
                                                    );
                                                    _model.diceResult1 =
                                                        valueOrDefault<int>(
                                                      random_data.randomInteger(
                                                          1, 6),
                                                      1,
                                                    );
                                                  });
                                                  logFirebaseEvent(
                                                      'DiceButton_start_periodic_action');
                                                  _model.diceTimer1 =
                                                      InstantTimer.periodic(
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    callback: (timer) async {
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice11Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice12Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice13Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice14Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice15Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice16Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice21Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice22Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice23Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice24Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice25Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_rive_animation');

                                                      _model.dice26Controllers
                                                          .forEach(
                                                              (controller) {
                                                        controller.reactivate =
                                                            true;
                                                      });
                                                      logFirebaseEvent(
                                                          'DiceButton_stop_periodic_action');
                                                      _model.diceTimer1
                                                          ?.cancel();
                                                      logFirebaseEvent(
                                                          'DiceButton_start_periodic_action');
                                                      _model.endDice1 =
                                                          InstantTimer.periodic(
                                                        duration: Duration(
                                                            milliseconds: 3000),
                                                        callback:
                                                            (timer) async {
                                                          logFirebaseEvent(
                                                              'DiceButton_update_page_state');
                                                          setState(() {
                                                            _model.hasDice =
                                                                false;
                                                          });
                                                          logFirebaseEvent(
                                                              'DiceButton_stop_periodic_action');
                                                          _model.endDice1
                                                              ?.cancel();
                                                        },
                                                        startImmediately: false,
                                                      );
                                                    },
                                                    startImmediately: false,
                                                  );
                                                },
                                              ),
                                              Stack(
                                                children: [
                                                  if (!widget.isRanked!)
                                                    FlutterFlowIconButton(
                                                      borderColor:
                                                          Colors.transparent,
                                                      borderRadius: 20.0,
                                                      borderWidth: 1.0,
                                                      buttonSize: 56.0,
                                                      icon: Icon(
                                                        Icons.refresh_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 38.0,
                                                      ),
                                                      onPressed: () async {
                                                        logFirebaseEvent(
                                                            'C_GAME_VIEW_PAGE_RestartButton_ON_TAP');
                                                        logFirebaseEvent(
                                                            'RestartButton_alert_dialog');
                                                        var confirmDialogResponse =
                                                            await showDialog<
                                                                    bool>(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (alertDialogContext) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Rematch?'),
                                                                      content: Text(
                                                                          'Do you want to rematch?'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              false),
                                                                          child:
                                                                              Text('Cancel'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              true),
                                                                          child:
                                                                              Text('Confirm'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ) ??
                                                                false;
                                                        if (confirmDialogResponse) {
                                                          logFirebaseEvent(
                                                              'RestartButton_update_page_state');
                                                          setState(() {
                                                            _model.lifeCounter1 =
                                                                20;
                                                            _model.lifeCounter2 =
                                                                20;
                                                            _model.isCounter1 =
                                                                false;
                                                            _model.isCounter2 =
                                                                false;
                                                            _model.counter1 = 0;
                                                            _model.counter2 = 0;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  if (widget.isRanked ?? true)
                                                    FlutterFlowIconButton(
                                                      borderColor:
                                                          Colors.transparent,
                                                      borderRadius: 20.0,
                                                      borderWidth: 1.0,
                                                      buttonSize: 56.0,
                                                      icon: Icon(
                                                        FFIcons.ktrophyFull,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 30.0,
                                                      ),
                                                      onPressed: () async {
                                                        logFirebaseEvent(
                                                            'C_GAME_VIEW_PAGE_VictoryButton_ON_TAP');
                                                        // Did you win?
                                                        logFirebaseEvent(
                                                            'VictoryButton_Didyouwin?');
                                                        var confirmDialogResponse =
                                                            await showDialog<
                                                                    bool>(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (alertDialogContext) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                        FFLocalizations.of(context)
                                                                            .getVariableText(
                                                                          enText:
                                                                              'Victory',
                                                                          frText:
                                                                              'Victoire',
                                                                        ),
                                                                        'Victory',
                                                                      )),
                                                                      content: Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                        FFLocalizations.of(context)
                                                                            .getVariableText(
                                                                          enText: (String
                                                                              deck1Name) {
                                                                            return 'Save the game with $deck1Name as winner?';
                                                                          }(_model
                                                                              .deck1!
                                                                              .name),
                                                                          frText:
                                                                              valueOrDefault<String>(
                                                                            (String
                                                                                deck1Name) {
                                                                              return 'Sauvegarder la partie avec $deck1Name comme vainqueur ?';
                                                                            }(_model.deck1!.name),
                                                                            'Sauvegarder la partie avec le joueur du bas comme vainqueur ?',
                                                                          ),
                                                                        ),
                                                                        'Save the game with bottom player as winner?',
                                                                      )),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              false),
                                                                          child:
                                                                              Text(valueOrDefault<String>(
                                                                            FFLocalizations.of(context).getVariableText(
                                                                              enText: 'Cancel',
                                                                              frText: 'Annuler',
                                                                            ),
                                                                            'Cancel',
                                                                          )),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              true),
                                                                          child:
                                                                              Text(valueOrDefault<String>(
                                                                            FFLocalizations.of(context).getVariableText(
                                                                              enText: 'Confirm',
                                                                              frText: 'Confirmer',
                                                                            ),
                                                                            'Confirm',
                                                                          )),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ) ??
                                                                false;
                                                        if (confirmDialogResponse) {
                                                          // Create matchupid
                                                          logFirebaseEvent(
                                                              'VictoryButton_Creatematchupid');
                                                          _model.matchupId =
                                                              await actions
                                                                  .createsMatchupid(
                                                            FFAppState()
                                                                .currentGameDeckRef1!
                                                                .id,
                                                            FFAppState()
                                                                .currentGameDeckRef2!
                                                                .id,
                                                          );
                                                          // Check if today game exists
                                                          logFirebaseEvent(
                                                              'VictoryButton_Checkiftodaygameexists');
                                                          _model.hasTodayGame =
                                                              await actions
                                                                  .checkIfTodayMatchupGameExists(
                                                            _model.matchupId!,
                                                          );
                                                          // Set Player1 Victorious
                                                          logFirebaseEvent(
                                                              'VictoryButton_SetPlayer1Victorious');
                                                          setState(() {
                                                            _model.isPlayer1Victorious =
                                                                true;
                                                          });
                                                          if (_model
                                                              .hasTodayGame!) {
                                                            // Get today game
                                                            logFirebaseEvent(
                                                                'VictoryButton_Gettodaygame');
                                                            _model.todayGameDoc =
                                                                await queryGamesRecordOnce(
                                                              queryBuilder:
                                                                  (gamesRecord) =>
                                                                      gamesRecord
                                                                          .where(
                                                                            'matchupId',
                                                                            isEqualTo:
                                                                                _model.matchupId,
                                                                          )
                                                                          .where(
                                                                            'date',
                                                                            isGreaterThanOrEqualTo:
                                                                                functions.getTodayDate(),
                                                                          ),
                                                              singleRecord:
                                                                  true,
                                                            ).then((s) => s
                                                                    .firstOrNull);
                                                            // Get player1 (victorious)
                                                            logFirebaseEvent(
                                                                'VictoryButton_Getplayer1victorious');
                                                            _model.winnerPlayer =
                                                                await queryPlayersRecordOnce(
                                                              parent: _model
                                                                  .todayGameDoc
                                                                  ?.reference,
                                                              queryBuilder:
                                                                  (playersRecord) =>
                                                                      playersRecord
                                                                          .where(
                                                                'deckId',
                                                                isEqualTo: _model
                                                                    .deck1
                                                                    ?.reference
                                                                    .id,
                                                              ),
                                                              singleRecord:
                                                                  true,
                                                            ).then((s) => s
                                                                    .firstOrNull);
                                                            // Update player1 score
                                                            logFirebaseEvent(
                                                                'VictoryButton_Updateplayer1score');

                                                            await _model
                                                                .winnerPlayer!
                                                                .reference
                                                                .update({
                                                              ...mapToFirestore(
                                                                {
                                                                  'score': FieldValue
                                                                      .increment(
                                                                          1),
                                                                },
                                                              ),
                                                            });
                                                            logFirebaseEvent(
                                                                'VictoryButton_firestore_query');
                                                            _model.existingMatchupDocUpdateGame =
                                                                await queryMatchupsRecordOnce(
                                                              queryBuilder:
                                                                  (matchupsRecord) =>
                                                                      matchupsRecord
                                                                          .where(
                                                                'matchupId',
                                                                isEqualTo: _model
                                                                    .matchupId,
                                                              ),
                                                              singleRecord:
                                                                  true,
                                                            ).then((s) => s
                                                                    .firstOrNull);
                                                            logFirebaseEvent(
                                                                'VictoryButton_custom_action');
                                                            _model.newScoresUpdateGame =
                                                                await actions
                                                                    .updateScores(
                                                              FFAppState()
                                                                  .currentGameDeckRef1!
                                                                  .id,
                                                              1,
                                                              FFAppState()
                                                                  .currentGameDeckRef2!
                                                                  .id,
                                                              0,
                                                              _model
                                                                  .existingMatchupDocUpdateGame!
                                                                  .scores
                                                                  .toList(),
                                                            );
                                                            logFirebaseEvent(
                                                                'VictoryButton_backend_call');

                                                            await _model
                                                                .existingMatchupDocUpdateGame!
                                                                .reference
                                                                .update({
                                                              ...mapToFirestore(
                                                                {
                                                                  'scores':
                                                                      getScoreListFirestoreData(
                                                                    _model
                                                                        .newScoresUpdateGame,
                                                                  ),
                                                                },
                                                              ),
                                                            });
                                                          } else {
                                                            // Create the game
                                                            logFirebaseEvent(
                                                                'VictoryButton_Createthegame');

                                                            var gamesRecordReference =
                                                                GamesRecord
                                                                    .collection
                                                                    .doc();
                                                            await gamesRecordReference
                                                                .set({
                                                              ...createGamesRecordData(
                                                                crewId: valueOrDefault(
                                                                    currentUserDocument
                                                                        ?.crewId,
                                                                    ''),
                                                              ),
                                                              ...mapToFirestore(
                                                                {
                                                                  'date': FieldValue
                                                                      .serverTimestamp(),
                                                                  'deckIds': (String
                                                                              deckId1,
                                                                          String
                                                                              deckId2) {
                                                                    return [
                                                                      deckId1,
                                                                      deckId2
                                                                    ];
                                                                  }(
                                                                      FFAppState()
                                                                          .currentGameDeckRef1!
                                                                          .id,
                                                                      FFAppState()
                                                                          .currentGameDeckRef2!
                                                                          .id),
                                                                },
                                                              ),
                                                            });
                                                            _model.savedGameDoc =
                                                                GamesRecord
                                                                    .getDocumentFromData({
                                                              ...createGamesRecordData(
                                                                crewId: valueOrDefault(
                                                                    currentUserDocument
                                                                        ?.crewId,
                                                                    ''),
                                                              ),
                                                              ...mapToFirestore(
                                                                {
                                                                  'date':
                                                                      DateTime
                                                                          .now(),
                                                                  'deckIds': (String
                                                                              deckId1,
                                                                          String
                                                                              deckId2) {
                                                                    return [
                                                                      deckId1,
                                                                      deckId2
                                                                    ];
                                                                  }(
                                                                      FFAppState()
                                                                          .currentGameDeckRef1!
                                                                          .id,
                                                                      FFAppState()
                                                                          .currentGameDeckRef2!
                                                                          .id),
                                                                },
                                                              ),
                                                            }, gamesRecordReference);
                                                            // Save player 1
                                                            // Create player1 (victorious)
                                                            logFirebaseEvent(
                                                                'VictoryButton_Createplayer1victorious');

                                                            var playersRecordReference1 =
                                                                PlayersRecord
                                                                    .createDoc(_model
                                                                        .savedGameDoc!
                                                                        .reference);
                                                            await playersRecordReference1
                                                                .set(
                                                                    createPlayersRecordData(
                                                              score: 1,
                                                              deckName: _model
                                                                  .deck1?.name,
                                                              deckId: _model
                                                                  .deck1
                                                                  ?.reference
                                                                  .id,
                                                              crewmateId: _model
                                                                  .deck1
                                                                  ?.crewmateId,
                                                              crewId: _model
                                                                  .deck1
                                                                  ?.crewId,
                                                              deckRef: functions
                                                                  .fromDeckIdToRef(
                                                                      _model
                                                                          .deck1!
                                                                          .reference
                                                                          .id),
                                                              crewmateRef: functions
                                                                  .fromCrewmateIdToRef(
                                                                      _model
                                                                          .deck1!
                                                                          .crewmateId,
                                                                      _model
                                                                          .deck1!
                                                                          .crewId),
                                                            ));
                                                            _model.player1Doc =
                                                                PlayersRecord
                                                                    .getDocumentFromData(
                                                                        createPlayersRecordData(
                                                                          score:
                                                                              1,
                                                                          deckName: _model
                                                                              .deck1
                                                                              ?.name,
                                                                          deckId: _model
                                                                              .deck1
                                                                              ?.reference
                                                                              .id,
                                                                          crewmateId: _model
                                                                              .deck1
                                                                              ?.crewmateId,
                                                                          crewId: _model
                                                                              .deck1
                                                                              ?.crewId,
                                                                          deckRef: functions.fromDeckIdToRef(_model
                                                                              .deck1!
                                                                              .reference
                                                                              .id),
                                                                          crewmateRef: functions.fromCrewmateIdToRef(
                                                                              _model.deck1!.crewmateId,
                                                                              _model.deck1!.crewId),
                                                                        ),
                                                                        playersRecordReference1);
                                                            // Save player2
                                                            // Create player2 (loser)
                                                            logFirebaseEvent(
                                                                'VictoryButton_Createplayer2loser');

                                                            var playersRecordReference2 =
                                                                PlayersRecord
                                                                    .createDoc(_model
                                                                        .savedGameDoc!
                                                                        .reference);
                                                            await playersRecordReference2
                                                                .set(
                                                                    createPlayersRecordData(
                                                              score: 0,
                                                              deckName: _model
                                                                  .deck2?.name,
                                                              deckId: _model
                                                                  .deck2
                                                                  ?.reference
                                                                  .id,
                                                              crewmateId: _model
                                                                  .deck2
                                                                  ?.crewmateId,
                                                              crewId: _model
                                                                  .deck2
                                                                  ?.crewId,
                                                              deckRef: functions
                                                                  .fromDeckIdToRef(
                                                                      _model
                                                                          .deck2!
                                                                          .reference
                                                                          .id),
                                                              crewmateRef: functions
                                                                  .fromCrewmateIdToRef(
                                                                      _model
                                                                          .deck2!
                                                                          .crewmateId,
                                                                      _model
                                                                          .deck2!
                                                                          .crewId),
                                                            ));
                                                            _model.player2Doc =
                                                                PlayersRecord
                                                                    .getDocumentFromData(
                                                                        createPlayersRecordData(
                                                                          score:
                                                                              0,
                                                                          deckName: _model
                                                                              .deck2
                                                                              ?.name,
                                                                          deckId: _model
                                                                              .deck2
                                                                              ?.reference
                                                                              .id,
                                                                          crewmateId: _model
                                                                              .deck2
                                                                              ?.crewmateId,
                                                                          crewId: _model
                                                                              .deck2
                                                                              ?.crewId,
                                                                          deckRef: functions.fromDeckIdToRef(_model
                                                                              .deck2!
                                                                              .reference
                                                                              .id),
                                                                          crewmateRef: functions.fromCrewmateIdToRef(
                                                                              _model.deck2!.crewmateId,
                                                                              _model.deck2!.crewId),
                                                                        ),
                                                                        playersRecordReference2);
                                                            logFirebaseEvent(
                                                                'VictoryButton_custom_action');
                                                            _model.hasMatchup =
                                                                await actions
                                                                    .checkIfMatchupExists(
                                                              _model.matchupId!,
                                                            );
                                                            if (_model
                                                                .hasMatchup!) {
                                                              logFirebaseEvent(
                                                                  'VictoryButton_firestore_query');
                                                              _model.existingMatchupDoc =
                                                                  await queryMatchupsRecordOnce(
                                                                queryBuilder:
                                                                    (matchupsRecord) =>
                                                                        matchupsRecord
                                                                            .where(
                                                                  'matchupId',
                                                                  isEqualTo: _model
                                                                      .matchupId,
                                                                ),
                                                                singleRecord:
                                                                    true,
                                                              ).then((s) => s
                                                                      .firstOrNull);
                                                              logFirebaseEvent(
                                                                  'VictoryButton_custom_action');
                                                              _model.newScores =
                                                                  await actions
                                                                      .updateScores(
                                                                FFAppState()
                                                                    .currentGameDeckRef1!
                                                                    .id,
                                                                1,
                                                                FFAppState()
                                                                    .currentGameDeckRef2!
                                                                    .id,
                                                                0,
                                                                _model
                                                                    .existingMatchupDoc!
                                                                    .scores
                                                                    .toList(),
                                                              );
                                                              logFirebaseEvent(
                                                                  'VictoryButton_backend_call');

                                                              await _model
                                                                  .existingMatchupDoc!
                                                                  .reference
                                                                  .update({
                                                                ...mapToFirestore(
                                                                  {
                                                                    'gameIds':
                                                                        FieldValue
                                                                            .arrayUnion([
                                                                      _model
                                                                          .savedGameDoc
                                                                          ?.reference
                                                                          .id
                                                                    ]),
                                                                    'scores':
                                                                        getScoreListFirestoreData(
                                                                      _model
                                                                          .newScores,
                                                                    ),
                                                                  },
                                                                ),
                                                              });
                                                            } else {
                                                              logFirebaseEvent(
                                                                  'VictoryButton_custom_action');
                                                              _model.createdScores =
                                                                  await actions
                                                                      .createScores(
                                                                FFAppState()
                                                                    .currentGameDeckRef1!
                                                                    .id,
                                                                1,
                                                                FFAppState()
                                                                    .currentGameDeckRef2!
                                                                    .id,
                                                                0,
                                                              );
                                                              logFirebaseEvent(
                                                                  'VictoryButton_backend_call');

                                                              await MatchupsRecord
                                                                  .collection
                                                                  .doc()
                                                                  .set({
                                                                ...createMatchupsRecordData(
                                                                  matchupId: _model
                                                                      .matchupId,
                                                                  crewId: valueOrDefault(
                                                                      currentUserDocument
                                                                          ?.crewId,
                                                                      ''),
                                                                ),
                                                                ...mapToFirestore(
                                                                  {
                                                                    'gameIds': [
                                                                      _model
                                                                          .savedGameDoc
                                                                          ?.reference
                                                                          .id
                                                                    ],
                                                                    'deckIds': (String
                                                                                deckId1,
                                                                            String
                                                                                deckId2) {
                                                                      return [
                                                                        deckId1,
                                                                        deckId2
                                                                      ];
                                                                    }(
                                                                        FFAppState()
                                                                            .currentGameDeckRef1!
                                                                            .id,
                                                                        FFAppState()
                                                                            .currentGameDeckRef2!
                                                                            .id),
                                                                    'scores':
                                                                        getScoreListFirestoreData(
                                                                      _model
                                                                          .createdScores,
                                                                    ),
                                                                  },
                                                                ),
                                                              });
                                                            }
                                                          }

                                                          logFirebaseEvent(
                                                              'VictoryButton_rive_animation');

                                                          _model
                                                              .confettiPlayer1Controllers
                                                              .forEach(
                                                                  (controller) {
                                                            controller
                                                                    .reactivate =
                                                                true;
                                                          });
                                                          logFirebaseEvent(
                                                              'VictoryButton_haptic_feedback');
                                                          HapticFeedback
                                                              .vibrate();
                                                          logFirebaseEvent(
                                                              'VictoryButton_alert_dialog');
                                                          confirmDialogResponse =
                                                              await showDialog<
                                                                      bool>(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (alertDialogContext) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            'Rematch?'),
                                                                        content:
                                                                            Text('Do you want to rematch?'),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(alertDialogContext, false),
                                                                            child:
                                                                                Text('Cancel'),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(alertDialogContext, true),
                                                                            child:
                                                                                Text('Confirm'),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  ) ??
                                                                  false;
                                                          if (confirmDialogResponse) {
                                                            logFirebaseEvent(
                                                                'VictoryButton_update_page_state');
                                                            setState(() {
                                                              _model.lifeCounter1 =
                                                                  20;
                                                              _model.lifeCounter2 =
                                                                  20;
                                                              _model.counter1 =
                                                                  0;
                                                              _model.counter2 =
                                                                  0;
                                                              _model.isCounter1 =
                                                                  false;
                                                              _model.isCounter2 =
                                                                  false;
                                                            });
                                                          } else {
                                                            logFirebaseEvent(
                                                                'VictoryButton_update_app_state');
                                                            setState(() {
                                                              FFAppState()
                                                                      .deck1Selected =
                                                                  false;
                                                              FFAppState()
                                                                      .deck2Selected =
                                                                  false;
                                                            });
                                                            logFirebaseEvent(
                                                                'VictoryButton_navigate_to');

                                                            context.pushNamed(
                                                                'A_HomePage');
                                                          }
                                                        }

                                                        setState(() {});
                                                      },
                                                    ),
                                                ],
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    1.0, 0.0),
                                                child: FlutterFlowIconButton(
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderRadius: 20.0,
                                                  borderWidth: 1.0,
                                                  buttonSize: 56.0,
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 38.0,
                                                  ),
                                                  onPressed: () async {
                                                    logFirebaseEvent(
                                                        'C_GAME_VIEW_PAGE_CancelButton_ON_TAP');
                                                    logFirebaseEvent(
                                                        'CancelButton_alert_dialog');
                                                    var confirmDialogResponse =
                                                        await showDialog<bool>(
                                                              context: context,
                                                              builder:
                                                                  (alertDialogContext) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Leave the game'),
                                                                  content: Text(
                                                                      'Are you sure you want to leave the game?'),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () => Navigator.pop(
                                                                          alertDialogContext,
                                                                          false),
                                                                      child: Text(
                                                                          'Cancel'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () => Navigator.pop(
                                                                          alertDialogContext,
                                                                          true),
                                                                      child: Text(
                                                                          'Confirm'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            ) ??
                                                            false;
                                                    if (confirmDialogResponse) {
                                                      logFirebaseEvent(
                                                          'CancelButton_navigate_to');

                                                      context.pushNamed(
                                                          'A_HomePage');
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                              .animateOnPageLoad(animationsMap[
                                                  'rowOnPageLoadAnimation1']!)
                                              .animateOnActionTrigger(
                                                  animationsMap[
                                                      'rowOnActionTriggerAnimation1']!,
                                                  hasBeenTriggered:
                                                      hasRowTriggered1),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_model.hasDice && (_model.diceResult1 == 1))
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              child: RiveAnimation.asset(
                                'assets/rive_animations/3226-6789-shakeable-dice.riv',
                                artboard: 'New Artboard',
                                fit: BoxFit.cover,
                                controllers: _model.dice11Controllers,
                              ),
                            ),
                          ),
                        if (_model.hasDice && (_model.diceResult1 == 2))
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              child: RiveAnimation.asset(
                                'assets/rive_animations/3226-6789-shakeable-dice.riv',
                                artboard: 'New Artboard',
                                fit: BoxFit.cover,
                                controllers: _model.dice12Controllers,
                              ),
                            ),
                          ),
                        if (_model.hasDice && (_model.diceResult1 == 3))
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              child: RiveAnimation.asset(
                                'assets/rive_animations/3226-6789-shakeable-dice.riv',
                                artboard: 'New Artboard',
                                fit: BoxFit.cover,
                                controllers: _model.dice13Controllers,
                              ),
                            ),
                          ),
                        if (_model.hasDice && (_model.diceResult1 == 4))
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              child: RiveAnimation.asset(
                                'assets/rive_animations/3226-6789-shakeable-dice.riv',
                                artboard: 'New Artboard',
                                fit: BoxFit.cover,
                                controllers: _model.dice14Controllers,
                              ),
                            ),
                          ),
                        if (_model.hasDice && (_model.diceResult1 == 5))
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              child: RiveAnimation.asset(
                                'assets/rive_animations/3226-6789-shakeable-dice.riv',
                                artboard: 'New Artboard',
                                fit: BoxFit.cover,
                                controllers: _model.dice15Controllers,
                              ),
                            ),
                          ),
                        if (_model.hasDice && (_model.diceResult1 == 6))
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              child: RiveAnimation.asset(
                                'assets/rive_animations/3226-6789-shakeable-dice.riv',
                                artboard: 'New Artboard',
                                fit: BoxFit.cover,
                                controllers: _model.dice16Controllers,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.network(
                      widget.isRanked!
                          ? valueOrDefault<String>(
                              _model.deck2?.avatarUrl,
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/magic-6zjv9f/assets/9e5l347v0vwn/output-onlinegiftools.gif',
                            )
                          : _model.avatar2,
                    ).image,
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFFCA5052), Colors.white],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.34, -1.0),
                    end: AlignmentDirectional(-0.34, 1.0),
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                  shape: BoxShape.rectangle,
                ),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Stack(
                    children: [
                      if (valueOrDefault<bool>(
                        _model.isPlayer2Victorious,
                        false,
                      ))
                        Align(
                          alignment: AlignmentDirectional(1.0, 0.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 0.5,
                            child: RiveAnimation.asset(
                              'assets/rive_animations/confetti_mobile_(1).riv',
                              artboard: 'Confetti.svg',
                              fit: BoxFit.fill,
                              controllers: _model.confettiPlayer2Controllers,
                            ),
                          ),
                        ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.5,
                        decoration: BoxDecoration(
                          color: Color(0x33323236),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  if (_model.isCounter2)
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: FFButtonWidget(
                                                        onPressed: () async {
                                                          logFirebaseEvent(
                                                              'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                          logFirebaseEvent(
                                                              'Button_update_page_state');
                                                          setState(() {
                                                            _model.counter2 =
                                                                _model.counter2 +
                                                                    -1;
                                                            _model.deltaCounter2 =
                                                                _model.deltaCounter2 +
                                                                    -1;
                                                          });
                                                          if (!_model
                                                              .isTimerCounter2Set) {
                                                            logFirebaseEvent(
                                                                'Button_update_page_state');
                                                            setState(() {
                                                              _model.isTimerCounter2Set =
                                                                  true;
                                                            });
                                                            logFirebaseEvent(
                                                                'Button_start_periodic_action');
                                                            _model.minusTimerCounter2 =
                                                                InstantTimer
                                                                    .periodic(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      3000),
                                                              callback:
                                                                  (timer) async {
                                                                logFirebaseEvent(
                                                                    'Button_update_page_state');
                                                                setState(() {
                                                                  _model.deltaCounter2 =
                                                                      0;
                                                                  _model.isTimerCounter2Set =
                                                                      false;
                                                                });
                                                                logFirebaseEvent(
                                                                    'Button_stop_periodic_action');
                                                                _model
                                                                    .minusTimerCounter2
                                                                    ?.cancel();
                                                              },
                                                              startImmediately:
                                                                  false,
                                                            );
                                                          }
                                                        },
                                                        text: '',
                                                        icon: Icon(
                                                          Icons.remove_rounded,
                                                          size: 70.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: Colors
                                                              .transparent,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Cinzel Decorative',
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: AutoSizeText(
                                                        _model.counter2
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  'Noto Sans',
                                                              fontSize: 120.0,
                                                              letterSpacing:
                                                                  5.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: FFButtonWidget(
                                                        onPressed: () async {
                                                          logFirebaseEvent(
                                                              'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                          logFirebaseEvent(
                                                              'Button_update_page_state');
                                                          setState(() {
                                                            _model.counter2 =
                                                                _model.counter2 +
                                                                    1;
                                                            _model.deltaCounter2 =
                                                                _model.deltaCounter2 +
                                                                    1;
                                                          });
                                                          if (!_model
                                                              .isTimerCounter2Set) {
                                                            logFirebaseEvent(
                                                                'Button_update_page_state');
                                                            setState(() {
                                                              _model.isTimerCounter2Set =
                                                                  true;
                                                            });
                                                            logFirebaseEvent(
                                                                'Button_start_periodic_action');
                                                            _model.plusTimerCounter2 =
                                                                InstantTimer
                                                                    .periodic(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      3000),
                                                              callback:
                                                                  (timer) async {
                                                                logFirebaseEvent(
                                                                    'Button_update_page_state');
                                                                setState(() {
                                                                  _model.deltaCounter2 =
                                                                      0;
                                                                  _model.isTimerCounter2Set =
                                                                      false;
                                                                });
                                                                logFirebaseEvent(
                                                                    'Button_stop_periodic_action');
                                                                _model
                                                                    .plusTimerCounter2
                                                                    ?.cancel();
                                                              },
                                                              startImmediately:
                                                                  false,
                                                            );
                                                          }
                                                        },
                                                        text: '',
                                                        icon: Icon(
                                                          Icons.add_rounded,
                                                          size: 70.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: Colors
                                                              .transparent,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Cinzel Decorative',
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        showLoadingIndicator:
                                                            false,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (_model.isTimerCounter2Set)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 140.0, 0.0, 0.0),
                                                  child: Text(
                                                    (int delta) {
                                                      return delta > 0
                                                          ? '+ $delta'
                                                          : '$delta';
                                                    }(_model.deltaCounter2),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Noto Sans',
                                                          fontSize: 30.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            if (!_model.isTimerCounter2Set)
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 140.0, 0.0, 0.0),
                                                child: Icon(
                                                  Icons.onetwothree,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 30.0,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (!_model.isCounter2)
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: FFButtonWidget(
                                                        onPressed: () async {
                                                          logFirebaseEvent(
                                                              'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                          logFirebaseEvent(
                                                              'Button_update_page_state');
                                                          setState(() {
                                                            _model.startTime2 =
                                                                getCurrentTimestamp;
                                                            _model.lifeCounter2 =
                                                                _model.lifeCounter2 +
                                                                    -1;
                                                            _model.lifeCounterDelta2 =
                                                                _model.lifeCounterDelta2! +
                                                                    -1;
                                                          });
                                                          if (_model
                                                                  .lifeCounterDelta2 ==
                                                              -1) {
                                                            while (_model
                                                                    .startTime2
                                                                    ?.millisecondsSinceEpoch !=
                                                                null) {
                                                              logFirebaseEvent(
                                                                  'Button_wait__delay');
                                                              await Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000));
                                                              if (_model.startTime2!
                                                                          .millisecondsSinceEpoch +
                                                                      _model
                                                                          .showDeltaPeriod <=
                                                                  getCurrentTimestamp
                                                                      .millisecondsSinceEpoch) {
                                                                // startTime = null & delta = 0
                                                                logFirebaseEvent(
                                                                    'Button_startTime=null&delta=0');
                                                                setState(() {
                                                                  _model.lifeCounterDelta2 =
                                                                      0;
                                                                  _model.startTime2 =
                                                                      null;
                                                                });
                                                                break;
                                                              }
                                                            }
                                                          }
                                                        },
                                                        text: '',
                                                        icon: Icon(
                                                          Icons.remove_rounded,
                                                          size: 70.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: Colors
                                                              .transparent,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Cinzel Decorative',
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        showLoadingIndicator:
                                                            false,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: AutoSizeText(
                                                        valueOrDefault<String>(
                                                          _model.lifeCounter2
                                                              .toString(),
                                                          '20',
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  'Noto Sans',
                                                              fontSize: 120.0,
                                                              letterSpacing:
                                                                  5.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: FFButtonWidget(
                                                        onPressed: () async {
                                                          logFirebaseEvent(
                                                              'C_GAME_VIEW_PAGE__BTN_ON_TAP');
                                                          logFirebaseEvent(
                                                              'Button_update_page_state');
                                                          setState(() {
                                                            _model.startTime2 =
                                                                getCurrentTimestamp;
                                                            _model.lifeCounter2 =
                                                                _model.lifeCounter2 +
                                                                    1;
                                                            _model.lifeCounterDelta2 =
                                                                _model.lifeCounterDelta2! +
                                                                    1;
                                                          });
                                                          if (_model
                                                                  .lifeCounterDelta2 ==
                                                              1) {
                                                            while (_model
                                                                    .startTime2
                                                                    ?.millisecondsSinceEpoch !=
                                                                null) {
                                                              logFirebaseEvent(
                                                                  'Button_wait__delay');
                                                              await Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000));
                                                              if (_model.startTime2!
                                                                          .millisecondsSinceEpoch +
                                                                      _model
                                                                          .showDeltaPeriod <=
                                                                  getCurrentTimestamp
                                                                      .millisecondsSinceEpoch) {
                                                                // startTime = null & delta = 0
                                                                logFirebaseEvent(
                                                                    'Button_startTime=null&delta=0');
                                                                setState(() {
                                                                  _model.lifeCounterDelta2 =
                                                                      0;
                                                                  _model.startTime2 =
                                                                      null;
                                                                });
                                                                break;
                                                              }
                                                            }
                                                          }
                                                        },
                                                        text: '',
                                                        icon: Icon(
                                                          Icons.add_rounded,
                                                          size: 70.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: Colors
                                                              .transparent,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Cinzel Decorative',
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        showLoadingIndicator:
                                                            false,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (_model.startTime2
                                                    ?.millisecondsSinceEpoch !=
                                                null)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 140.0, 0.0, 0.0),
                                                  child: Text(
                                                    (int delta) {
                                                      return delta > 0
                                                          ? '+ $delta'
                                                          : '$delta';
                                                    }(_model
                                                        .lifeCounterDelta2!),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Noto Sans',
                                                          fontSize: 30.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            if (!(_model.startTime2
                                                    ?.millisecondsSinceEpoch !=
                                                null))
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 140.0, 0.0, 0.0),
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 30.0,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 0.0, 8.0, 40.0),
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            if (_model.hasSettings2)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    1.0, 0.0),
                                                child: FlutterFlowIconButton(
                                                  borderRadius: 20.0,
                                                  borderWidth: 1.0,
                                                  buttonSize: 64.0,
                                                  icon: Icon(
                                                    Icons
                                                        .remove_red_eye_outlined,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 38.0,
                                                  ),
                                                  onPressed: () async {
                                                    logFirebaseEvent(
                                                        'C_GAME_VIEW_PAGE_Eye_ON_TAP');
                                                    logFirebaseEvent(
                                                        'Eye_update_page_state');
                                                    setState(() {
                                                      _model.hasSettings2 =
                                                          false;
                                                    });
                                                    logFirebaseEvent(
                                                        'Eye_widget_animation');
                                                    if (animationsMap[
                                                            'rowOnActionTriggerAnimation2'] !=
                                                        null) {
                                                      await animationsMap[
                                                              'rowOnActionTriggerAnimation2']!
                                                          .controller
                                                          .reverse();
                                                    }
                                                  },
                                                ),
                                              ),
                                            if (!_model.hasSettings2)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    1.0, 0.0),
                                                child: FlutterFlowIconButton(
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderRadius: 20.0,
                                                  borderWidth: 1.0,
                                                  buttonSize: 64.0,
                                                  icon: FaIcon(
                                                    FontAwesomeIcons.eyeSlash,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 38.0,
                                                  ),
                                                  onPressed: () async {
                                                    logFirebaseEvent(
                                                        'C_GAME_VIEW_PAGE_EyeClosed_ON_TAP');
                                                    logFirebaseEvent(
                                                        'EyeClosed_update_page_state');
                                                    setState(() {
                                                      _model.hasSettings2 =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'EyeClosed_widget_animation');
                                                    if (animationsMap[
                                                            'rowOnActionTriggerAnimation2'] !=
                                                        null) {
                                                      setState(() =>
                                                          hasRowTriggered2 =
                                                              true);
                                                      SchedulerBinding.instance
                                                          .addPostFrameCallback((_) async =>
                                                              await animationsMap[
                                                                      'rowOnActionTriggerAnimation2']!
                                                                  .controller
                                                                  .forward(
                                                                      from:
                                                                          0.0));
                                                    }
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (_model.hasSettings2)
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Stack(
                                              children: [
                                                if (_model.isCounter2)
                                                  FlutterFlowIconButton(
                                                    borderColor:
                                                        Colors.transparent,
                                                    borderRadius: 20.0,
                                                    borderWidth: 1.0,
                                                    buttonSize: 64.0,
                                                    icon: Icon(
                                                      Icons.favorite,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 38.0,
                                                    ),
                                                    onPressed: () async {
                                                      logFirebaseEvent(
                                                          'C_GAME_VIEW_PAGE_LifeButton_ON_TAP');
                                                      logFirebaseEvent(
                                                          'LifeButton_update_page_state');
                                                      setState(() {
                                                        _model.isCounter2 =
                                                            false;
                                                      });
                                                    },
                                                  ),
                                                if (!_model.isCounter2)
                                                  FlutterFlowIconButton(
                                                    borderColor:
                                                        Colors.transparent,
                                                    borderRadius: 20.0,
                                                    borderWidth: 1.0,
                                                    buttonSize: 64.0,
                                                    icon: Icon(
                                                      Icons.onetwothree,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 48.0,
                                                    ),
                                                    onPressed: () async {
                                                      logFirebaseEvent(
                                                          'C_GAME_VIEW_PAGE_CounterButton_ON_TAP');
                                                      logFirebaseEvent(
                                                          'CounterButton_update_page_state');
                                                      setState(() {
                                                        _model.isCounter2 =
                                                            true;
                                                      });
                                                    },
                                                  ),
                                              ],
                                            ),
                                            if (!widget.isRanked!)
                                              FlutterFlowIconButton(
                                                borderColor: Colors.transparent,
                                                borderRadius: 20.0,
                                                borderWidth: 1.0,
                                                buttonSize: 56.0,
                                                icon: FaIcon(
                                                  FontAwesomeIcons.random,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 30.0,
                                                ),
                                                onPressed: () async {
                                                  logFirebaseEvent(
                                                      'C_GAME_VIEW_PAGE_RandomButton_ON_TAP');
                                                  logFirebaseEvent(
                                                      'RandomButton_update_page_state');
                                                  setState(() {
                                                    _model.randomAvatar2 =
                                                        valueOrDefault<int>(
                                                      random_data.randomInteger(
                                                          0,
                                                          _model.images!
                                                                  .where((e) =>
                                                                      e.type ==
                                                                      'avatar')
                                                                  .toList()
                                                                  .length -
                                                              1),
                                                      0,
                                                    );
                                                  });
                                                  logFirebaseEvent(
                                                      'RandomButton_update_page_state');
                                                  setState(() {
                                                    _model.avatar2 = _model
                                                        .images!
                                                        .where((e) =>
                                                            e.type == 'avatar')
                                                        .toList()[_model
                                                            .randomAvatar2]
                                                        .image
                                                        .first
                                                        .downloadURL;
                                                  });
                                                },
                                              ),
                                            FlutterFlowIconButton(
                                              borderColor: Colors.transparent,
                                              borderRadius: 20.0,
                                              borderWidth: 1.0,
                                              buttonSize: 56.0,
                                              icon: FaIcon(
                                                FontAwesomeIcons.dice,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 38.0,
                                              ),
                                              onPressed: () async {
                                                logFirebaseEvent(
                                                    'C_GAME_VIEW_PAGE_DiceButton_ON_TAP');
                                                logFirebaseEvent(
                                                    'DiceButton_update_page_state');
                                                setState(() {
                                                  _model.hasDice = true;
                                                });
                                                logFirebaseEvent(
                                                    'DiceButton_update_page_state');
                                                setState(() {
                                                  _model.diceResult2 =
                                                      valueOrDefault<int>(
                                                    random_data.randomInteger(
                                                        1, 6),
                                                    1,
                                                  );
                                                  _model.diceResult1 =
                                                      valueOrDefault<int>(
                                                    random_data.randomInteger(
                                                        1, 6),
                                                    1,
                                                  );
                                                });
                                                logFirebaseEvent(
                                                    'DiceButton_start_periodic_action');
                                                _model.diceTimer2 =
                                                    InstantTimer.periodic(
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  callback: (timer) async {
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice11Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice12Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice13Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice14Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice15Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice16Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice21Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice22Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice23Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice24Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice25Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_rive_animation');

                                                    _model.dice26Controllers
                                                        .forEach((controller) {
                                                      controller.reactivate =
                                                          true;
                                                    });
                                                    logFirebaseEvent(
                                                        'DiceButton_stop_periodic_action');
                                                    _model.diceTimer2?.cancel();
                                                    logFirebaseEvent(
                                                        'DiceButton_start_periodic_action');
                                                    _model.endDice2 =
                                                        InstantTimer.periodic(
                                                      duration: Duration(
                                                          milliseconds: 3000),
                                                      callback: (timer) async {
                                                        logFirebaseEvent(
                                                            'DiceButton_update_page_state');
                                                        setState(() {
                                                          _model.hasDice =
                                                              false;
                                                        });
                                                        logFirebaseEvent(
                                                            'DiceButton_stop_periodic_action');
                                                        _model.endDice2
                                                            ?.cancel();
                                                      },
                                                      startImmediately: false,
                                                    );
                                                  },
                                                  startImmediately: false,
                                                );
                                              },
                                            ),
                                            Stack(
                                              children: [
                                                if (!widget.isRanked!)
                                                  FlutterFlowIconButton(
                                                    borderRadius: 20.0,
                                                    borderWidth: 1.0,
                                                    buttonSize: 56.0,
                                                    icon: Icon(
                                                      Icons.refresh_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 38.0,
                                                    ),
                                                    onPressed: () async {
                                                      logFirebaseEvent(
                                                          'C_GAME_VIEW_PAGE_RestartButton_ON_TAP');
                                                      logFirebaseEvent(
                                                          'RestartButton_alert_dialog');
                                                      var confirmDialogResponse =
                                                          await showDialog<
                                                                  bool>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (alertDialogContext) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getVariableText(
                                                                        enText:
                                                                            'Rematch?',
                                                                        frText:
                                                                            'Revanche ?',
                                                                      ),
                                                                      'Rematch?',
                                                                    )),
                                                                    content: Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getVariableText(
                                                                        enText:
                                                                            'Do you want to rematch?',
                                                                        frText:
                                                                            'Voulez-vous jouer la revanche ?',
                                                                      ),
                                                                      'Do you want to rematch?',
                                                                    )),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            false),
                                                                        child: Text(
                                                                            valueOrDefault<String>(
                                                                          FFLocalizations.of(context)
                                                                              .getVariableText(
                                                                            enText:
                                                                                'Cancel',
                                                                            frText:
                                                                                'Annuler',
                                                                          ),
                                                                          'Cancel',
                                                                        )),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            true),
                                                                        child: Text(
                                                                            valueOrDefault<String>(
                                                                          FFLocalizations.of(context)
                                                                              .getVariableText(
                                                                            enText:
                                                                                'Confirm',
                                                                            frText:
                                                                                'Confirmer',
                                                                          ),
                                                                          'Confirm',
                                                                        )),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              ) ??
                                                              false;
                                                      if (confirmDialogResponse) {
                                                        logFirebaseEvent(
                                                            'RestartButton_update_page_state');
                                                        setState(() {
                                                          _model.lifeCounter1 =
                                                              20;
                                                          _model.lifeCounter2 =
                                                              20;
                                                          _model.isCounter1 =
                                                              false;
                                                          _model.isCounter2 =
                                                              false;
                                                          _model.counter1 = 0;
                                                          _model.counter2 = 0;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                if (widget.isRanked ?? true)
                                                  FlutterFlowIconButton(
                                                    borderColor:
                                                        Colors.transparent,
                                                    borderRadius: 20.0,
                                                    borderWidth: 1.0,
                                                    buttonSize: 56.0,
                                                    icon: Icon(
                                                      FFIcons.ktrophyFull,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 30.0,
                                                    ),
                                                    onPressed: () async {
                                                      logFirebaseEvent(
                                                          'C_GAME_VIEW_PAGE_VictoryButton_ON_TAP');
                                                      logFirebaseEvent(
                                                          'VictoryButton_alert_dialog');
                                                      var confirmDialogResponse =
                                                          await showDialog<
                                                                  bool>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (alertDialogContext) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getVariableText(
                                                                        enText:
                                                                            'Victory!',
                                                                        frText:
                                                                            'Victoire !',
                                                                      ),
                                                                      'Victory!',
                                                                    )),
                                                                    content: Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getVariableText(
                                                                        enText: (String
                                                                            deck2Name) {
                                                                          return 'Save the game with $deck2Name as winner?';
                                                                        }(_model
                                                                            .deck2!
                                                                            .name),
                                                                        frText:
                                                                            valueOrDefault<String>(
                                                                          (String
                                                                              deck2Name) {
                                                                            return 'Sauvegarder la partie avec $deck2Name comme vainqueur ?';
                                                                          }(_model
                                                                              .deck2!
                                                                              .name),
                                                                          'Sauvegarder la partie avec le joueur du bas comme vainqueur ?',
                                                                        ),
                                                                      ),
                                                                      'Save the game with bottom player as winner?',
                                                                    )),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            false),
                                                                        child: Text(
                                                                            valueOrDefault<String>(
                                                                          FFLocalizations.of(context)
                                                                              .getVariableText(
                                                                            enText:
                                                                                'Cancel',
                                                                            frText:
                                                                                'Annuler',
                                                                          ),
                                                                          'Cancel',
                                                                        )),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            true),
                                                                        child: Text(
                                                                            valueOrDefault<String>(
                                                                          FFLocalizations.of(context)
                                                                              .getVariableText(
                                                                            enText:
                                                                                'Confirm',
                                                                            frText:
                                                                                'Confirmer',
                                                                          ),
                                                                          'Confirm',
                                                                        )),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              ) ??
                                                              false;
                                                      if (confirmDialogResponse) {
                                                        logFirebaseEvent(
                                                            'VictoryButton_custom_action');
                                                        _model.matchupId2 =
                                                            await actions
                                                                .createsMatchupid(
                                                          FFAppState()
                                                              .currentGameDeckRef1!
                                                              .id,
                                                          FFAppState()
                                                              .currentGameDeckRef2!
                                                              .id,
                                                        );
                                                        logFirebaseEvent(
                                                            'VictoryButton_custom_action');
                                                        _model.hasTodayGame2 =
                                                            await actions
                                                                .checkIfTodayMatchupGameExists(
                                                          _model.matchupId2!,
                                                        );
                                                        // Set Player2 victorious
                                                        logFirebaseEvent(
                                                            'VictoryButton_SetPlayer2victorious');
                                                        setState(() {
                                                          _model.isPlayer2Victorious =
                                                              true;
                                                        });
                                                        if (_model
                                                            .hasTodayGame2!) {
                                                          logFirebaseEvent(
                                                              'VictoryButton_firestore_query');
                                                          _model.todayGameDoc2 =
                                                              await queryGamesRecordOnce(
                                                            queryBuilder:
                                                                (gamesRecord) =>
                                                                    gamesRecord
                                                                        .where(
                                                                          'matchupId',
                                                                          isEqualTo:
                                                                              _model.matchupId2,
                                                                        )
                                                                        .where(
                                                                          'date',
                                                                          isGreaterThanOrEqualTo:
                                                                              functions.getTodayDate(),
                                                                        ),
                                                            singleRecord: true,
                                                          ).then((s) => s
                                                                  .firstOrNull);
                                                          logFirebaseEvent(
                                                              'VictoryButton_firestore_query');
                                                          _model.winnerPlayer2 =
                                                              await queryPlayersRecordOnce(
                                                            parent: _model
                                                                .todayGameDoc2
                                                                ?.reference,
                                                            queryBuilder:
                                                                (playersRecord) =>
                                                                    playersRecord
                                                                        .where(
                                                              'deckId',
                                                              isEqualTo: _model
                                                                  .deck2
                                                                  ?.reference
                                                                  .id,
                                                            ),
                                                            singleRecord: true,
                                                          ).then((s) => s
                                                                  .firstOrNull);
                                                          // Update winner score
                                                          logFirebaseEvent(
                                                              'VictoryButton_backend_call');

                                                          await _model
                                                              .winnerPlayer2!
                                                              .reference
                                                              .update({
                                                            ...mapToFirestore(
                                                              {
                                                                'score': FieldValue
                                                                    .increment(
                                                                        1),
                                                              },
                                                            ),
                                                          });
                                                          logFirebaseEvent(
                                                              'VictoryButton_firestore_query');
                                                          _model.existingMatchupDocUpdateGame2 =
                                                              await queryMatchupsRecordOnce(
                                                            queryBuilder:
                                                                (matchupsRecord) =>
                                                                    matchupsRecord
                                                                        .where(
                                                              'matchupId',
                                                              isEqualTo: _model
                                                                  .matchupId2,
                                                            ),
                                                            singleRecord: true,
                                                          ).then((s) => s
                                                                  .firstOrNull);
                                                          logFirebaseEvent(
                                                              'VictoryButton_custom_action');
                                                          _model.newScoresUpdateGame2 =
                                                              await actions
                                                                  .updateScores(
                                                            FFAppState()
                                                                .currentGameDeckRef1!
                                                                .id,
                                                            0,
                                                            FFAppState()
                                                                .currentGameDeckRef2!
                                                                .id,
                                                            1,
                                                            _model
                                                                .existingMatchupDocUpdateGame2!
                                                                .scores
                                                                .toList(),
                                                          );
                                                          logFirebaseEvent(
                                                              'VictoryButton_backend_call');

                                                          await _model
                                                              .existingMatchupDocUpdateGame2!
                                                              .reference
                                                              .update({
                                                            ...mapToFirestore(
                                                              {
                                                                'scores':
                                                                    getScoreListFirestoreData(
                                                                  _model
                                                                      .newScoresUpdateGame2,
                                                                ),
                                                              },
                                                            ),
                                                          });
                                                        } else {
                                                          // Create the game
                                                          logFirebaseEvent(
                                                              'VictoryButton_Createthegame');

                                                          var gamesRecordReference =
                                                              GamesRecord
                                                                  .collection
                                                                  .doc();
                                                          await gamesRecordReference
                                                              .set({
                                                            ...createGamesRecordData(
                                                              crewId: valueOrDefault(
                                                                  currentUserDocument
                                                                      ?.crewId,
                                                                  ''),
                                                            ),
                                                            ...mapToFirestore(
                                                              {
                                                                'date': FieldValue
                                                                    .serverTimestamp(),
                                                                'deckIds': (String
                                                                            deckId1,
                                                                        String
                                                                            deckId2) {
                                                                  return [
                                                                    deckId1,
                                                                    deckId2
                                                                  ];
                                                                }(
                                                                    FFAppState()
                                                                        .currentGameDeckRef1!
                                                                        .id,
                                                                    FFAppState()
                                                                        .currentGameDeckRef2!
                                                                        .id),
                                                              },
                                                            ),
                                                          });
                                                          _model.savedGameDoc2 =
                                                              GamesRecord
                                                                  .getDocumentFromData({
                                                            ...createGamesRecordData(
                                                              crewId: valueOrDefault(
                                                                  currentUserDocument
                                                                      ?.crewId,
                                                                  ''),
                                                            ),
                                                            ...mapToFirestore(
                                                              {
                                                                'date': DateTime
                                                                    .now(),
                                                                'deckIds': (String
                                                                            deckId1,
                                                                        String
                                                                            deckId2) {
                                                                  return [
                                                                    deckId1,
                                                                    deckId2
                                                                  ];
                                                                }(
                                                                    FFAppState()
                                                                        .currentGameDeckRef1!
                                                                        .id,
                                                                    FFAppState()
                                                                        .currentGameDeckRef2!
                                                                        .id),
                                                              },
                                                            ),
                                                          }, gamesRecordReference);
                                                          // Save player 1
                                                          // Create player1 (loser)
                                                          logFirebaseEvent(
                                                              'VictoryButton_Createplayer1loser');

                                                          var playersRecordReference1 =
                                                              PlayersRecord
                                                                  .createDoc(_model
                                                                      .savedGameDoc2!
                                                                      .reference);
                                                          await playersRecordReference1
                                                              .set(
                                                                  createPlayersRecordData(
                                                            score: 0,
                                                            deckName: _model
                                                                .deck1?.name,
                                                            deckId: _model.deck1
                                                                ?.reference.id,
                                                            crewmateId: _model
                                                                .deck1
                                                                ?.crewmateId,
                                                            crewId: _model
                                                                .deck1?.crewId,
                                                            deckRef: functions
                                                                .fromDeckIdToRef(
                                                                    _model
                                                                        .deck1!
                                                                        .reference
                                                                        .id),
                                                            crewmateRef: functions
                                                                .fromCrewmateIdToRef(
                                                                    _model
                                                                        .deck1!
                                                                        .crewmateId,
                                                                    _model
                                                                        .deck1!
                                                                        .crewId),
                                                          ));
                                                          _model.player1Doc2 =
                                                              PlayersRecord
                                                                  .getDocumentFromData(
                                                                      createPlayersRecordData(
                                                                        score:
                                                                            0,
                                                                        deckName: _model
                                                                            .deck1
                                                                            ?.name,
                                                                        deckId: _model
                                                                            .deck1
                                                                            ?.reference
                                                                            .id,
                                                                        crewmateId: _model
                                                                            .deck1
                                                                            ?.crewmateId,
                                                                        crewId: _model
                                                                            .deck1
                                                                            ?.crewId,
                                                                        deckRef: functions.fromDeckIdToRef(_model
                                                                            .deck1!
                                                                            .reference
                                                                            .id),
                                                                        crewmateRef: functions.fromCrewmateIdToRef(
                                                                            _model.deck1!.crewmateId,
                                                                            _model.deck1!.crewId),
                                                                      ),
                                                                      playersRecordReference1);
                                                          // Save player2
                                                          // Create player2 (victorious)
                                                          logFirebaseEvent(
                                                              'VictoryButton_Createplayer2victorious');

                                                          var playersRecordReference2 =
                                                              PlayersRecord
                                                                  .createDoc(_model
                                                                      .savedGameDoc2!
                                                                      .reference);
                                                          await playersRecordReference2
                                                              .set(
                                                                  createPlayersRecordData(
                                                            score: 1,
                                                            deckName: _model
                                                                .deck2?.name,
                                                            deckId: _model.deck2
                                                                ?.reference.id,
                                                            crewmateId: _model
                                                                .deck2
                                                                ?.crewmateId,
                                                            crewId: _model
                                                                .deck2?.crewId,
                                                            deckRef: functions
                                                                .fromDeckIdToRef(
                                                                    _model
                                                                        .deck2!
                                                                        .reference
                                                                        .id),
                                                            crewmateRef: functions
                                                                .fromCrewmateIdToRef(
                                                                    _model
                                                                        .deck2!
                                                                        .crewmateId,
                                                                    _model
                                                                        .deck2!
                                                                        .crewId),
                                                          ));
                                                          _model.player2Doc2 =
                                                              PlayersRecord
                                                                  .getDocumentFromData(
                                                                      createPlayersRecordData(
                                                                        score:
                                                                            1,
                                                                        deckName: _model
                                                                            .deck2
                                                                            ?.name,
                                                                        deckId: _model
                                                                            .deck2
                                                                            ?.reference
                                                                            .id,
                                                                        crewmateId: _model
                                                                            .deck2
                                                                            ?.crewmateId,
                                                                        crewId: _model
                                                                            .deck2
                                                                            ?.crewId,
                                                                        deckRef: functions.fromDeckIdToRef(_model
                                                                            .deck2!
                                                                            .reference
                                                                            .id),
                                                                        crewmateRef: functions.fromCrewmateIdToRef(
                                                                            _model.deck2!.crewmateId,
                                                                            _model.deck2!.crewId),
                                                                      ),
                                                                      playersRecordReference2);
                                                          logFirebaseEvent(
                                                              'VictoryButton_custom_action');
                                                          _model.hasMatchup2 =
                                                              await actions
                                                                  .checkIfMatchupExists(
                                                            _model.matchupId2!,
                                                          );
                                                          if (_model
                                                              .hasMatchup2!) {
                                                            logFirebaseEvent(
                                                                'VictoryButton_firestore_query');
                                                            _model.existingMatchupDoc2 =
                                                                await queryMatchupsRecordOnce(
                                                              queryBuilder:
                                                                  (matchupsRecord) =>
                                                                      matchupsRecord
                                                                          .where(
                                                                'matchupId',
                                                                isEqualTo: _model
                                                                    .matchupId2,
                                                              ),
                                                              singleRecord:
                                                                  true,
                                                            ).then((s) => s
                                                                    .firstOrNull);
                                                            logFirebaseEvent(
                                                                'VictoryButton_custom_action');
                                                            _model.newScores2 =
                                                                await actions
                                                                    .updateScores(
                                                              FFAppState()
                                                                  .currentGameDeckRef1!
                                                                  .id,
                                                              0,
                                                              FFAppState()
                                                                  .currentGameDeckRef2!
                                                                  .id,
                                                              1,
                                                              _model
                                                                  .existingMatchupDoc2!
                                                                  .scores
                                                                  .toList(),
                                                            );
                                                            logFirebaseEvent(
                                                                'VictoryButton_backend_call');

                                                            await _model
                                                                .existingMatchupDoc2!
                                                                .reference
                                                                .update({
                                                              ...mapToFirestore(
                                                                {
                                                                  'gameIds':
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    _model
                                                                        .savedGameDoc2
                                                                        ?.reference
                                                                        .id
                                                                  ]),
                                                                  'scores':
                                                                      getScoreListFirestoreData(
                                                                    _model
                                                                        .newScores2,
                                                                  ),
                                                                },
                                                              ),
                                                            });
                                                          } else {
                                                            logFirebaseEvent(
                                                                'VictoryButton_custom_action');
                                                            _model.createdScores2 =
                                                                await actions
                                                                    .createScores(
                                                              FFAppState()
                                                                  .currentGameDeckRef1!
                                                                  .id,
                                                              0,
                                                              FFAppState()
                                                                  .currentGameDeckRef2!
                                                                  .id,
                                                              1,
                                                            );
                                                            logFirebaseEvent(
                                                                'VictoryButton_backend_call');

                                                            await MatchupsRecord
                                                                .collection
                                                                .doc()
                                                                .set({
                                                              ...createMatchupsRecordData(
                                                                matchupId: _model
                                                                    .matchupId2,
                                                                crewId: valueOrDefault(
                                                                    currentUserDocument
                                                                        ?.crewId,
                                                                    ''),
                                                              ),
                                                              ...mapToFirestore(
                                                                {
                                                                  'gameIds': [
                                                                    _model
                                                                        .savedGameDoc2
                                                                        ?.reference
                                                                        .id
                                                                  ],
                                                                  'deckIds': (String
                                                                              deckId1,
                                                                          String
                                                                              deckId2) {
                                                                    return [
                                                                      deckId1,
                                                                      deckId2
                                                                    ];
                                                                  }(
                                                                      FFAppState()
                                                                          .currentGameDeckRef1!
                                                                          .id,
                                                                      FFAppState()
                                                                          .currentGameDeckRef2!
                                                                          .id),
                                                                  'scores':
                                                                      getScoreListFirestoreData(
                                                                    _model
                                                                        .createdScores2,
                                                                  ),
                                                                },
                                                              ),
                                                            });
                                                          }
                                                        }

                                                        logFirebaseEvent(
                                                            'VictoryButton_rive_animation');

                                                        _model
                                                            .confettiPlayer2Controllers
                                                            .forEach(
                                                                (controller) {
                                                          controller
                                                                  .reactivate =
                                                              true;
                                                        });
                                                        logFirebaseEvent(
                                                            'VictoryButton_haptic_feedback');
                                                        HapticFeedback
                                                            .vibrate();
                                                        logFirebaseEvent(
                                                            'VictoryButton_alert_dialog');
                                                        confirmDialogResponse =
                                                            await showDialog<
                                                                    bool>(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (alertDialogContext) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                        FFLocalizations.of(context)
                                                                            .getVariableText(
                                                                          enText:
                                                                              'Rematch?',
                                                                          frText:
                                                                              'Revanche ?',
                                                                        ),
                                                                        'Rematch?',
                                                                      )),
                                                                      content: Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                        FFLocalizations.of(context)
                                                                            .getVariableText(
                                                                          enText:
                                                                              'Do you want to rematch?',
                                                                          frText:
                                                                              'Voulez-vous jouer la revanche ?',
                                                                        ),
                                                                        'Do you want to rematch?',
                                                                      )),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              false),
                                                                          child:
                                                                              Text(valueOrDefault<String>(
                                                                            FFLocalizations.of(context).getVariableText(
                                                                              enText: 'Cancel',
                                                                              frText: 'Annuler',
                                                                            ),
                                                                            'Cancel',
                                                                          )),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              true),
                                                                          child:
                                                                              Text(valueOrDefault<String>(
                                                                            FFLocalizations.of(context).getVariableText(
                                                                              enText: 'Confirm',
                                                                              frText: 'Confirmer',
                                                                            ),
                                                                            'Confirm',
                                                                          )),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ) ??
                                                                false;
                                                        if (confirmDialogResponse) {
                                                          logFirebaseEvent(
                                                              'VictoryButton_update_page_state');
                                                          setState(() {
                                                            _model.lifeCounter1 =
                                                                20;
                                                            _model.lifeCounter2 =
                                                                20;
                                                            _model.counter1 = 0;
                                                            _model.counter2 = 0;
                                                            _model.isCounter1 =
                                                                false;
                                                            _model.isCounter2 =
                                                                false;
                                                          });
                                                        } else {
                                                          logFirebaseEvent(
                                                              'VictoryButton_update_app_state');
                                                          setState(() {
                                                            FFAppState()
                                                                    .deck1Selected =
                                                                false;
                                                            FFAppState()
                                                                    .deck2Selected =
                                                                false;
                                                          });
                                                          logFirebaseEvent(
                                                              'VictoryButton_navigate_to');

                                                          context.pushNamed(
                                                              'A_HomePage');
                                                        }
                                                      }

                                                      setState(() {});
                                                    },
                                                  ),
                                              ],
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  1.0, 0.0),
                                              child: FlutterFlowIconButton(
                                                borderColor: Colors.transparent,
                                                borderRadius: 20.0,
                                                borderWidth: 1.0,
                                                buttonSize: 56.0,
                                                icon: Icon(
                                                  Icons.close,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 38.0,
                                                ),
                                                onPressed: () async {
                                                  logFirebaseEvent(
                                                      'C_GAME_VIEW_PAGE_CancelButton_ON_TAP');
                                                  logFirebaseEvent(
                                                      'CancelButton_alert_dialog');
                                                  var confirmDialogResponse =
                                                      await showDialog<bool>(
                                                            context: context,
                                                            builder:
                                                                (alertDialogContext) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                  FFLocalizations.of(
                                                                          context)
                                                                      .getVariableText(
                                                                    enText:
                                                                        'Leave the game?',
                                                                    frText:
                                                                        'Quitter la partie ?',
                                                                  ),
                                                                  'Leave the game?',
                                                                )),
                                                                content: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                  FFLocalizations.of(
                                                                          context)
                                                                      .getVariableText(
                                                                    enText:
                                                                        'Are you sure you want to leave the game?',
                                                                    frText:
                                                                        'Voulez-vous vraiment quitter la partie ?',
                                                                  ),
                                                                  'Are you sure you want to leave the game?',
                                                                )),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            alertDialogContext,
                                                                            false),
                                                                    child: Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getVariableText(
                                                                        enText:
                                                                            'Cancel',
                                                                        frText:
                                                                            'Annuler',
                                                                      ),
                                                                      'Cancel',
                                                                    )),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            alertDialogContext,
                                                                            true),
                                                                    child: Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getVariableText(
                                                                        enText:
                                                                            'Confirm',
                                                                        frText:
                                                                            'Confirmer',
                                                                      ),
                                                                      'Confirm',
                                                                    )),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ) ??
                                                          false;
                                                  if (confirmDialogResponse) {
                                                    logFirebaseEvent(
                                                        'CancelButton_navigate_to');

                                                    context.pushNamed(
                                                        'A_HomePage');
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                            .animateOnPageLoad(animationsMap[
                                                'rowOnPageLoadAnimation2']!)
                                            .animateOnActionTrigger(
                                                animationsMap[
                                                    'rowOnActionTriggerAnimation2']!,
                                                hasBeenTriggered:
                                                    hasRowTriggered2),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_model.hasDice && (_model.diceResult2 == 1))
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 250.0,
                            height: 250.0,
                            child: RiveAnimation.asset(
                              'assets/rive_animations/3226-6789-shakeable-dice.riv',
                              artboard: 'New Artboard',
                              fit: BoxFit.cover,
                              controllers: _model.dice21Controllers,
                            ),
                          ),
                        ),
                      if (_model.hasDice && (_model.diceResult2 == 2))
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 250.0,
                            height: 250.0,
                            child: RiveAnimation.asset(
                              'assets/rive_animations/3226-6789-shakeable-dice.riv',
                              artboard: 'New Artboard',
                              fit: BoxFit.cover,
                              controllers: _model.dice22Controllers,
                            ),
                          ),
                        ),
                      if (_model.hasDice && (_model.diceResult2 == 3))
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 250.0,
                            height: 250.0,
                            child: RiveAnimation.asset(
                              'assets/rive_animations/3226-6789-shakeable-dice.riv',
                              artboard: 'New Artboard',
                              fit: BoxFit.cover,
                              controllers: _model.dice23Controllers,
                            ),
                          ),
                        ),
                      if (_model.hasDice && (_model.diceResult2 == 4))
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 250.0,
                            height: 250.0,
                            child: RiveAnimation.asset(
                              'assets/rive_animations/3226-6789-shakeable-dice.riv',
                              artboard: 'New Artboard',
                              fit: BoxFit.cover,
                              controllers: _model.dice24Controllers,
                            ),
                          ),
                        ),
                      if (_model.hasDice && (_model.diceResult2 == 5))
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 250.0,
                            height: 250.0,
                            child: RiveAnimation.asset(
                              'assets/rive_animations/3226-6789-shakeable-dice.riv',
                              artboard: 'New Artboard',
                              fit: BoxFit.cover,
                              controllers: _model.dice25Controllers,
                            ),
                          ),
                        ),
                      if (_model.hasDice && (_model.diceResult2 == 6))
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 250.0,
                            height: 250.0,
                            child: RiveAnimation.asset(
                              'assets/rive_animations/3226-6789-shakeable-dice.riv',
                              artboard: 'New Artboard',
                              fit: BoxFit.cover,
                              controllers: _model.dice26Controllers,
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
  }
}
