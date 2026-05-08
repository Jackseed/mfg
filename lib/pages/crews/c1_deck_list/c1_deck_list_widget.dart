import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/deck_form/deck_form_widget.dart';
import '/small_components/deck_view/deck_view_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'c1_deck_list_model.dart';
export 'c1_deck_list_model.dart';

/// View mode for the deck list. Templates are the player's canonical decks
/// (`isTemplate: true`); snapshots are the per-tournament imports (default).
enum _DeckListView { snapshots, templates }

class C1DeckListWidget extends StatefulWidget {
  const C1DeckListWidget({Key? key}) : super(key: key);

  @override
  _C1DeckListWidgetState createState() => _C1DeckListWidgetState();
}

class _C1DeckListWidgetState extends State<C1DeckListWidget> {
  late C1DeckListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Currently selected view: snapshots (all imports) or templates only.
  _DeckListView _view = _DeckListView.snapshots;

  // Lazy-loaded set of crewmate IDs that belong to actual crew members
  // (those with userReference set). Opponents imported from tournaments have
  // no userReference and are excluded from the deck list.
  Future<Set<String>>? _memberIdsFuture;

  // Batch-loaded scores for all visible decks — replaces N individual queries.
  Future<Map<String, DeckScoreStruct>>? _scoresFuture;
  // Sorted deck IDs used for the last score load; prevents redundant reloads.
  List<String> _scoredDeckIds = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => C1DeckListModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'C1_DeckList'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Returns the set of crewmate document IDs that should be visible in the
  /// deck list for the current user:
  ///
  /// 1. ALL crewmates across every crew where `userId == currentUserUid`
  ///    (covers tournament org-crews created by Spicerack import — the user
  ///    may have one crewmate per org-crew, each with a different doc ID).
  /// 2. All crewmates in the user's personal crew that have a `userReference`
  ///    (real friends, not tournament opponents).
  Future<Set<String>> _fetchMemberCrewmateIds() async {
    final Set<String> ids = {};
    final uid = currentUserUid;

    // Collection-group query: find every crewmate doc that belongs to the
    // current user via userReference (set by import + manual crew join).
    // Note: crewmates.userId = Spicerack integer ID, NOT the Firebase UID.
    if (currentUserReference != null) {
      final snap = await FirebaseFirestore.instance
          .collectionGroup('crewmates')
          .where('userReference', isEqualTo: currentUserReference)
          .get();
      ids.addAll(snap.docs.map((d) => d.id));
    }

    // Personal crew: include ALL crewmates (userReference may not be set on
    // older data — don't filter it out or the user's own decks disappear).
    final crewRef = currentUserDocument?.crewRef;
    if (crewRef != null) {
      final snap = await crewRef.collection('crewmates').get();
      ids.addAll(snap.docs.map((d) => d.id));
    }

    // Fallback: always include the user's own crewmate doc even when the
    // collection-group query and crew query both come up empty (pre-import data).
    if (currentUserDocument?.crewmateRef != null) {
      ids.add(currentUserDocument!.crewmateRef!.id);
    }

    return ids;
  }

  /// Fetches all matchups that involve any of [deckIds] in one batch query
  /// (using arrayContainsAny, max 30 per chunk) and computes BO3 + game stats
  /// for each deck. Much faster than one query per deck.
  Future<Map<String, DeckScoreStruct>> _loadScores(List<String> deckIds) async {
    if (deckIds.isEmpty) return {};

    final wins = <String, int>{for (final id in deckIds) id: 0};
    final losses = <String, int>{for (final id in deckIds) id: 0};
    final matchWins = <String, int>{for (final id in deckIds) id: 0};
    final matchLosses = <String, int>{for (final id in deckIds) id: 0};

    // Firestore arrayContainsAny allows max 30 values → chunk as needed.
    for (int i = 0; i < deckIds.length; i += 30) {
      final chunk = deckIds.sublist(i, (i + 30).clamp(0, deckIds.length));
      try {
        final snap = await FirebaseFirestore.instance
            .collection('matchups')
            .where('deckIds', arrayContainsAny: chunk)
            .get();

        for (final doc in snap.docs) {
          final matchup = doc.data();
          final rawScores = matchup['scores'];
          if (rawScores == null || rawScores is! List) continue;
          final matchScores =
              (rawScores as List).cast<Map<String, dynamic>>();

          for (final entry in matchScores) {
            final thisDeckId = entry['deckId'] as String?;
            if (thisDeckId == null || !wins.containsKey(thisDeckId)) continue;

            final myScore = (entry['score'] as num?)?.toInt() ?? 0;
            final oppScore = matchScores
                .where((s) => s['deckId'] != thisDeckId)
                .fold(0, (s, e) => s + ((e['score'] as num?)?.toInt() ?? 0));

            wins[thisDeckId] = wins[thisDeckId]! + myScore;
            losses[thisDeckId] = losses[thisDeckId]! + oppScore;
            if (myScore > oppScore) {
              matchWins[thisDeckId] = matchWins[thisDeckId]! + 1;
            } else if (myScore < oppScore) {
              matchLosses[thisDeckId] = matchLosses[thisDeckId]! + 1;
            }
          }
        }
      } catch (_) {}
    }

    final result = <String, DeckScoreStruct>{};
    for (final id in deckIds) {
      final w = wins[id]!;
      final l = losses[id]!;
      final total = w + l;
      result[id] = DeckScoreStruct(
        wins: w,
        losses: l,
        winrate: total > 0 ? w / total.toDouble() : 0.0,
        matchWins: matchWins[id],
        matchLosses: matchLosses[id],
      );
    }
    return result;
  }

  /// Updates [_scoresFuture] synchronously during build if the visible deck
  /// list changed. Safe to call from build() — mutates the field directly
  /// without setState; the FutureBuilder below picks up the new future in the
  /// same build pass, no extra frame needed.
  void _updateScoresFutureIfNeeded(List<DecksRecord> decks) {
    final newIds = (decks
            .map((d) => d.deckId)
            .where((id) => id.isNotEmpty)
            .toList()
          ..sort());
    if (newIds.join(',') == _scoredDeckIds.join(',')) return;
    _scoredDeckIds = newIds;
    _scoresFuture = _loadScores(List.from(newIds));
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
      builder: (context) {
        final crewId = valueOrDefault(currentUserDocument?.crewId, '');

        return FutureBuilder<Set<String>>(
          future: _memberIdsFuture ??= _fetchMemberCrewmateIds(),
          builder: (context, crewSnap) {
            // memberIds == null → still loading
            final memberIds = crewSnap.data;

            // Stable cache key: forces StreamRequestManager to create a new
            // stream when the member ID set changes after the future resolves.
            final cacheKey = memberIds == null
                ? '__loading__'
                : '${crewId}_${(memberIds.toList()..sort()).join(',')}';

            return StreamBuilder<List<DecksRecord>>(
        stream: _model.deckListQuery(
                uniqueQueryKey: cacheKey,
          requestFn: () {
                  if (memberIds == null) {
                    // Future not yet resolved — hold off, show empty.
                    return Stream.value(<DecksRecord>[]);
                  }
                  if (crewId.isNotEmpty) {
                    // Real crew: fetch all crew decks, filter by real members
                    // in-memory below.
                    return queryDecksRecord(
                      queryBuilder: (q) =>
                          q.where('crewId', isEqualTo: crewId),
                    );
                  } else if (memberIds.isNotEmpty) {
                    // Solo import user: query directly by their crewmate IDs
                    // (one per org-crew they participated in, max 30).
                    return queryDecksRecord(
                      queryBuilder: (q) => q.where('crewmateId',
                          whereIn: memberIds.take(30).toList()),
                    );
                  } else {
                    return Stream.value(<DecksRecord>[]);
                  }
          },
        ),
        builder: (context, snapshot) {
          // Show spinner while member IDs are still loading (prevents the
          // "pas de deck" flash caused by the empty Stream.value([])).
          if (memberIds == null || !snapshot.hasData) {
            return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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
          List<DecksRecord> c1DeckListDecksRecordList = snapshot.data!;
          return GestureDetector(
            onTap: () => _model.unfocusNode.canRequestFocus
                ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                : FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              floatingActionButton: Builder(
                builder: (context) => FloatingActionButton.extended(
                  onPressed: () async {
                    logFirebaseEvent(
                        'C1_DECK_LIST_FloatingActionButton_5531ea');
                    logFirebaseEvent('FloatingActionButton_alert_dialog');
                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return Dialog(
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          alignment: AlignmentDirectional(0.0, 0.0)
                              .resolve(Directionality.of(context)),
                          child: GestureDetector(
                            onTap: () => _model.unfocusNode.canRequestFocus
                                ? FocusScope.of(context)
                                    .requestFocus(_model.unfocusNode)
                                : FocusScope.of(context).unfocus(),
                            child: DeckFormWidget(),
                          ),
                        );
                      },
                    ).then((value) => setState(() {}));
                  },
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  icon: Icon(
                    Icons.add,
                  ),
                  elevation: 8.0,
                  label: Text(
                    FFLocalizations.of(context).getText(
                      'xyd4oyif' /* Add deck */,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Noto Sans',
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: false,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 60.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'C1_DECK_LIST_arrow_back_rounded_ICN_ON_T');
                    logFirebaseEvent('IconButton_navigate_back');
                    context.pop();
                  },
                ),
                title: Text(
                  FFLocalizations.of(context).getText(
                    '8oyacj3o' /* DECKS */,
                  ),
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
                actions: [],
                centerTitle: true,
                elevation: 2.0,
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
                  child: Stack(
                    children: [
                      if (true)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: FutureBuilder<Set<String>>(
                            future: _memberIdsFuture ??=
                                _fetchMemberCrewmateIds(),
                            builder: (context, crewSnap) {
                              // For a real crew: the Firestore query returns all
                              // crew decks (including opponents'); filter to
                              // real members only.
                              // For solo import: decks are already scoped to
                              // the user's crewmate IDs by the whereIn query.
                              final visibleDecks = (crewId.isNotEmpty &&
                                      memberIds != null)
                                  ? c1DeckListDecksRecordList
                                      .where((d) =>
                                          d.crewmateId.isEmpty ||
                                          memberIds.contains(d.crewmateId))
                                      .toList()
                                  : c1DeckListDecksRecordList;

                              // Partition into templates (canonical per-player
                              // decks) and snapshots (per-tournament imports).
                              final templates = visibleDecks
                                  .where((d) =>
                                      d.hasIsTemplate() && d.isTemplate)
                                  .toList();
                              final snapshots = visibleDecks
                                  .where((d) =>
                                      !d.hasIsTemplate() || !d.isTemplate)
                                  .toList();

                              final deckList = _view == _DeckListView.templates
                                  ? templates
                                  : snapshots;

                              // Update batch scores synchronously — the
                              // FutureBuilder below picks it up this frame.
                              _updateScoresFutureIfNeeded(visibleDecks.toList());

                              return Column(
                                children: [
                                  _buildViewToggle(
                                    context,
                                    templatesCount: templates.length,
                                    snapshotsCount: snapshots.length,
                                  ),
                                  Expanded(
                                    child: deckList.isEmpty
                                        ? _buildEmptyForView(context)
                                        : FutureBuilder<Map<String, DeckScoreStruct>>(
                                            future: _scoresFuture,
                                            builder: (ctx, scoresSnap) {
                                              final scoresMap = scoresSnap.data ?? {};
                                              return ListView.builder(
                                                padding: EdgeInsets.zero,
                                                scrollDirection: Axis.vertical,
                                                itemCount: deckList.length,
                                                itemBuilder:
                                                    (context, deckListIndex) {
                                                  final deckListItem =
                                                      deckList[deckListIndex];
                                                  final child = DeckViewWidget(
                                                    key: Key(
                                                        'Keyp06_${deckListIndex}_of_${deckList.length}'),
                                                    deck: deckListItem,
                                                    preloadedScore: scoresMap[deckListItem.deckId],
                                                  );
                                                  // Templates open a history
                                                  // sheet showing every snapshot
                                                  // linked via templateRef.
                                                  if (_view ==
                                                      _DeckListView.templates) {
                                                    return GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTap: () =>
                                                          _showTemplateHistory(
                                                              context,
                                                              deckListItem),
                                                      child: child,
                                                    );
                                                  }
                                                  return child;
                                                },
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
        );
      },
    );
  }

  /// Segmented toggle switching the list between snapshots (default) and
  /// templates (canonical decks of the crew's players).
  Widget _buildViewToggle(
    BuildContext context, {
    required int templatesCount,
    required int snapshotsCount,
  }) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    Widget chip(String label, int count, _DeckListView target) {
      final selected = _view == target;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _view = target),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withOpacity(0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$label  ·  $count',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: selected ? accent : accent.withOpacity(0.55),
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            chip('SNAPSHOTS', snapshotsCount, _DeckListView.snapshots),
            chip('TEMPLATES', templatesCount, _DeckListView.templates),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyForView(BuildContext context) {
    final isTemplates = _view == _DeckListView.templates;
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isTemplates ? Icons.bookmark_border : Icons.auto_awesome_outlined,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 56,
          ),
          SizedBox(height: 12),
          Text(
            isTemplates
                ? 'No templates yet'
                : 'No snapshots yet',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Cinzel Decorative',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 16,
                ),
          ),
          SizedBox(height: 4),
          Text(
            isTemplates
                ? 'Promote any snapshot into a template from the tournament detail bottom sheet.'
                : 'Import a Spicerack event or add a deck manually.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Noto Sans',
                  color: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.55),
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet that lists every snapshot linked to the given template via
  /// `templateRef == template.reference`. Lightweight stand-in for the full
  /// deck_detail page — can be replaced with a dedicated route later.
  Future<void> _showTemplateHistory(
    BuildContext context,
    DecksRecord template,
  ) async {
    final accent = FlutterFlowTheme.of(context).primaryText;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  if (template.hasAvatarUrl() && template.avatarUrl.isNotEmpty)
                    ClipOval(
                      child: Image.network(
                        template.avatarUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            SizedBox(width: 40, height: 40),
                      ),
                    ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                fontFamily: 'Cinzel Decorative',
                                color: accent,
                                fontSize: 18,
                              ),
                        ),
                        if (template.avatarName.isNotEmpty)
                          Text(
                            template.avatarName,
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              color: accent.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Divider(
                height: 1,
                color: accent.withOpacity(0.15),
              ),
              SizedBox(height: 10),
              Text(
                'SNAPSHOTS LINKED',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: accent.withOpacity(0.55),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 8),
              Flexible(
                child: FutureBuilder<List<DecksRecord>>(
                  future: queryDecksRecordOnce(
                    queryBuilder: (q) =>
                        q.where('templateRef', isEqualTo: template.reference),
                  ),
                  builder: (ctx, snap) {
                    if (!snap.hasData) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SpinKitFadingFour(
                            color: Color(0xFFE6486F),
                            size: 28,
                          ),
                        ),
                      );
                    }
                    final snapshots = snap.data!;
                    if (snapshots.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'No snapshots yet. Tag a tournament deck as "this is my deck" to link it here.',
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            color: accent.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshots.length,
                      itemBuilder: (_, i) {
                        final s = snapshots[i];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.bookmark_outline,
                                  size: 16,
                                  color: accent.withOpacity(0.55)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.name.isNotEmpty
                                      ? s.name
                                      : s.avatarName,
                                  style: TextStyle(
                                    fontFamily: 'Noto Sans',
                                    color: accent.withOpacity(0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (s.hasSpicerackDecklistId() &&
                                  s.spicerackDecklistId > 0)
                                Text(
                                  '#${s.spicerackDecklistId}',
                                  style: TextStyle(
                                    fontFamily: 'Noto Sans',
                                    color: accent.withOpacity(0.35),
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
