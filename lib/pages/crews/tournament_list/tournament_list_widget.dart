import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/stats/tournament_stats.dart' as stats;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'tournament_list_model.dart';
export 'tournament_list_model.dart';

/// Local aliases so the rest of the widget keeps reading as-is. The actual
/// types come from the pure-Dart stats module which is unit-tested.
typedef _DeckArchetypeInfo = stats.DeckArchetypeInfo;
typedef _ArchetypeTally = stats.ArchetypeTally;

/// Adapts a [MatchupsRecord] into the plain-Dart shape the stats module
/// expects. Centralised here so every caller on this page goes through the
/// same conversion.
List<stats.ScoreEntry> _scoresOf(MatchupsRecord m) => [
      for (final s in m.scores)
        stats.ScoreEntry(deckId: s.deckId, score: s.score),
    ];

class TournamentListWidget extends StatefulWidget {
  const TournamentListWidget({Key? key}) : super(key: key);

  @override
  State<TournamentListWidget> createState() => _TournamentListWidgetState();
}

class _TournamentListWidgetState extends State<TournamentListWidget> {
  late TournamentListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Data state
  bool _isLoading = true;
  List<TournamentsRecord> _tournaments = [];
  Map<String, List<MatchupsRecord>> _matchupsByTournament = {};
  Set<String> _myDeckIds = {};
  Map<String, String> _tournamentFormatMap = {};

  /// Deck-id → (archetype name, avatar url) for the user's own decks, used to
  /// compute the "top archetypes you played" strip.
  final Map<String, _DeckArchetypeInfo> _deckArchetype = {};

  /// Currently selected format filter (null = all).
  String? _selectedFormat;

  /// Currently selected archetype filter (null = all). Key is archetype name.
  String? _selectedArchetype;

  static const _formatColors = {
    'LEGACY': Color(0xFF9B59B6),
    'MODERN': Color(0xFFE67E22),
    'PIONEER': Color(0xFF3498DB),
    'STANDARD': Color(0xFF2ECC71),
    'VINTAGE': Color(0xFFF1C40F),
    'PAUPER': Color(0xFF95A5A6),
  };

  Color _formatColor(String format) =>
      _formatColors[format.toUpperCase()] ?? const Color(0xFF95A5A6);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentListModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'TournamentList'});
    _loadData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Step 1: Get user's main crewmate → Spicerack userId
      final crewmateRef = currentUserDocument?.crewmateRef;
      if (crewmateRef == null) {
        setState(() => _isLoading = false);
        return;
      }

      final mainCrewmate =
          await CrewmatesRecord.getDocumentOnce(crewmateRef);
      final spicerackUserId = mainCrewmate.userId;

      // Step 2: Find ALL crewmates with this Spicerack userId (across all crews)
      final allCrewmates = await queryCrewmatesRecordOnce(
        queryBuilder: (q) =>
            q.where('userId', isEqualTo: spicerackUserId),
      );

      final allCrewIds = <String>{};
      final allCrewmateIds = <String>{};
      for (final cm in allCrewmates) {
        allCrewmateIds.add(cm.reference.id);
        allCrewIds.add(cm.parentReference.id);
      }

      // Also pick up the user's organization memberships (Spicerack-scoped
      // tournaments live under `organizationId`, while manual games still live
      // under `crewId`). We union both worlds so any tournament the user can
      // see appears here.
      final userOrgIds = currentUserDocument?.organizationIds
              .where((id) => id.isNotEmpty)
              .toSet() ??
          <String>{};

      if (allCrewIds.isEmpty && userOrgIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Step 3: Query tournaments, matchups, decks for ALL user's crews.
      // whereIn has a cap of 30 entries in Firestore — we chunk just in case.
      final crewIdsList = allCrewIds.toList();
      final orgIdsList = userOrgIds.toList();

      Future<List<T>> chunkedWhereIn<T>(
        Future<List<T>> Function(List<String> chunk) runner,
        List<String> values, {
        int chunkSize = 30,
      }) async {
        if (values.isEmpty) return <T>[];
        final all = <T>[];
        for (var i = 0; i < values.length; i += chunkSize) {
          final slice =
              values.sublist(i, (i + chunkSize).clamp(0, values.length));
          all.addAll(await runner(slice));
        }
        return all;
      }

      final tournamentsByCrewFut = chunkedWhereIn<TournamentsRecord>(
        (chunk) => queryTournamentsRecordOnce(
          queryBuilder: (q) => q.where('crewId', whereIn: chunk),
        ),
        crewIdsList,
      );
      final tournamentsByOrgFut = chunkedWhereIn<TournamentsRecord>(
        (chunk) => queryTournamentsRecordOnce(
          queryBuilder: (q) => q.where('organizationId', whereIn: chunk),
        ),
        orgIdsList,
      );
      final matchupsByCrewFut = chunkedWhereIn<MatchupsRecord>(
        (chunk) => queryMatchupsRecordOnce(
          queryBuilder: (q) => q.where('crewId', whereIn: chunk),
        ),
        crewIdsList,
      );
      final matchupsByOrgFut = chunkedWhereIn<MatchupsRecord>(
        (chunk) => queryMatchupsRecordOnce(
          queryBuilder: (q) => q.where('organizationId', whereIn: chunk),
        ),
        orgIdsList,
      );
      final decksFut = chunkedWhereIn<DecksRecord>(
        (chunk) => queryDecksRecordOnce(
          queryBuilder: (q) => q.where('crewId', whereIn: chunk),
        ),
        crewIdsList,
      );

      final results = await Future.wait([
        tournamentsByCrewFut,
        tournamentsByOrgFut,
        matchupsByCrewFut,
        matchupsByOrgFut,
        decksFut,
      ]);

      // De-dup tournaments/matchups by reference path since the same doc may
      // match both predicates (crewId + organizationId set).
      final tournamentsMerged = <String, TournamentsRecord>{};
      for (final list in [
        results[0] as List<TournamentsRecord>,
        results[1] as List<TournamentsRecord>,
      ]) {
        for (final t in list) {
          tournamentsMerged[t.reference.path] = t;
        }
      }
      final matchupsMerged = <String, MatchupsRecord>{};
      for (final list in [
        results[2] as List<MatchupsRecord>,
        results[3] as List<MatchupsRecord>,
      ]) {
        for (final m in list) {
          matchupsMerged[m.reference.path] = m;
        }
      }

      final tournaments = tournamentsMerged.values.toList();
      final matchups = matchupsMerged.values.toList();
      final decks = results[4] as List<DecksRecord>;

      // Sort by date descending
      tournaments.sort((a, b) {
        final aDate = a.date ?? DateTime(2000);
        final bDate = b.date ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      // Build myDeckIds from ALL the user's crewmates
      final myDeckIds = <String>{};
      for (final d in decks) {
        if (allCrewmateIds.contains(d.crewmateId) && d.deckId.isNotEmpty) {
          myDeckIds.add(d.deckId);
        }
      }

      // Build a deckId → archetype-info lookup for every deck we loaded. Used
      // later to aggregate win/loss counts per archetype for the "top archetypes
      // you played" strip. We prefer the explicit archetype assignment
      // (`avatarName` + `avatarUrl`) when present; otherwise fall back to
      // whatever label the import decided to show.
      final deckArchetype = <String, _DeckArchetypeInfo>{};
      for (final d in decks) {
        if (d.deckId.isEmpty) continue;
        final label = d.avatarName.trim().isNotEmpty
            ? d.avatarName.trim()
            : d.name.trim();
        if (label.isEmpty) continue;
        deckArchetype[d.deckId] = _DeckArchetypeInfo(
          name: label,
          avatarUrl: d.hasAvatarUrl() && d.avatarUrl.isNotEmpty
              ? d.avatarUrl
              : null,
        );
      }

      // Group matchups by tournamentId
      final matchupsByTournament = <String, List<MatchupsRecord>>{};
      for (final m in matchups) {
        if (m.tournamentId.isNotEmpty) {
          matchupsByTournament
              .putIfAbsent(m.tournamentId, () => [])
              .add(m);
        }
      }

      // Build format lookup
      final tournamentFormatMap = <String, String>{};
      for (final t in tournaments) {
        tournamentFormatMap[t.tournamentId] = t.format.toUpperCase();
      }

      setState(() {
        _tournaments = tournaments;
        _matchupsByTournament = matchupsByTournament;
        _myDeckIds = myDeckIds;
        _tournamentFormatMap = tournamentFormatMap;
        _deckArchetype
          ..clear()
          ..addAll(deckArchetype);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tournament data: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Façade over [stats.userResult] — kept as a method so call sites read
  /// naturally against a [MatchupsRecord]. See tests in
  /// `test/tournament_stats_test.dart`.
  int? _userResult(MatchupsRecord matchup, Set<String> myDeckIds) =>
      stats.userResult(_scoresOf(matchup), myDeckIds);

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'Tournaments',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Cinzel Decorative',
                  fontSize: 24.0,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF323236), Color(0xFFE6486F)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: _isLoading
                ? Center(
                    child: SpinKitFadingFour(
                      color: Color(0xFFE6486F),
                      size: 50.0,
                    ),
                  )
                : _tournaments.isEmpty
                    ? _buildEmpty(context)
                    : _buildList(context),
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    // Collect formats
    final formats = <String>{};
    for (final t in _tournaments) {
      if (t.format.isNotEmpty) formats.add(t.format.toUpperCase());
    }

    // Aggregate "top archetypes you played" from the full (unfiltered) data.
    // Key is the normalized archetype name; value is a tally with display info.
    final archetypeTally = <String, _ArchetypeTally>{};
    for (final entry in _matchupsByTournament.entries) {
      final tFormat = _tournamentFormatMap[entry.key] ?? '';
      if (_selectedFormat != null && tFormat != _selectedFormat) continue;
      for (final m in entry.value) {
        final played = _myPlayedDeckId(m, _myDeckIds);
        if (played == null) continue;
        final info = _deckArchetype[played];
        if (info == null) continue;
        final key = info.name.toLowerCase();
        final tally = archetypeTally.putIfAbsent(
          key,
          () => _ArchetypeTally(name: info.name, avatarUrl: info.avatarUrl),
        );
        if (tally.avatarUrl == null && info.avatarUrl != null) {
          tally.avatarUrl = info.avatarUrl;
        }
        final r = _userResult(m, _myDeckIds);
        if (r == null) continue;
        tally.games += 1;
        if (r > 0) tally.wins += 1;
        else if (r < 0) tally.losses += 1;
        else tally.draws += 1;
      }
    }
    final topArchetypes = archetypeTally.values.toList()
      ..sort((a, b) => b.games.compareTo(a.games));

    // Filter tournaments by format and, if set, by archetype (i.e. keep only
    // tournaments where at least one matchup was played with that archetype).
    bool tournamentMatchesArchetype(TournamentsRecord t) {
      if (_selectedArchetype == null) return true;
      final key = _selectedArchetype!.toLowerCase();
      final matchups = _matchupsByTournament[t.tournamentId] ?? const [];
      for (final m in matchups) {
        final played = _myPlayedDeckId(m, _myDeckIds);
        if (played == null) continue;
        final info = _deckArchetype[played];
        if (info != null && info.name.toLowerCase() == key) return true;
      }
      return false;
    }

    final filteredTournaments = _tournaments.where((t) {
      if (_selectedFormat != null &&
          t.format.toUpperCase() != _selectedFormat) {
        return false;
      }
      return tournamentMatchesArchetype(t);
    }).toList();

    // Compute global stats for the current selection (format + archetype).
    int globalWins = 0;
    int globalLosses = 0;
    int globalDraws = 0;
    final archetypeKey = _selectedArchetype?.toLowerCase();
    for (final entry in _matchupsByTournament.entries) {
      final tFormat = _tournamentFormatMap[entry.key] ?? '';
      if (_selectedFormat != null && tFormat != _selectedFormat) continue;
      for (final m in entry.value) {
        if (archetypeKey != null) {
          final played = _myPlayedDeckId(m, _myDeckIds);
          if (played == null) continue;
          final info = _deckArchetype[played];
          if (info == null || info.name.toLowerCase() != archetypeKey) {
            continue;
          }
        }
        final r = _userResult(m, _myDeckIds);
        if (r == null) continue;
        if (r > 0) globalWins++;
        else if (r < 0) globalLosses++;
        else globalDraws++;
      }
    }
    final globalTotal = globalWins + globalLosses + globalDraws;
    final winRate =
        globalTotal > 0 ? (globalWins / globalTotal * 100).round() : 0;

    return Column(
      children: [
        _buildStatsHeader(
          context,
          formats: formats,
          filteredCount: filteredTournaments.length,
          wins: globalWins,
          losses: globalLosses,
          winRate: winRate,
          topArchetypes: topArchetypes,
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filteredTournaments.length,
              itemBuilder: (context, index) {
                final t = filteredTournaments[index];
                final tMatchups =
                    _matchupsByTournament[t.tournamentId] ?? [];
                return _buildTournamentCard(
                    context, t, tMatchups, _myDeckIds);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Façade over [stats.myPlayedDeckId].
  String? _myPlayedDeckId(MatchupsRecord matchup, Set<String> myDeckIds) =>
      stats.myPlayedDeckId(_scoresOf(matchup), myDeckIds);

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined,
                color: FlutterFlowTheme.of(context).secondaryText, size: 80),
            SizedBox(height: 16),
            Text(
              'No tournaments yet',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Cinzel Decorative',
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 20,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Import your tournament history from Spicerack to see your results here.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Noto Sans',
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.6),
                    fontSize: 14,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context, {
    required Set<String> formats,
    required int filteredCount,
    required int wins,
    required int losses,
    required int winRate,
    required List<_ArchetypeTally> topArchetypes,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Format filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'ALL', null),
                ...formats.map((f) => _buildFilterChip(context, f, f)),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statColumn(context, '$filteredCount', 'Events'),
              _statColumn(context, '$wins', 'Wins',
                  color: Color(0xFF2ECC71)),
              _statColumn(context, '$losses', 'Losses',
                  color: Color(0xFFE74C3C)),
              _statColumn(context, '$winRate%', 'Win rate',
                  color: winRate >= 50
                      ? Color(0xFF2ECC71)
                      : Color(0xFFE74C3C)),
            ],
          ),
          if (topArchetypes.isNotEmpty) ...[
            SizedBox(height: 12),
            Divider(
              height: 1,
              color: FlutterFlowTheme.of(context)
                  .primaryText
                  .withOpacity(0.1),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 2, bottom: 6),
              child: Text(
                'Top archetypes played',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.65),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final a in topArchetypes.take(8))
                    _buildArchetypeChip(context, a),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArchetypeChip(BuildContext context, _ArchetypeTally a) {
    final isSelected =
        _selectedArchetype?.toLowerCase() == a.name.toLowerCase();
    final total = a.wins + a.losses + a.draws;
    final winRate = total > 0 ? (a.wins / total * 100).round() : null;
    final accent = FlutterFlowTheme.of(context).primaryText;

    return Padding(
      padding: EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedArchetype = isSelected ? null : a.name;
        }),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withOpacity(0.15)
                : Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? accent.withOpacity(0.5)
                  : accent.withOpacity(0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (a.avatarUrl != null && a.avatarUrl!.isNotEmpty)
                ClipOval(
                  child: Image.network(
                    a.avatarUrl!,
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => SizedBox(width: 22, height: 22),
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.style,
                      size: 12, color: accent.withOpacity(0.6)),
                ),
              SizedBox(width: 6),
              Text(
                a.name,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: accent.withOpacity(isSelected ? 1.0 : 0.85),
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              SizedBox(width: 6),
              Text(
                winRate != null ? '${a.games}g · $winRate%' : '${a.games}g',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: accent.withOpacity(0.55),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, String? format) {
    final isSelected = _selectedFormat == format;
    final color = format != null ? _formatColor(format) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFormat = format),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color.withOpacity(0.7)
                  : FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              color: isSelected
                  ? color
                  : FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.5),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statColumn(BuildContext context, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Cinzel Decorative',
                color: color ?? FlutterFlowTheme.of(context).primaryText,
                fontSize: 20,
              ),
        ),
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Noto Sans',
                color:
                    FlutterFlowTheme.of(context).primaryText.withOpacity(0.6),
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildTournamentCard(
    BuildContext context,
    TournamentsRecord tournament,
    List<MatchupsRecord> matchups,
    Set<String> myDeckIds,
  ) {
    final dateStr = tournament.date != null
        ? DateFormat('MMM d, yyyy').format(tournament.date!)
        : '';
    final format = tournament.format.toUpperCase();

    // Compute per-tournament result
    int tWins = 0;
    int tLosses = 0;
    int tDraws = 0;
    for (final m in matchups) {
      final r = _userResult(m, myDeckIds);
      if (r == null) continue;
      if (r > 0) tWins++;
      else if (r < 0) tLosses++;
      else tDraws++;
    }
    final tTotal = tWins + tLosses + tDraws;

    return Listener(
      onPointerDown: (event) {
        // Only allow primary button (left click / single tap)
        if (event.buttons != kPrimaryButton) return;
      },
      child: GestureDetector(
      onTap: () {
        context.pushNamed(
          'TournamentDetail',
          queryParameters: {
            'tournamentId':
                serializeParam(tournament.tournamentId, ParamType.String),
          }.withoutNulls,
        );
      },
      onSecondaryTap: () {}, // Swallow right-click
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _formatColor(format).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Trophy icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _formatColor(format).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: _formatColor(format),
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Noto Sans',
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _formatColor(format).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          format,
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            color: _formatColor(format),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        dateStr,
                        style:
                            FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: 'Noto Sans',
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText
                                      .withOpacity(0.5),
                                  fontSize: 12,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Result badge W/L/D
            if (tTotal > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: tWins > tLosses
                      ? Color(0xFF2ECC71).withOpacity(0.15)
                      : tLosses > tWins
                          ? Color(0xFFE74C3C).withOpacity(0.15)
                          : Color(0xFFF1C40F).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tDraws > 0
                      ? '$tWins/$tLosses/$tDraws'
                      : '$tWins/$tLosses',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    color: tWins > tLosses
                        ? Color(0xFF2ECC71)
                        : tLosses > tWins
                            ? Color(0xFFE74C3C)
                            : Color(0xFFF1C40F),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color:
                  FlutterFlowTheme.of(context).primaryText.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    ),  // close Listener
    );
  }
}

// _DeckArchetypeInfo and _ArchetypeTally are now typedefs over the pure-Dart
// types in lib/backend/stats/tournament_stats.dart (see top of file).
