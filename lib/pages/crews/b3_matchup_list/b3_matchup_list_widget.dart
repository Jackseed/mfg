import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_icons.dart';
import '/page_component/archetype_editor/archetype_editor_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'b3_matchup_list_model.dart';
export 'b3_matchup_list_model.dart';

// ─── Data classes ────────────────────────────────────────────────────────────

class _MatchupPageData {
  final List<DecksRecord> decks;
  final Map<String, DecksRecord> deckMap;
  final Map<String, String> crewmateNameMap;
  final Set<String> myDeckIds;
  final Map<String, DateTime> matchupDateMap;
  // Most recent game date per tournamentId — built from GamesRecord.date, no async needed.
  final Map<String, DateTime> tournamentDateMap;

  const _MatchupPageData({
    required this.decks,
    required this.deckMap,
    required this.crewmateNameMap,
    required this.myDeckIds,
    required this.matchupDateMap,
    required this.tournamentDateMap,
  });
}

/// Aggregate for one archetype-pair (my archetype vs opponent archetype).
class _ArchetypeAgg {
  final String myArchetype;
  final String oppArchetype;
  DecksRecord? myRepDeck;
  DecksRecord? oppRepDeck;
  int wins = 0;
  int losses = 0;
  int draws = 0;
  final List<MatchupsRecord> matchups = [];

  _ArchetypeAgg(this.myArchetype, this.oppArchetype);

  int get total => wins + losses + draws;
}

/// Aggregate for one opponent player.
class _PlayerAgg {
  final String crewmateId;
  final String playerName;
  int wins = 0;
  int losses = 0;
  int draws = 0;
  final List<MatchupsRecord> matchups = [];

  _PlayerAgg(this.crewmateId, this.playerName);

  int get total => wins + losses + draws;
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class B3MatchupListWidget extends StatefulWidget {
  const B3MatchupListWidget({
    Key? key,
    required this.filteredDeckList,
  }) : super(key: key);

  final List<String>? filteredDeckList;

  @override
  _B3MatchupListWidgetState createState() => _B3MatchupListWidgetState();
}

class _B3MatchupListWidgetState extends State<B3MatchupListWidget>
    with TickerProviderStateMixin {
  late B3MatchupListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;

  // Drill-down state
  _ArchetypeAgg? _selectedArchetype;
  _PlayerAgg? _selectedPlayer;

  // Page-data cache
  String? _lastCrewId;
  String? _lastCrewmateId;
  Future<_MatchupPageData>? _pageDataFuture;

  // Tournament name cache (tournamentId → name, null while loading).
  // Dates come from games already loaded in _loadPageData — no async needed.
  final Map<String, String?> _tournamentNames = {};

  void _loadTournamentName(String tournId, DocumentReference? ref) {
    if (_tournamentNames.containsKey(tournId)) return;
    _tournamentNames[tournId] = null;
    if (ref == null) return;
    ref.get().then((doc) {
      final name =
          (doc.data() as Map<String, dynamic>?)?['name'] as String?;
      if (mounted) setState(() => _tournamentNames[tournId] = name);
    }).catchError((_) {});
  }

  static String _formatMatchupDate(DateTime d, String locale) {
    if (locale == 'fr') {
      const m = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    }
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  static final _colorIcons = {
    'W': FFIcons.kwhite,
    'U': FFIcons.kblue,
    'B': FFIcons.kblack,
    'R': FFIcons.kred,
    'G': FFIcons.kgreen,
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => B3MatchupListModel());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedArchetype = null;
          _selectedPlayer = null;
        });
      }
    });
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'B3_MatchupList'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ─── Data loading ───────────────────────────────────────────────────────────

  Future<_MatchupPageData> _getPageData(String crewId, String? crewmateId) {
    if (_pageDataFuture == null ||
        crewId != _lastCrewId ||
        crewmateId != _lastCrewmateId) {
      _lastCrewId = crewId;
      _lastCrewmateId = crewmateId;
      _pageDataFuture = _loadPageData(crewId, crewmateId);
    }
    return _pageDataFuture!;
  }

  Future<_MatchupPageData> _loadPageData(
      String crewId, String? myCrewmateId) async {
    // For org-only users (no personal crew), discover their crewmate IDs and
    // the parent crew IDs via userReference collection-group query.
    Set<String> myCrewmateIds = myCrewmateId != null ? {myCrewmateId} : {};
    Set<String> myOrgCrewIds = {};
    if (crewId.isEmpty && currentUserReference != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collectionGroup('crewmates')
            .where('userReference', isEqualTo: currentUserReference)
            .get();
        myCrewmateIds = snap.docs.map((d) => d.id).toSet();
        // Extract parent crew IDs (the org-crew containers created by import).
        myOrgCrewIds = snap.docs.map((d) => d.reference.parent.parent!.id).toSet();
      } catch (_) {}
    }

    List<DecksRecord> decks;
    if (crewId.isNotEmpty) {
      decks = await queryDecksRecordOnce(
        queryBuilder: (q) =>
            q.where('crewId', isEqualTo: crewId).orderBy('name'),
      );
    } else if (myOrgCrewIds.isNotEmpty) {
      // Fetch ALL decks from the user's org-crews (includes opponents) so
      // deck names resolve correctly in matchup cards.
      final results = await Future.wait(
        myOrgCrewIds.take(10).map((cid) => queryDecksRecordOnce(
              queryBuilder: (q) => q.where('crewId', isEqualTo: cid),
            )),
      );
      decks = results.expand((l) => l).toList();
    } else {
      decks = [];
    }

    final deckMap = <String, DecksRecord>{};
    for (final d in decks) {
      if (d.deckId.isNotEmpty) deckMap[d.deckId] = d;
      // Also key by Firestore document ID so that old matchups whose
      // scores.deckId stored the document ID (not the UUID) still resolve.
      deckMap[d.reference.id] = d;
    }

    final refs = decks
        .where((d) => d.hasCrewmateRef())
        .map((d) => d.crewmateRef!)
        .toSet();
    final crewmateNameMap = <String, String>{};
    if (refs.isNotEmpty) {
      final docs = await Future.wait(refs.map((r) => r.get()));
      for (final doc in docs) {
        final name =
            (doc.data() as Map<String, dynamic>?)?['name'] as String?;
        if (name != null && name.isNotEmpty) crewmateNameMap[doc.id] = name;
      }
    }

    final myDeckIds = <String>{};
    for (final d in decks) {
      if (myCrewmateIds.contains(d.crewmateId) && d.deckId.isNotEmpty) {
        myDeckIds.add(d.deckId);
      }
    }

    final games = await queryGamesRecordOnce(
      queryBuilder: (q) => crewId.isNotEmpty
          ? q.where('crewId', isEqualTo: crewId)
          : q.where('crewmateId',
              whereIn: myCrewmateIds.isEmpty
                  ? ['___no_match___']
                  : myCrewmateIds.take(30).toList()),
    );
    final matchupDateMap = <String, DateTime>{};
    final tournamentDateMap = <String, DateTime>{};
    for (final g in games) {
      if (g.date == null) continue;
      void _store(String key) {
        if (key.isEmpty) return;
        final existing = matchupDateMap[key];
        if (existing == null || g.date!.isAfter(existing)) {
          matchupDateMap[key] = g.date!;
        }
      }
      _store(g.matchupId);
      if (g.matchupRef != null) _store(g.matchupRef!.id);
      // Also index by tournamentId so matchups without a direct game-date
      // lookup can fall back to the most recent game date in that tournament.
      if (g.tournamentId.isNotEmpty) {
        final existing = tournamentDateMap[g.tournamentId];
        if (existing == null || g.date!.isAfter(existing)) {
          tournamentDateMap[g.tournamentId] = g.date!;
        }
      }
    }

    return _MatchupPageData(
      decks: decks,
      deckMap: deckMap,
      crewmateNameMap: crewmateNameMap,
      myDeckIds: myDeckIds,
      matchupDateMap: matchupDateMap,
      tournamentDateMap: tournamentDateMap,
    );
  }

  // ─── Aggregation helpers ─────────────────────────────────────────────────────

  String _deckLabel(DecksRecord? deck) {
    if (deck == null) return 'Unknown';
    if (deck.avatarName.isNotEmpty) return deck.avatarName;
    if (deck.name.isNotEmpty) return deck.name;
    return 'Unknown';
  }

  /// Sort: newest first, then round descending.
  DateTime? _matchupDate(MatchupsRecord m, _MatchupPageData data) =>
      data.matchupDateMap[m.matchupId.isNotEmpty ? m.matchupId : '__']
          ?? data.matchupDateMap[m.reference.id]
          ?? (m.tournamentId.isNotEmpty ? data.tournamentDateMap[m.tournamentId] : null);

  List<MatchupsRecord> _sorted(
      List<MatchupsRecord> raw, _MatchupPageData data) {
    return [...raw]
      ..sort((a, b) {
        final da = _matchupDate(a, data);
        final db = _matchupDate(b, data);
        if (da == null && db == null) return b.round.compareTo(a.round);
        if (da == null) return 1;
        if (db == null) return -1;
        final cmp = db.compareTo(da);
        return cmp != 0 ? cmp : b.round.compareTo(a.round);
      });
  }

  int? _userResult(MatchupsRecord m, Set<String> myDeckIds) {
    if (m.scores.length < 2) return null;
    final s1 = m.scores.first;
    final s2 = m.scores.last;
    int my, opp;
    if (myDeckIds.contains(s1.deckId)) {
      my = s1.score;
      opp = s2.score;
    } else if (myDeckIds.contains(s2.deckId)) {
      my = s2.score;
      opp = s1.score;
    } else {
      return null;
    }
    if (my > opp) return 1;
    if (my < opp) return -1;
    return 0;
  }

  List<_ArchetypeAgg> _computeArchetypeAggs(
      List<MatchupsRecord> matchups, _MatchupPageData data) {
    final map = <String, _ArchetypeAgg>{};
    for (final m in matchups) {
      if (m.scores.length < 2) continue;
      final s1 = m.scores.first;
      final s2 = m.scores.last;
      final bool mine1 = data.myDeckIds.contains(s1.deckId);
      final bool mine2 = data.myDeckIds.contains(s2.deckId);
      if (!mine1 && !mine2) continue;

      final myScore = mine1 ? s1 : s2;
      final oppScore = mine1 ? s2 : s1;
      final myDeck = data.deckMap[myScore.deckId];
      final oppDeck = data.deckMap[oppScore.deckId];

      final myArch = _deckLabel(myDeck);
      final oppArch = _deckLabel(oppDeck);
      final key = '$myArch\x00$oppArch';

      final agg = map.putIfAbsent(key, () => _ArchetypeAgg(myArch, oppArch));
      agg.myRepDeck ??= myDeck;
      agg.oppRepDeck ??= oppDeck;
      agg.matchups.add(m);

      final r = myScore.score.compareTo(oppScore.score);
      if (r > 0) agg.wins++;
      else if (r < 0) agg.losses++;
      else agg.draws++;
    }
    double ratio(_ArchetypeAgg a) =>
        a.total == 0 ? 0 : a.wins / a.total;
    return map.values.toList()
      ..sort((a, b) {
        final cmp = ratio(b).compareTo(ratio(a));
        return cmp != 0 ? cmp : b.total.compareTo(a.total);
      });
  }

  List<_PlayerAgg> _computePlayerAggs(
      List<MatchupsRecord> matchups, _MatchupPageData data) {
    final map = <String, _PlayerAgg>{};
    for (final m in matchups) {
      if (m.scores.length < 2) continue;
      final s1 = m.scores.first;
      final s2 = m.scores.last;
      final bool mine1 = data.myDeckIds.contains(s1.deckId);
      final bool mine2 = data.myDeckIds.contains(s2.deckId);
      if (!mine1 && !mine2) continue;

      final myScore = mine1 ? s1 : s2;
      final oppScore = mine1 ? s2 : s1;
      final oppDeck = data.deckMap[oppScore.deckId];
      final oppCrewmateId = oppDeck?.crewmateId ?? '';
      final oppName =
          data.crewmateNameMap[oppCrewmateId] ?? 'Unknown';

      final key = oppCrewmateId.isNotEmpty ? oppCrewmateId : oppName;
      final agg =
          map.putIfAbsent(key, () => _PlayerAgg(oppCrewmateId, oppName));
      agg.matchups.add(m);

      final r = myScore.score.compareTo(oppScore.score);
      if (r > 0) agg.wins++;
      else if (r < 0) agg.losses++;
      else agg.draws++;
    }
    double ratio(_PlayerAgg a) =>
        a.total == 0 ? 0 : a.wins / a.total;
    return map.values.toList()
      ..sort((a, b) {
        final cmp = ratio(b).compareTo(ratio(a));
        return cmp != 0 ? cmp : b.total.compareTo(a.total);
      });
  }

  // ─── Avatar helpers ──────────────────────────────────────────────────────────

  Widget _buildColorIconsOrInitials(
      BuildContext context, String name, List<String> colors) {
    if (colors.isEmpty) return _buildInitialsAvatar(context, name);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: colors.take(3).map((c) {
            final icon = _colorIcons[c.toUpperCase()];
            if (icon != null) {
              return Icon(icon,
                  size: 10,
                  color: FlutterFlowTheme.of(context).primaryText);
            }
            return const SizedBox.shrink();
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, String name) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Cinzel Decorative',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _deckAvatar(BuildContext context, DecksRecord? deck, String label) {
    final colors = deck?.colors ?? [];
    final hasAvatar = deck != null && deck.avatarUrl.isNotEmpty;
    if (hasAvatar) {
      return Container(
        width: 36,
        height: 36,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: CachedNetworkImage(
          imageUrl: deck.avatarUrl,
          fit: BoxFit.cover,
          placeholder: (ctx, _) => _buildInitialsAvatar(ctx, label),
          errorWidget: (ctx, _, __) =>
              _buildColorIconsOrInitials(ctx, label, colors),
        ),
      );
    }
    if (colors.isNotEmpty) {
      return _buildColorIconsOrInitials(context, label, colors);
    }
    return _buildInitialsAvatar(context, label);
  }

  // ─── Matchup card (shared across all tabs) ───────────────────────────────────

  Widget _buildMatchupCard(
      BuildContext context, MatchupsRecord matchup, _MatchupPageData data) {
    if (matchup.scores.length < 2) return const SizedBox.shrink();
    final s1 = matchup.scores.first;
    final s2 = matchup.scores.last;
    final deck1 = data.deckMap[s1.deckId];
    final deck2 = data.deckMap[s2.deckId];
    final player1 = deck1 != null ? data.crewmateNameMap[deck1.crewmateId] : null;
    final player2 = deck2 != null ? data.crewmateNameMap[deck2.crewmateId] : null;

    final result = _userResult(matchup, data.myDeckIds);
    final resultColor = result == null
        ? const Color(0xFF95A5A6)
        : result > 0
            ? const Color(0xFF2ECC71)
            : result < 0
                ? const Color(0xFFE74C3C)
                : const Color(0xFFF1C40F);
    final resultText = result == null
        ? '—'
        : result > 0
            ? FFLocalizations.of(context).getVariableText(enText: 'WIN', frText: 'VICTOIRE')
            : result < 0
                ? FFLocalizations.of(context).getVariableText(enText: 'LOSS', frText: 'DÉFAITE')
                : FFLocalizations.of(context).getVariableText(enText: 'DRAW', frText: 'NUL');

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resultColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(resultText,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    color: resultColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _buildPlayerSide(context, deck1, s1.score,
                        isLeft: true, playerName: player1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('VS',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Cinzel Decorative',
                            color: FlutterFlowTheme.of(context)
                                .primaryText
                                .withOpacity(0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )),
                ),
                Expanded(
                    child: _buildPlayerSide(context, deck2, s2.score,
                        isLeft: false, playerName: player2)),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildPlayerSide(
    BuildContext context,
    DecksRecord? deck,
    int score, {
    required bool isLeft,
    String? playerName,
  }) {
    final label = _deckLabel(deck);
    final colors = deck?.colors ?? [];

    Widget avatarWidget = _deckAvatar(context, deck, label);
    if (deck != null) {
      avatarWidget = Stack(
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 9, color: Colors.white),
            ),
          ),
        ],
      );
      avatarWidget = GestureDetector(
        onTap: () =>
            showArchetypeEditor(context, deck, onSaved: () => setState(() {})),
        child: avatarWidget,
      );
    }
    final avatar = avatarWidget;

    final scoreWidget = Text('$score',
        style: FlutterFlowTheme.of(context).headlineSmall.override(
              fontFamily: 'Cinzel Decorative',
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 24,
            ));

    final nameWidget = Text(label,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Noto Sans',
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: isLeft ? TextAlign.left : TextAlign.right);

    Widget colorRow = const SizedBox.shrink();
    if (colors.isNotEmpty) {
      colorRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((c) {
          final icon = _colorIcons[c.toUpperCase()];
          return icon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(icon,
                      size: 12,
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.7)),
                )
              : const SizedBox.shrink();
        }).toList(),
      );
    }

    Widget? playerWidget;
    if (playerName != null && playerName.isNotEmpty) {
      playerWidget = Text(playerName,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Noto Sans',
                color: FlutterFlowTheme.of(context)
                    .primaryText
                    .withOpacity(0.5),
                fontSize: 10,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isLeft ? TextAlign.left : TextAlign.right);
    }

    if (isLeft) {
      return Row(children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (playerWidget != null) playerWidget,
              nameWidget,
              const SizedBox(height: 2),
              colorRow,
            ],
          ),
        ),
        const SizedBox(width: 4),
        scoreWidget,
      ]);
    } else {
      return Row(children: [
        scoreWidget,
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (playerWidget != null) playerWidget,
              nameWidget,
              const SizedBox(height: 2),
              Align(alignment: Alignment.centerRight, child: colorRow),
            ],
          ),
        ),
        const SizedBox(width: 8),
        avatar,
      ]);
    }
  }

  // ─── Archetype agg card ──────────────────────────────────────────────────────

  Widget _buildArchetypeAggCard(
      BuildContext context, _ArchetypeAgg agg, _MatchupPageData data) {
    final resultColor = agg.wins > agg.losses
        ? const Color(0xFF2ECC71)
        : agg.wins < agg.losses
            ? const Color(0xFFE74C3C)
            : const Color(0xFFF1C40F);

    return InkWell(
      onTap: () => setState(() => _selectedArchetype = agg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resultColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            // Record badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${agg.wins}W · ${agg.losses}L${agg.draws > 0 ? ' · ${agg.draws}D' : ''}',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: resultColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Archetype vs
            Row(
              children: [
                Expanded(
                    child: _buildArchetypeSide(
                        context, agg.myArchetype, agg.myRepDeck,
                        isLeft: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('VS',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Cinzel Decorative',
                            color: FlutterFlowTheme.of(context)
                                .primaryText
                                .withOpacity(0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )),
                ),
                Expanded(
                    child: _buildArchetypeSide(
                        context, agg.oppArchetype, agg.oppRepDeck,
                        isLeft: false)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              FFLocalizations.of(context).languageCode == 'fr'
                  ? '${agg.total} ${agg.total == 1 ? "partie" : "parties"}'
                  : '${agg.total} ${agg.total == 1 ? "game" : "games"}',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: FlutterFlowTheme.of(context)
                    .primaryText
                    .withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchetypeSide(
      BuildContext context, String label, DecksRecord? deck,
      {required bool isLeft}) {
    final colors = deck?.colors ?? [];
    final avatar = _deckAvatar(context, deck, label);
    final nameWidget = Text(
      label,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Noto Sans',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: isLeft ? TextAlign.left : TextAlign.right,
    );
    Widget colorRow = const SizedBox.shrink();
    if (colors.isNotEmpty) {
      colorRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((c) {
          final icon = _colorIcons[c.toUpperCase()];
          return icon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(icon,
                      size: 12,
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.7)),
                )
              : const SizedBox.shrink();
        }).toList(),
      );
    }

    if (isLeft) {
      return Row(children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameWidget,
              const SizedBox(height: 2),
              colorRow,
            ],
          ),
        ),
      ]);
    } else {
      return Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              nameWidget,
              const SizedBox(height: 2),
              Align(alignment: Alignment.centerRight, child: colorRow),
            ],
          ),
        ),
        const SizedBox(width: 8),
        avatar,
      ]);
    }
  }

  // ─── Player agg card ─────────────────────────────────────────────────────────

  Widget _buildPlayerAggCard(BuildContext context, _PlayerAgg agg) {
    final resultColor = agg.wins > agg.losses
        ? const Color(0xFF2ECC71)
        : agg.wins < agg.losses
            ? const Color(0xFFE74C3C)
            : const Color(0xFFF1C40F);

    return InkWell(
      onTap: () => setState(() => _selectedPlayer = agg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resultColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            _buildInitialsAvatar(context, agg.playerName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agg.playerName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Noto Sans',
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    FFLocalizations.of(context).languageCode == 'fr'
                  ? '${agg.total} ${agg.total == 1 ? "partie" : "parties"}'
                  : '${agg.total} ${agg.total == 1 ? "game" : "games"}',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${agg.wins}-${agg.losses}${agg.draws > 0 ? '-${agg.draws}' : ''}',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: resultColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right,
                color: FlutterFlowTheme.of(context)
                    .primaryText
                    .withOpacity(0.3),
                size: 18),
          ],
        ),
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, {String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FFIcons.kred,
                color: FlutterFlowTheme.of(context).secondaryText, size: 80),
            const SizedBox(height: 20),
            Text(
              message ?? FFLocalizations.of(context).getText('wxo7v8rv'),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Cinzel Decorative',
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab bodies ──────────────────────────────────────────────────────────────

  /// Renders a grouped list of matchups, with section headers showing
  /// "19 avr · Tournament Name" (or just "19 avr 2026" if no tournament).
  Widget _buildGroupedMatchupList(
      BuildContext context,
      List<MatchupsRecord> matchups,
      _MatchupPageData data) {
    final locale = FFLocalizations.of(context).languageCode;

    // Group by "YYYY-MM-DD|tournamentId"
    final grouped = <String, List<MatchupsRecord>>{};
    for (final m in matchups) {
      final date = _matchupDate(m, data);
      final dateKey = date != null
          ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          : '0000-00-00';
      final key = '$dateKey|${m.tournamentId}';
      grouped.putIfAbsent(key, () => []).add(m);
      if (m.tournamentId.isNotEmpty) {
        _loadTournamentName(m.tournamentId, m.tournamentRef);
      }
    }

    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final items = <Widget>[];

    for (final key in keys) {
      final parts = key.split('|');
      final dateStr = parts[0];
      final tournId = parts.length > 1 ? parts[1] : '';

      String headerLabel = '';
      if (dateStr != '0000-00-00') {
        final dp = dateStr.split('-');
        final d = DateTime(
            int.parse(dp[0]), int.parse(dp[1]), int.parse(dp[2]));
        headerLabel = _formatMatchupDate(d, locale);
      }
      final tournName =
          tournId.isNotEmpty ? _tournamentNames[tournId] : null;
      if (tournName != null && tournName.isNotEmpty) {
        headerLabel = headerLabel.isNotEmpty
            ? '$headerLabel · $tournName'
            : tournName;
      }

      if (headerLabel.isNotEmpty) {
        items.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
          child: Text(
            headerLabel,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: 'Cinzel Decorative',
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  fontSize: 13,
                ),
          ),
        ));
      }

      for (final m in grouped[key]!) {
        items.add(_buildMatchupCard(context, m, data));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: items,
    );
  }

  Widget _buildPartiesTab(
      BuildContext context,
      List<MatchupsRecord> allMatchups,
      _MatchupPageData data) {
    final matchups = _sorted(allMatchups, data);

    if (matchups.isEmpty) return _buildEmptyState(context);

    return _buildGroupedMatchupList(context, matchups, data);
  }

  Widget _buildMatchupsTab(BuildContext context, List<MatchupsRecord> allMatchups,
      _MatchupPageData data) {
    // Drill-down: show filtered matchup list for selected archetype pair
    if (_selectedArchetype != null) {
      final agg = _selectedArchetype!;
      final filtered = _sorted(agg.matchups, data);
      return _buildGroupedMatchupList(context, filtered, data);
    }

    final aggs = _computeArchetypeAggs(allMatchups, data);
    if (aggs.isEmpty) {
      return _buildEmptyState(context,
          message: 'Aucun matchup avec tes decks');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      itemCount: aggs.length,
      itemBuilder: (ctx, i) =>
          _buildArchetypeAggCard(ctx, aggs[i], data),
    );
  }

  Widget _buildJoueursTab(BuildContext context, List<MatchupsRecord> allMatchups,
      _MatchupPageData data) {
    // Drill-down: show filtered matchup list for selected player
    if (_selectedPlayer != null) {
      final agg = _selectedPlayer!;
      final filtered = _sorted(agg.matchups, data);
      return _buildGroupedMatchupList(context, filtered, data);
    }

    final aggs = _computePlayerAggs(allMatchups, data);
    if (aggs.isEmpty) {
      return _buildEmptyState(context,
          message: 'Aucune partie enregistrée');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      itemCount: aggs.length,
      itemBuilder: (ctx, i) => _buildPlayerAggCard(ctx, aggs[i]),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Theme.of(context).brightness,
        systemStatusBarContrastEnforced: true,
      ));
    }
    context.watch<FFAppState>();

    final inDrillDown = _selectedArchetype != null || _selectedPlayer != null;

    return AuthUserStreamWidget(
      builder: (context) {
        final crewId = valueOrDefault(currentUserDocument?.crewId, '');
        final myCrewmateId = currentUserDocument?.crewmateRef?.id;
        final orgIds = (currentUserDocument?.organizationIds ?? [])
            .where((id) => id.isNotEmpty)
            .toList();

        return FutureBuilder<_MatchupPageData>(
          future: _getPageData(crewId, myCrewmateId),
          builder: (context, dataSnap) {
            if (!dataSnap.hasData) {
              return Scaffold(
                backgroundColor: FlutterFlowTheme.of(context).alternate,
                body: const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: SpinKitFadingFour(color: Color(0xFFE6486F), size: 50),
                  ),
                ),
              );
            }

            final pageData = dataSnap.data!;

            // AppBar title changes in drill-down
            String appBarTitle = 'Parties';
            if (_selectedArchetype != null) {
              appBarTitle =
                  '${_selectedArchetype!.myArchetype} vs ${_selectedArchetype!.oppArchetype}';
            } else if (_selectedPlayer != null) {
              appBarTitle = 'vs ${_selectedPlayer!.playerName}';
            }

            return GestureDetector(
              onTap: () => _model.unfocusNode.canRequestFocus
                  ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                  : FocusScope.of(context).unfocus(),
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: FlutterFlowTheme.of(context).alternate,
                floatingActionButton: _tabController.index == 0 &&
                        valueOrDefault(currentUserDocument?.crewId, '') != ''
                    ? FloatingActionButton.extended(
                        onPressed: () {
                          logFirebaseEvent(
                              'B3_MATCHUP_LIST_FloatingActionButton_0c2');
                          context.pushNamed('B2_AddMatchup');
                        },
                        backgroundColor:
                            FlutterFlowTheme.of(context).primary,
                        icon: const Icon(Icons.add),
                        elevation: 8.0,
                        label: Text(
                          FFLocalizations.of(context).getText('kpx4xw60'),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      )
                    : null,
                appBar: AppBar(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  automaticallyImplyLeading: !inDrillDown,
                  leading: inDrillDown
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => setState(() {
                            _selectedArchetype = null;
                            _selectedPlayer = null;
                          }),
                        )
                      : null,
                  title: Text(
                    appBarTitle,
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'Cinzel Decorative',
                          fontSize: inDrillDown ? 16.0 : 24.0,
                          letterSpacing: 0.9,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: true,
                  elevation: 4.0,
                  bottom: inDrillDown
                      ? null
                      : TabBar(
                          controller: _tabController,
                          indicatorColor:
                              FlutterFlowTheme.of(context).tertiary,
                          labelColor: FlutterFlowTheme.of(context).primaryText,
                          unselectedLabelColor: FlutterFlowTheme.of(context)
                              .primaryText
                              .withOpacity(0.5),
                          labelStyle: const TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Toutes'),
                            Tab(text: 'Matchups'),
                            Tab(text: 'Joueurs'),
                          ],
                        ),
                ),
                body: SafeArea(
                  top: true,
                  child: StreamBuilder<List<MatchupsRecord>>(
                    stream: crewId.isNotEmpty
                        ? queryMatchupsRecord(
                            queryBuilder: (q) =>
                                q.where('crewId', isEqualTo: crewId),
                          )
                        : orgIds.isNotEmpty
                            ? queryMatchupsRecord(
                                queryBuilder: (q) => q.where(
                                  'organizationId',
                                  whereIn: orgIds.take(30).toList(),
                                ),
                              )
                            : Stream.value(<MatchupsRecord>[]),
                    builder: (context, matchupSnap) {
                      if (!matchupSnap.hasData) {
                        return const Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: SpinKitFadingFour(
                                color: Color(0xFFE6486F), size: 50),
                          ),
                        );
                      }

                      final allMatchups = matchupSnap.data!;

                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF323236), Color(0xFFE6486F)],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                        ),
                        child: inDrillDown
                            ? (_selectedArchetype != null
                                ? _buildMatchupsTab(
                                    context, allMatchups, pageData)
                                : _buildJoueursTab(
                                    context, allMatchups, pageData))
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildPartiesTab(
                                      context, allMatchups, pageData),
                                  _buildMatchupsTab(
                                      context, allMatchups, pageData),
                                  _buildJoueursTab(
                                      context, allMatchups, pageData),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
