import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/page_component/deck_edit/deck_edit_widget.dart';
import '/custom_code/actions/index.dart' as actions;
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
    this.preloadedScore,
  }) : super(key: key);

  final DecksRecord? deck;
  /// When provided by a parent that has already batch-loaded all scores,
  /// the widget skips its own Firestore query and uses this directly.
  final DeckScoreStruct? preloadedScore;

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
      if (widget.preloadedScore != null) {
        // Score was batch-loaded by the parent — use it directly.
        _model.deckScore = widget.preloadedScore;
      } else {
        // Fallback: individual query (used when widget is shown standalone).
        logFirebaseEvent('DeckView_custom_action');
        _model.deckScore = await actions.getDeckScore(
          widget.deck!.deckId,
        );
        logFirebaseEvent('DeckView_update_component_state');
      }
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void didUpdateWidget(DeckViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent provides a freshly-loaded score, apply it immediately.
    if (widget.preloadedScore != null &&
        widget.preloadedScore != oldWidget.preloadedScore) {
      setState(() {
        _model.deckScore = widget.preloadedScore;
      });
    }
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final matchW = _model.deckScore?.matchWins ?? 0;
    final matchL = _model.deckScore?.matchLosses ?? 0;
    final gameW = _model.deckScore?.wins ?? 0;
    final gameL = _model.deckScore?.losses ?? 0;
    final winrate = _model.deckScore?.winrate ?? 0.0;
    final hasGames = gameW > 0 || gameL > 0;

    // Border / badge colour mirrors B3 card convention.
    final Color resultColor;
    if (!hasGames) {
      resultColor = const Color(0xFF95A5A6); // gray – no games yet
    } else if (matchW > matchL) {
      resultColor = const Color(0xFF2ECC71); // green – winning record
    } else if (matchW < matchL) {
      resultColor = const Color(0xFFE74C3C); // red – losing record
    } else {
      resultColor = const Color(0xFFF1C40F); // yellow – even
    }

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        onTap: () async {
          logFirebaseEvent('DECK_VIEW_COMP_DeckCard_ON_TAP');
          if (!hasGames) {
            logFirebaseEvent('DeckCard_show_snack_bar');
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  FFLocalizations.of(context).languageCode == 'fr'
                      ? 'Aucune partie sauvegardée.'
                      : 'No game yet.',
                  style: GoogleFonts.getFont(
                    'Noto Sans',
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                ),
                duration: const Duration(milliseconds: 4000),
                backgroundColor: FlutterFlowTheme.of(context).primary,
              ),
            );
          } else {
            logFirebaseEvent('DeckCard_navigate_to');
            context.pushNamed(
              'C2_GameList',
              queryParameters: {
                'filteredDeckList': serializeParam([], ParamType.String, true),
                'deckId': serializeParam(
                    widget.deck?.reference.id, ParamType.String),
              }.withoutNulls,
            );
          }
        },
        // ── Modern card styled like B3 matchup cards ──────────────────
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: resultColor.withOpacity(0.35), width: 1),
            boxShadow: const [
              BoxShadow(
                  blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ──────────────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FlutterFlowTheme.of(context).primary,
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 4,
                        color: Color(0x33000000),
                        offset: Offset(0, 2))
                  ],
                ),
                child: Image.network(
                  valueOrDefault<String>(
                    widget.deck?.avatarUrl,
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/magic-6zjv9f/assets/9e5l347v0vwn/output-onlinegiftools.gif',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // ── Deck info ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Deck name + edit icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            valueOrDefault<String>(widget.deck?.name, 'Deck'),
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Cinzel Decorative',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  lineHeight: 1.2,
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () async {
                            logFirebaseEvent('DECK_VIEW_COMP_Edit_ON_TAP');
                            logFirebaseEvent('Edit_alert_dialog');
                            await showDialog(
                              context: context,
                              builder: (dialogContext) => Dialog(
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: DeckEditWidget(
                                  title: FFLocalizations.of(context)
                                      .getText('x8wz0s6u' /* Edit a deck */),
                                  editedDeck: widget.deck!,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          child: Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: FlutterFlowTheme.of(context)
                                .primaryText
                                .withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                    // Owner name (async)
                    if (widget.deck?.crewmateRef != null) ...[
                      const SizedBox(height: 2),
                      FutureBuilder<CrewmatesRecord>(
                        future: CrewmatesRecord.getDocumentOnce(
                            widget.deck!.crewmateRef!),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox(height: 13);
                          return Text(
                            valueOrDefault<String>(snap.data?.name, ''),
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              color: FlutterFlowTheme.of(context)
                                  .primaryText
                                  .withOpacity(0.55),
                              fontSize: 11,
                              height: 1.2,
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Color identity dots
                    Row(
                      children: (widget.deck?.colors?.toList() ?? [])
                          .map((color) {
                        final dot = const {
                          'White': Color(0xFFF3ECA0),
                          'Blue': Color(0xFF59A4E7),
                          'Black': Color(0xFF4A4A4A),
                          'Red': Color(0xFFFB8080),
                          'Green': Color(0xFF7BBC60),
                        }[color];
                        if (dot == null) return const SizedBox.shrink();
                        return Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dot,
                            border: Border.all(
                                color: Colors.black26, width: 0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Score badge ──────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BO3 record (coloured pill)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$matchW - $matchL',
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        color: resultColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Game record + winrate
                  Text(
                    '$gameW-$gameL · ${valueOrDefault<String>(formatNumber(winrate, formatType: FormatType.percent), '0%')}',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.45),
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
