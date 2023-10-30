import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/page_component/deck_edit/deck_edit_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'deck_view_model.dart';
export 'deck_view_model.dart';

class DeckViewWidget extends StatefulWidget {
  const DeckViewWidget({
    Key? key,
    required this.deck,
  }) : super(key: key);

  final DecksRecord? deck;

  @override
  _DeckViewWidgetState createState() => _DeckViewWidgetState();
}

class _DeckViewWidgetState extends State<DeckViewWidget> {
  late DeckViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeckViewModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('DECK_VIEW_COMP_DeckView_ON_INIT_STATE');
      _model.deckScore = await actions.getDeckScore(
        widget.deck!.deckId,
      );
      setState(() {});
    });

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
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 0.15,
        constraints: BoxConstraints(
          minHeight: 130.0,
          maxHeight: 150.0,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x33000000),
              offset: Offset(0.0, 2.0),
              spreadRadius: 0.5,
            )
          ],
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            logFirebaseEvent('DECK_VIEW_COMP_DeckCard_ON_TAP');
            if ((_model.deckScore?.wins == 0) &&
                (_model.deckScore?.losses == 0)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No game yet',
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                  duration: Duration(milliseconds: 4000),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                ),
              );
            } else {
              context.pushNamed(
                'C2_GameList',
                queryParameters: {
                  'filteredDeckList': serializeParam(
                    [],
                    ParamType.String,
                    true,
                  ),
                  'deckId': serializeParam(
                    widget.deck?.reference.id,
                    ParamType.String,
                  ),
                }.withoutNulls,
              );
            }
          },
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: FlutterFlowTheme.of(context).primary,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              width: 100.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(
                    'assets/images/images.jpeg',
                  ).image,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4.0,
                    color: Color(0x33000000),
                    offset: Offset(0.0, 2.0),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).width * 0.2,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4.0,
                            color: Color(0x33000000),
                            offset: Offset(0.0, 2.0),
                          )
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.2,
                        height: MediaQuery.sizeOf(context).width * 0.2,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          valueOrDefault<String>(
                            widget.deck?.avatarUrl,
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/magic-6zjv9f/assets/9e5l347v0vwn/output-onlinegiftools.gif',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            valueOrDefault<String>(
                              widget.deck?.name,
                              'Deck name',
                            ).maybeHandleOverflow(
                              maxChars: 8,
                              replacement: '…',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Cinzel Decorative',
                                  fontSize: 24.0,
                                  letterSpacing: 0.9,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 4.0, 0.0, 4.0),
                            child: FutureBuilder<CrewmatesRecord>(
                              future: CrewmatesRecord.getDocumentOnce(
                                  widget.deck!.crewmateRef!),
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
                                final ownerCrewmatesRecord = snapshot.data!;
                                return Text(
                                  valueOrDefault<String>(
                                    ownerCrewmatesRecord.name,
                                    'Owner',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: 'Noto Sans',
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                );
                              },
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 4.0, 0.0, 0.0),
                                  child: Container(
                                    width: 150.0,
                                    height: 28.0,
                                    decoration: BoxDecoration(),
                                    child: Builder(
                                      builder: (context) {
                                        final colors =
                                            widget.deck?.colors?.toList() ?? [];
                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: colors.length,
                                          itemBuilder: (context, colorsIndex) {
                                            final colorsItem =
                                                colors[colorsIndex];
                                            return Stack(
                                              children: [
                                                if (colorsItem == 'Black')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.00, 1.00),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  4.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderColor:
                                                            Colors.transparent,
                                                        borderRadius: 20.0,
                                                        borderWidth: 1.0,
                                                        buttonSize: 28.0,
                                                        fillColor:
                                                            Color(0xFF4A4A4A),
                                                        icon: Icon(
                                                          FFIcons.kblack,
                                                          color: Colors.white,
                                                          size: 13.0,
                                                        ),
                                                        onPressed: true
                                                            ? null
                                                            : () {
                                                                print(
                                                                    'Black pressed ...');
                                                              },
                                                      ),
                                                    ),
                                                  ),
                                                if (colorsItem == 'White')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.10, 1.00),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  4.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderColor:
                                                            Colors.transparent,
                                                        borderRadius: 20.0,
                                                        borderWidth: 1.0,
                                                        buttonSize: 28.0,
                                                        fillColor:
                                                            Color(0xFFF3ECA0),
                                                        icon: Icon(
                                                          FFIcons.kwhite,
                                                          color:
                                                              Color(0xFF535353),
                                                          size: 13.0,
                                                        ),
                                                        onPressed: true
                                                            ? null
                                                            : () {
                                                                print(
                                                                    'White pressed ...');
                                                              },
                                                      ),
                                                    ),
                                                  ),
                                                if (colorsItem == 'Blue')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.10, 1.00),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  4.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderColor:
                                                            Colors.transparent,
                                                        borderRadius: 20.0,
                                                        borderWidth: 1.0,
                                                        buttonSize: 28.0,
                                                        fillColor:
                                                            Color(0xFF59A4E7),
                                                        icon: Icon(
                                                          FFIcons.kblue,
                                                          color: Colors.white,
                                                          size: 13.0,
                                                        ),
                                                        onPressed: true
                                                            ? null
                                                            : () {
                                                                print(
                                                                    'Blue pressed ...');
                                                              },
                                                      ),
                                                    ),
                                                  ),
                                                if (colorsItem == 'Green')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.10, 1.00),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  4.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderColor:
                                                            Colors.transparent,
                                                        borderRadius: 20.0,
                                                        borderWidth: 1.0,
                                                        buttonSize: 28.0,
                                                        fillColor:
                                                            Color(0xFF7BBC60),
                                                        icon: Icon(
                                                          FFIcons.kgreen,
                                                          color: Colors.white,
                                                          size: 13.0,
                                                        ),
                                                        onPressed: true
                                                            ? null
                                                            : () {
                                                                print(
                                                                    'Green pressed ...');
                                                              },
                                                      ),
                                                    ),
                                                  ),
                                                if (colorsItem == 'Red')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.10, 1.00),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  4.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderColor:
                                                            Color(0x004B39EF),
                                                        borderRadius: 20.0,
                                                        borderWidth: 1.0,
                                                        buttonSize: 28.0,
                                                        fillColor:
                                                            Color(0xFFFB8080),
                                                        icon: Icon(
                                                          FFIcons.kred,
                                                          color: Colors.white,
                                                          size: 13.0,
                                                        ),
                                                        onPressed: true
                                                            ? null
                                                            : () {
                                                                print(
                                                                    'Red pressed ...');
                                                              },
                                                      ),
                                                    ),
                                                  ),
                                              ],
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
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 6.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Builder(
                                  builder: (context) => FlutterFlowIconButton(
                                    borderColor:
                                        FlutterFlowTheme.of(context).primary,
                                    borderRadius: 20.0,
                                    borderWidth: 1.0,
                                    buttonSize: 32.0,
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    icon: Icon(
                                      Icons.edit_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 16.0,
                                    ),
                                    onPressed: () async {
                                      logFirebaseEvent(
                                          'DECK_VIEW_COMP_Edit_ON_TAP');
                                      await showAlignedDialog(
                                        context: context,
                                        isGlobal: true,
                                        avoidOverflow: false,
                                        targetAnchor:
                                            AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        followerAnchor:
                                            AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        builder: (dialogContext) {
                                          return Material(
                                            color: Colors.transparent,
                                            child: DeckEditWidget(
                                              title: FFLocalizations.of(context)
                                                  .getText(
                                                'x8wz0s6u' /* Edit a deck */,
                                              ),
                                              editedDeck: widget.deck!,
                                            ),
                                          );
                                        },
                                      ).then((value) => setState(() {}));
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(1.00, 1.00),
                                child: RichText(
                                  textScaleFactor:
                                      MediaQuery.of(context).textScaleFactor,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: valueOrDefault<String>(
                                          _model.deckScore?.wins?.toString(),
                                          '0',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      TextSpan(
                                        text:
                                            FFLocalizations.of(context).getText(
                                          'u0i2ln3j' /*  -  */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      TextSpan(
                                        text: valueOrDefault<String>(
                                          _model.deckScore?.losses?.toString(),
                                          '0',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      )
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          fontFamily: 'Noto Sans',
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Align(
                                alignment: AlignmentDirectional(1.00, -1.00),
                                child: SelectionArea(
                                    child: Text(
                                  valueOrDefault<String>(
                                    formatNumber(
                                      _model.deckScore?.winrate,
                                      formatType: FormatType.percent,
                                    ),
                                    '0',
                                  ),
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium,
                                )),
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
          ),
        ),
      ),
    );
  }
}
