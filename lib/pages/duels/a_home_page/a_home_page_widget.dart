import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'a_home_page_model.dart';
export 'a_home_page_model.dart';

class AHomePageWidget extends StatefulWidget {
  const AHomePageWidget({Key? key}) : super(key: key);

  @override
  _AHomePageWidgetState createState() => _AHomePageWidgetState();
}

class _AHomePageWidgetState extends State<AHomePageWidget> {
  late AHomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AHomePageModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'A_HomePage'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('A_HOME_A_HomePage_ON_INIT_STATE');
      logFirebaseEvent('A_HomePage_update_app_state');
      setState(() {
        FFAppState().currentGameDeckRef1 =
            FirebaseFirestore.instance.doc('/decks/0YMtzxv9Gae9WsgfPcjG');
        FFAppState().currentGameDeckRef2 =
            FirebaseFirestore.instance.doc('/decks/0YMtzxv9Gae9WsgfPcjG');
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

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            logFirebaseEvent('A_HOME_FloatingActionButton_9dlv0anm_ON_');
            logFirebaseEvent('FloatingActionButton_navigate_to');

            context.pushNamed('D_About');
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          elevation: 8.0,
          child: Icon(
            Icons.question_mark_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 24.0,
          ),
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          logFirebaseEvent(
                              'A_HOME_PAGE_PAGE_StartButton_ON_TAP');
                          if (_model.switchValue!) {
                            logFirebaseEvent('StartButton_navigate_to');

                            context.pushNamed('B_GameForm');
                          } else {
                            logFirebaseEvent('StartButton_navigate_to');

                            context.pushNamed(
                              'C_GameView',
                              queryParameters: {
                                'isRanked': serializeParam(
                                  false,
                                  ParamType.bool,
                                ),
                              }.withoutNulls,
                            );
                          }
                        },
                        child: Material(
                          color: Colors.transparent,
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            height: MediaQuery.sizeOf(context).height * 0.15,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: Image.asset(
                                  'assets/images/images.jpeg',
                                ).image,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              color: Colors.transparent,
                              elevation: 4.0,
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'zd3bzna3' /* New match */,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        fontFamily: 'Cinzel Decorative',
                                        fontSize: 34.0,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 2.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
                    child: Stack(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      children: [
                        // Show "Partie Crew" toggle only for users with a real
                        // (non-solo) crew. Others see a prompt to join/create.
                        AuthUserStreamWidget(
                          builder: (context) {
                            final hasRealCrew =
                                currentUserDocument?.hasRealCrew ?? false;
                            if (hasRealCrew) {
                              return Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 4.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          '5upd8f28' /* Crew game */,
                                        ),
                                        textAlign: TextAlign.start,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _model.switchValue ??= false,
                                      onChanged: (newValue) async {
                                        setState(() =>
                                            _model.switchValue = newValue!);
                                      },
                                      activeColor: FlutterFlowTheme.of(context)
                                          .tertiary,
                                      activeTrackColor:
                                          FlutterFlowTheme.of(context).tertiary,
                                      inactiveTrackColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      inactiveThumbColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                    ),
                                  ],
                                ),
                              );
                            }
                            // No crew or solo crew → prompt to join/create.
                            return GestureDetector(
                              onTap: () => context.pushNamed('A_CrewMenu'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText
                                        .withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.group_add_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rejoindre ou créer un crew',
                                      style: TextStyle(
                                        fontFamily: 'Noto Sans',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText
                                          .withOpacity(0.6),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (true) // TODO: remove before prod
                  FFButtonWidget(
                    onPressed: () async {
                      logFirebaseEvent('A_HOME_LOG_OUT_V0_11_BTN_ON_TAP');
                      logFirebaseEvent('Button_auth');
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();

                      context.goNamedAuth('EntryPage', context.mounted);
                    },
                    text: FFLocalizations.of(context).getText(
                      'bfqx9xex' /* log out v0.11 */,
                    ),
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Cinzel Decorative',
                                color: Colors.white,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
