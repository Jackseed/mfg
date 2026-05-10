import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/page_component/deck_form/deck_form_widget.dart';
import '/small_components/deck_view/deck_view_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'c1_deck_list_model.dart';
export 'c1_deck_list_model.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// One canonical "deck" entry in the DECKS view.
/// [representative] is the root of the templateRef chain (shown as the card).
/// [members] is the full family (root + all linked snapshots).
class _DeckGroup {
  final DecksRecord representative;
  final List<DecksRecord> members;
  const _DeckGroup({required this.representative, required this.members});
}

/// Mutable score accumulator used during per-tournament loading.
class _MutableScore {
  int wins = 0, losses = 0, matchWins = 0, matchLosses = 0;

  void addGame(int my, int opp) {
    wins += my;
    losses += opp;
    if (my > opp) matchWins++;
    else if (my < opp) matchLosses++;
  }

  DeckScoreStruct toStruct() {
    final total = wins + losses;
    return DeckScoreStruct(
      wins: wins,
      losses: losses,
      matchWins: matchWins,
      matchLosses: matchLosses,
      winrate: total > 0 ? wins / total.toDouble() : 0.0,
    );
  }
}

// ---------------------------------------------------------------------------
// View enum
// ---------------------------------------------------------------------------

/// DECKS = one card per canonical deck (grouped by templateRef chain).
/// TOURNOIS = one card per tournament participation.
enum _DeckListView { decks, tournois }

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class C1DeckListWidget extends StatefulWidget {
  const C1DeckListWidget({Key? key}) : super(key: key);

  @override
  _C1DeckListWidgetState createState() => _C1DeckListWidgetState();
}

class _C1DeckListWidgetState extends State<C1DeckListWidget> {
  late C1DeckListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  _DeckListView _view = _DeckListView.decks;

  // ── Member IDs ────────────────────────────────────────────────────────────
  Future<Set<String>>? _memberIdsFuture;

  // ── DECKS view: aggregate scores keyed by deckId ─────────────────────────
  Future<Map<String, DeckScoreStruct>>? _scoresFuture;
  List<String> _scoredDeckIds = [];

  // ── TOURNOIS view: per-tournament scores keyed by deck reference.id ───────
  Future<Map<String, DeckScoreStruct>>? _tournamentScoresFuture;
  List<String> _scoredSnapshotRefIds = [];

  // ── TOURNOIS view: tournament name + date, keyed by tournamentId ──────────
  Future<Map<String, TournamentsRecord>>? _tournamentInfoFuture;
  List<String> _loadedTournamentIds = [];

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

  // ── Member IDs ─────────────────────────────────────────────────────────────
  Future<Set<String>> _fetchMemberCrewmateIds() async {
    final Set<String> ids = {};

    if (currentUserReference != null) {
      final snap = await FirebaseFirestore.instance
          .collectionGroup('crewmates')
          .where('userReference', isEqualTo: currentUserReference)
          .get();
      ids.addAll(snap.docs.map((d) => d.id));
    }

    final crewRef = currentUserDocument?.crewRef;
    if (crewRef != null) {
      final snap = await crewRef.collection('crewmates').get();
      ids.addAll(snap.docs.map((d) => d.id));
    }

    if (currentUserDocument?.crewmateRef != null) {
      ids.add(currentUserDocument!.crewmateRef!.id);
    }

    return ids;
  }

  // ── Grouping ───────────────────────────────────────────────────────────────

  /// Builds the canonical "root" for each deck by following its templateRef
  /// chain to the top. Decks whose templateRef points outside [decks] are
  /// treated as roots. Cycles are broken by a visited set.
  Map<String, String> _buildRootMap(List<DecksRecord> decks) {
    final byId = {for (final d in decks) d.reference.id: d};

    String findRoot(String id, Set<String> visited) {
      if (visited.contains(id)) return id; // cycle guard
      visited.add(id);
      final deck = byId[id];
      if (deck == null || deck.templateRef == null) return id;
      final parentId = deck.templateRef!.id;
      if (!byId.containsKey(parentId)) return id; // parent outside visible set
      return findRoot(parentId, visited);
    }

    return {
      for (final d in decks) d.reference.id: findRoot(d.reference.id, {}),
    };
  }

  /// Produces one [_DeckGroup] per canonical deck family by following the
  /// `templateRef` chain (level-1 only). Standalone decks (no templateRef
  /// links) each get their own entry — they are NOT merged by name, because
  /// the name may be a generic default (e.g. "Nurgle V's Deck") shared across
  /// unrelated decks played in different tournaments.
  List<_DeckGroup> _buildGroups(List<DecksRecord> decks) {
    final byId = {for (final d in decks) d.reference.id: d};
    final rootMap = _buildRootMap(decks);

    // Group by root reference id
    final groups = <String, List<DecksRecord>>{};
    for (final d in decks) {
      groups.putIfAbsent(rootMap[d.reference.id]!, () => []).add(d);
    }

    return groups.values.map((members) {
      // Representative = the root of the chain (no templateRef, or parent
      // outside the visible set)
      final rep = members.firstWhere(
        (d) => d.templateRef == null || !byId.containsKey(d.templateRef!.id),
        orElse: () => members.first,
      );
      return _DeckGroup(representative: rep, members: members);
    }).toList()
      ..sort((a, b) => a.representative.name.compareTo(b.representative.name));
  }

  // ── Score loading: DECKS (aggregate per deckId) ───────────────────────────

  Future<Map<String, DeckScoreStruct>> _loadScores(List<String> deckIds) async {
    if (deckIds.isEmpty) return {};

    final wins = <String, int>{for (final id in deckIds) id: 0};
    final losses = <String, int>{for (final id in deckIds) id: 0};
    final matchWins = <String, int>{for (final id in deckIds) id: 0};
    final matchLosses = <String, int>{for (final id in deckIds) id: 0};

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
          final matchScores = (rawScores as List).cast<Map<String, dynamic>>();

          for (final entry in matchScores) {
            final thisDeckId = entry['deckId'] as String?;
            if (thisDeckId == null || !wins.containsKey(thisDeckId)) continue;

            final myScore = (entry['score'] as num?)?.toInt() ?? 0;
            final oppScore = matchScores
                .where((s) => s['deckId'] != thisDeckId)
                .fold(0, (s, e) => s + ((e['score'] as num?)?.toInt() ?? 0));

            wins[thisDeckId] = wins[thisDeckId]! + myScore;
            losses[thisDeckId] = losses[thisDeckId]! + oppScore;
            if (myScore > oppScore) matchWins[thisDeckId] = matchWins[thisDeckId]! + 1;
            else if (myScore < oppScore) matchLosses[thisDeckId] = matchLosses[thisDeckId]! + 1;
          }
        }
      } catch (_) {}
    }

    final result = <String, DeckScoreStruct>{};
    for (final id in deckIds) {
      final w = wins[id]!, l = losses[id]!, total = w + l;
      result[id] = DeckScoreStruct(
        wins: w, losses: l,
        winrate: total > 0 ? w / total.toDouble() : 0.0,
        matchWins: matchWins[id], matchLosses: matchLosses[id],
      );
    }
    return result;
  }

  void _updateScoresFutureIfNeeded(List<DecksRecord> decks) {
    final newIds = (decks.map((d) => d.deckId).where((id) => id.isNotEmpty).toSet().toList()..sort());
    if (newIds.join(',') == _scoredDeckIds.join(',')) return;
    _scoredDeckIds = newIds;
    _scoresFuture = _loadScores(List.from(newIds));
  }

  /// Aggregates rawScores for all members of a [_DeckGroup] by summing
  /// across their distinct deckIds (no double-counting since deckIds are
  /// deduplicated).
  DeckScoreStruct _aggregateGroupScore(
    _DeckGroup group,
    Map<String, DeckScoreStruct> rawScores,
  ) {
    final ids = {for (final d in group.members) if (d.deckId.isNotEmpty) d.deckId};
    int w = 0, l = 0, mw = 0, ml = 0;
    for (final id in ids) {
      final s = rawScores[id];
      if (s == null) continue;
      w += s.wins ?? 0;
      l += s.losses ?? 0;
      mw += s.matchWins ?? 0;
      ml += s.matchLosses ?? 0;
    }
    final total = w + l;
    return DeckScoreStruct(
      wins: w, losses: l, matchWins: mw, matchLosses: ml,
      winrate: total > 0 ? w / total.toDouble() : 0.0,
    );
  }

  // ── Score loading: TOURNOIS (per tournament, keyed by deck reference.id) ──

  Future<Map<String, DeckScoreStruct>> _loadTournamentScores(
    List<DecksRecord> snapshots,
  ) async {
    if (snapshots.isEmpty) return {};

    // Group snapshots by tournamentId for batch queries
    final byTournament = <String, List<DecksRecord>>{};
    for (final s in snapshots) {
      if (s.tournamentId.isEmpty) continue;
      byTournament.putIfAbsent(s.tournamentId, () => []).add(s);
    }

    // Accumulators keyed by deck reference.id
    final accum = <String, _MutableScore>{
      for (final s in snapshots) s.reference.id: _MutableScore(),
    };

    for (final entry in byTournament.entries) {
      final tournamentId = entry.key;
      final tDecks = entry.value;
      final deckIds = tDecks.map((d) => d.deckId).where((id) => id.isNotEmpty).toSet().toList();
      if (deckIds.isEmpty) continue;

      for (int i = 0; i < deckIds.length; i += 30) {
        final chunk = deckIds.sublist(i, (i + 30).clamp(0, deckIds.length));
        try {
          final snap = await FirebaseFirestore.instance
              .collection('matchups')
              .where('tournamentId', isEqualTo: tournamentId)
              .where('deckIds', arrayContainsAny: chunk)
              .get();

          for (final doc in snap.docs) {
            final matchup = doc.data();
            final rawScores = matchup['scores'];
            if (rawScores == null || rawScores is! List) continue;
            final matchScores = (rawScores as List).cast<Map<String, dynamic>>();

            for (final scoreEntry in matchScores) {
              final thisDeckId = scoreEntry['deckId'] as String?;
              if (thisDeckId == null || !deckIds.contains(thisDeckId)) continue;

              final myScore = (scoreEntry['score'] as num?)?.toInt() ?? 0;
              final oppScore = matchScores
                  .where((s) => s['deckId'] != thisDeckId)
                  .fold(0, (s, e) => s + ((e['score'] as num?)?.toInt() ?? 0));

              // Update every snapshot in this tournament that has this deckId
              for (final tDeck in tDecks.where((d) => d.deckId == thisDeckId)) {
                accum[tDeck.reference.id]?.addGame(myScore, oppScore);
              }
            }
          }
        } catch (_) {}
      }
    }

    return {for (final e in accum.entries) e.key: e.value.toStruct()};
  }

  void _updateTournamentScoresFutureIfNeeded(List<DecksRecord> snapshots) {
    final newIds = (snapshots.map((s) => s.reference.id).toList()..sort());
    if (newIds.join(',') == _scoredSnapshotRefIds.join(',')) return;
    _scoredSnapshotRefIds = newIds;
    _tournamentScoresFuture = _loadTournamentScores(List.from(snapshots));
  }

  // ── Tournament info loading ────────────────────────────────────────────────

  Future<Map<String, TournamentsRecord>> _loadTournamentInfo(
    List<String> tournamentIds,
  ) async {
    if (tournamentIds.isEmpty) return {};
    final result = <String, TournamentsRecord>{};
    for (final id in tournamentIds) {
      try {
        // Tournament document ID = tournamentId field value (convention)
        final doc = await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(id)
            .get();
        if (doc.exists) {
          result[id] = TournamentsRecord.fromSnapshot(doc);
        } else {
          // Fallback: field-based query
          final snap = await FirebaseFirestore.instance
              .collection('tournaments')
              .where('tournamentId', isEqualTo: id)
              .limit(1)
              .get();
          if (snap.docs.isNotEmpty) {
            result[id] = TournamentsRecord.fromSnapshot(snap.docs.first);
          }
        }
      } catch (_) {}
    }
    return result;
  }

  void _updateTournamentInfoIfNeeded(List<DecksRecord> snapshots) {
    final ids = snapshots.map((s) => s.tournamentId).where((id) => id.isNotEmpty).toSet().toList()..sort();
    if (ids.join(',') == _loadedTournamentIds.join(',')) return;
    _loadedTournamentIds = ids;
    _tournamentInfoFuture = _loadTournamentInfo(ids);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Theme.of(context).brightness,
        systemStatusBarContrastEnforced: true,
      ));
    }

    context.watch<FFAppState>();

    return AuthUserStreamWidget(
      builder: (context) {
        final crewId = valueOrDefault(currentUserDocument?.crewId, '');

        return FutureBuilder<Set<String>>(
          future: _memberIdsFuture ??= _fetchMemberCrewmateIds(),
          builder: (context, crewSnap) {
            final memberIds = crewSnap.data;
            final cacheKey = memberIds == null
                ? '__loading__'
                : '${crewId}_${(memberIds.toList()..sort()).join(',')}';

            return StreamBuilder<List<DecksRecord>>(
              stream: _model.deckListQuery(
                uniqueQueryKey: cacheKey,
                requestFn: () {
                  if (memberIds == null) return Stream.value(<DecksRecord>[]);
                  if (crewId.isNotEmpty) {
                    return queryDecksRecord(
                      queryBuilder: (q) => q.where('crewId', isEqualTo: crewId),
                    );
                  } else if (memberIds.isNotEmpty) {
                    return queryDecksRecord(
                      queryBuilder: (q) => q.where(
                        'crewmateId',
                        whereIn: memberIds.take(30).toList(),
                      ),
                    );
                  } else {
                    return Stream.value(<DecksRecord>[]);
                  }
                },
              ),
              builder: (context, snapshot) {
                if (memberIds == null || !snapshot.hasData) {
                  return Scaffold(
                    backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                    body: const Center(
                      child: SizedBox(
                        width: 50, height: 50,
                        child: SpinKitFadingFour(color: Color(0xFFE6486F), size: 50),
                      ),
                    ),
                  );
                }

                final allDecks = snapshot.data!;

                // Filter to visible members only (real crew case)
                final visibleDecks = (crewId.isNotEmpty && memberIds != null)
                    ? allDecks.where((d) => d.crewmateId.isEmpty || memberIds.contains(d.crewmateId)).toList()
                    : allDecks;

                // Build grouped view for DECKS tab
                final groups = _buildGroups(visibleDecks.toList());

                // Keep all snapshots for TOURNOIS tab (sorted by name)
                final allSnapshots = List<DecksRecord>.from(visibleDecks)
                  ..sort((a, b) => a.name.compareTo(b.name));

                // Update score futures synchronously
                _updateScoresFutureIfNeeded(visibleDecks.toList());
                if (_view == _DeckListView.tournois) {
                  _updateTournamentScoresFutureIfNeeded(allSnapshots);
                  _updateTournamentInfoIfNeeded(allSnapshots);
                }

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
                          logFirebaseEvent('C1_DECK_LIST_FloatingActionButton_5531ea');
                          await showDialog(
                            context: context,
                            builder: (dialogContext) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              alignment: AlignmentDirectional(0, 0).resolve(Directionality.of(context)),
                              child: GestureDetector(
                                onTap: () => _model.unfocusNode.canRequestFocus
                                    ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                                    : FocusScope.of(context).unfocus(),
                                child: DeckFormWidget(),
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        icon: const Icon(Icons.add),
                        elevation: 8,
                        label: Text(
                          FFLocalizations.of(context).getText('xyd4oyif' /* Add deck */),
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
                        borderRadius: 30,
                        borderWidth: 1,
                        buttonSize: 60,
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
                        onPressed: () async {
                          logFirebaseEvent('C1_DECK_LIST_arrow_back_rounded_ICN_ON_T');
                          context.pop();
                        },
                      ),
                      title: Text(
                        FFLocalizations.of(context).getText('8oyacj3o' /* DECKS */),
                        style: FlutterFlowTheme.of(context).titleLarge,
                      ),
                      centerTitle: true,
                      elevation: 2,
                    ),
                    body: SafeArea(
                      top: true,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF323236), Color(0xFFE6486F)],
                            stops: [0, 1],
                            begin: AlignmentDirectional(0, -1),
                            end: AlignmentDirectional(0, 1),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              _buildViewToggle(
                                context,
                                decksCount: groups.length,
                                tournoisCount: allSnapshots.length,
                              ),
                              Expanded(
                                child: _view == _DeckListView.decks
                                    ? _buildDecksView(context, groups)
                                    : _buildTournoisView(context, allSnapshots),
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
        );
      },
    );
  }

  // ── DECKS view ─────────────────────────────────────────────────────────────

  Widget _buildDecksView(BuildContext context, List<_DeckGroup> groups) {
    if (groups.isEmpty) return _buildEmpty(context, isDecks: true);

    return FutureBuilder<Map<String, DeckScoreStruct>>(
      future: _scoresFuture,
      builder: (ctx, scoresSnap) {
        final rawScores = scoresSnap.data ?? {};
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: groups.length,
          itemBuilder: (ctx, i) {
            final group = groups[i];
            final score = _aggregateGroupScore(group, rawScores);
            return DeckViewWidget(
              key: Key('deck_group_$i'),
              deck: group.representative,
              preloadedScore: score,
            );
          },
        );
      },
    );
  }

  // ── TOURNOIS view ──────────────────────────────────────────────────────────

  Widget _buildTournoisView(BuildContext context, List<DecksRecord> snapshots) {
    if (snapshots.isEmpty) return _buildEmpty(context, isDecks: false);

    return FutureBuilder<Map<String, DeckScoreStruct>>(
      future: _tournamentScoresFuture,
      builder: (ctx, scoresSnap) {
        final scores = scoresSnap.data ?? {};

        return FutureBuilder<Map<String, TournamentsRecord>>(
          future: _tournamentInfoFuture,
          builder: (ctx2, infoSnap) {
            final tournamentInfo = infoSnap.data ?? {};

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshots.length,
              itemBuilder: (ctx3, i) {
                final deck = snapshots[i];
                final score = scores[deck.reference.id];
                final tournament = tournamentInfo[deck.tournamentId];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tournament header row
                    if (deck.tournamentId.isNotEmpty)
                      _buildTournamentHeader(context, tournament, deck.tournamentId),
                    DeckViewWidget(
                      key: Key('tournoi_${deck.reference.id}'),
                      deck: deck,
                      preloadedScore: score,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTournamentHeader(
    BuildContext context,
    TournamentsRecord? tournament,
    String tournamentId,
  ) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final name = tournament?.name.isNotEmpty == true
        ? tournament!.name
        : 'Tournoi $tournamentId';
    final dateStr = tournament?.date != null
        ? DateFormat('d MMM yyyy', 'fr').format(tournament!.date!)
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 16, 2),
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined, size: 11, color: accent.withOpacity(0.45)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: accent.withOpacity(0.55),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          if (dateStr.isNotEmpty)
            Text(
              dateStr,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: accent.withOpacity(0.35),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  // ── Toggle ─────────────────────────────────────────────────────────────────

  Widget _buildViewToggle(
    BuildContext context, {
    required int decksCount,
    required int tournoisCount,
  }) {
    final accent = FlutterFlowTheme.of(context).primaryText;

    Widget chip(String label, int count, _DeckListView target) {
      final selected = _view == target;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _view = target;
            if (target == _DeckListView.tournois) {
              // Trigger per-tournament score + info loads on first switch
              _scoredSnapshotRefIds = [];
              _loadedTournamentIds = [];
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(0.16) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$label  ·  $count',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: selected ? accent : accent.withOpacity(0.55),
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            chip('DECKS', decksCount, _DeckListView.decks),
            chip('TOURNOIS', tournoisCount, _DeckListView.tournois),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context, {required bool isDecks}) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDecks ? Icons.style_outlined : Icons.auto_awesome_outlined,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            isDecks ? 'Aucun deck' : 'Aucun tournoi',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Cinzel Decorative',
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isDecks
                ? 'Importe un tournoi Spicerack ou ajoute un deck manuellement.'
                : 'Importe un tournoi Spicerack pour voir tes decks par tournoi.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'Noto Sans',
              color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
