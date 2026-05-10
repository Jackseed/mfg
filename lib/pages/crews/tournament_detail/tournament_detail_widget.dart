import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/spicerack/spicerack_import.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_icons.dart';
import '/page_component/archetype_editor/archetype_editor_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'tournament_detail_model.dart';
export 'tournament_detail_model.dart';

class TournamentDetailWidget extends StatefulWidget {
  const TournamentDetailWidget({Key? key, this.tournamentId}) : super(key: key);

  final String? tournamentId;

  @override
  State<TournamentDetailWidget> createState() => _TournamentDetailWidgetState();
}

class _TournamentDetailWidgetState extends State<TournamentDetailWidget> {
  late TournamentDetailModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Map of format -> color for badges.
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

  /// MTG color name -> icon
  static final _colorIcons = {
    'W': FFIcons.kwhite,
    'U': FFIcons.kblue,
    'B': FFIcons.kblack,
    'R': FFIcons.kred,
    'G': FFIcons.kgreen,
  };

  // Increment to force FutureBuilder refresh after archetype edit
  int _refreshKey = 0;

  // True while expandTournament is running so we can disable the action button
  // and show a small inline indicator.
  bool _isExpanding = false;
  String _expandStatus = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentDetailModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'TournamentDetail'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Pull down every match in the tournament's bracket from Spicerack.
  ///
  /// The default import only stores the user's own matches, so the org-level
  /// ranking is partial. From here, the user can opt in to fetching everyone
  /// else's games on a per-tournament basis.
  Future<void> _expandTournament(TournamentsRecord tournament) async {
    final eventId = tournament.spicerackEventId;
    if (eventId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ce tournoi n\'a pas d\'identifiant Spicerack.'),
      ));
      return;
    }

    setState(() {
      _isExpanding = true;
      _expandStatus = 'Récupération du bracket…';
    });

    try {
      final importer = SpicerackImporter();
      await importer.expandTournament(
        spicerackEventId: eventId,
        onProgress: (current, total, status) {
          if (mounted) {
            setState(() {
              _expandStatus = status;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _isExpanding = false;
          _expandStatus = '';
          _refreshKey++; // force FutureBuilder to re-fetch
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Toutes les parties ont été chargées.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExpanding = false;
          _expandStatus = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) => FutureBuilder<List<TournamentsRecord>>(
        future: queryTournamentsRecordOnce(
          queryBuilder: (q) =>
              q.where('tournamentId', isEqualTo: widget.tournamentId),
          singleRecord: true,
        ),
        builder: (context, tournamentSnap) {
          if (!tournamentSnap.hasData) {
            return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              body: Center(
                child: SpinKitFadingFour(
                  color: Color(0xFFE6486F),
                  size: 50.0,
                ),
              ),
            );
          }

          if (tournamentSnap.data!.isEmpty) {
            return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                title: Text('Tournament',
                    style: FlutterFlowTheme.of(context).titleLarge),
              ),
              body: Center(
                child: Text('Tournament not found',
                    style: FlutterFlowTheme.of(context).bodyMedium),
              ),
            );
          }

          final tournament = tournamentSnap.data!.first;
          final format = tournament.format.toUpperCase();
          final dateStr = tournament.date != null
              ? DateFormat('MMM d, yyyy').format(tournament.date!)
              : '';

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primary,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tournament.name,
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'Cinzel Decorative',
                          fontSize: 18.0,
                          letterSpacing: 0.9,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _formatColor(format).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: _formatColor(format).withOpacity(0.5)),
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
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Noto Sans',
                              color: FlutterFlowTheme.of(context)
                                  .primaryText
                                  .withOpacity(0.6),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: true,
              elevation: 0.0,
              actions: [
                if (tournament.spicerackEventId != 0)
                  IconButton(
                    tooltip: _isExpanding
                        ? _expandStatus
                        : 'Charger toutes les parties du tournoi',
                    icon: _isExpanding
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  FlutterFlowTheme.of(context).primaryText,
                            ),
                          )
                        : Icon(
                            Icons.cloud_download_outlined,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 22,
                          ),
                    onPressed:
                        _isExpanding ? null : () => _expandTournament(tournament),
                  ),
              ],
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
                child: _buildMatchups(context, tournament),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchups(BuildContext context, TournamentsRecord tournament) {
    return FutureBuilder<_TournamentData>(
      key: ValueKey(_refreshKey),
      future: _loadTournamentData(tournament),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(
            child: SpinKitFadingFour(
              color: Color(0xFFE6486F),
              size: 50.0,
            ),
          );
        }

        final data = snap.data!;
        if (data.matchups.isEmpty) {
          return _buildEmptyMatchups(context);
        }

        return Column(
          children: [
            // Summary header
            _buildSummaryHeader(
              context,
              data.totalWins + data.totalLosses + data.totalDraws,
              data.totalWins,
              data.totalLosses,
              data.totalDraws,
            ),
            // Matchup list grouped by round
            Expanded(
              child: _buildMatchupList(context, data),
            ),
          ],
        );
      },
    );
  }

  /// Load only matchups that involve the current user, plus enough deck and
  /// crewmate info to label both sides of those matches.
  ///
  /// Since the import now stores every match in a tournament (including ones
  /// the user didn't play in), this page narrows down quickly:
  ///   1) fetch all matchups for the tournament
  ///   2) resolve the user's crewmate ids → user deck ids (one focused query)
  ///   3) keep only matchups involving the user
  ///   4) fetch opponent decks via the deckIds in those filtered matchups
  ///   5) resolve crewmate names so labels show properly
  ///
  /// Net effect: a player who plays one match per round in a 12-round
  /// tournament loads ~12 user matchups + ~24 decks instead of 100s.
  Future<_TournamentData> _loadTournamentData(TournamentsRecord tournament) async {
    final allMatchups = await queryMatchupsRecordOnce(
      queryBuilder: (q) =>
          q.where('tournamentId', isEqualTo: tournament.tournamentId),
    );

    if (allMatchups.isEmpty) {
      return _TournamentData(
        matchups: [],
        deckMap: {},
        crewmateNameMap: {},
        myDeckIds: {},
        totalWins: 0,
        totalLosses: 0,
        totalDraws: 0,
      );
    }

    // 1. Resolve every crewmate that maps to the current user (across crews).
    // Use userReference (DocumentReference) — not userId which is the
    // Spicerack integer ID, not the Firebase UID.
    final myCrewmateIds = <String>{};
    if (currentUserReference != null) {
      try {
        final allCrewmates = await FirebaseFirestore.instance
            .collectionGroup('crewmates')
            .where('userReference', isEqualTo: currentUserReference)
            .get();
        for (final doc in allCrewmates.docs) {
          myCrewmateIds.add(doc.id);
        }
      } catch (_) {/* fault-tolerant */}
    }

    // Fallback: if the collection-group query returned nothing (index missing
    // or crewmates lack userReference), use the user's crewmateRef directly.
    if (myCrewmateIds.isEmpty && currentUserDocument?.crewmateRef != null) {
      myCrewmateIds.add(currentUserDocument!.crewmateRef!.id);
    }

    // 2. Fetch decks for THIS tournament (single-field index, always
    //    available) and filter client-side to those owned by the user.
    final tournamentDecks = await queryDecksRecordOnce(
      queryBuilder: (q) =>
          q.where('tournamentId', isEqualTo: tournament.tournamentId),
    );
    final myDecks = tournamentDecks
        .where((d) => myCrewmateIds.contains(d.crewmateId))
        .toList();
    final myDeckIds = <String>{
      for (final d in myDecks) if (d.deckId.isNotEmpty) d.deckId,
    };

    // 3. Filter matchups to user-only.
    final matchups = allMatchups.where((m) {
      for (final s in m.scores) {
        if (myDeckIds.contains(s.deckId)) return true;
      }
      return false;
    }).toList();

    // 4. Tournament-scoped deck snapshot already includes opponent decks.
    final deckMap = <String, DecksRecord>{};
    for (final d in tournamentDecks) {
      if (d.deckId.isNotEmpty) deckMap[d.deckId] = d;
    }

    // 5. Resolve crewmate names — only for decks actually used by the user's
    //    filtered matchups, so we don't pay the round-trip on unrelated ones.
    final relevantRefs = <DocumentReference>{};
    for (final m in matchups) {
      for (final s in m.scores) {
        final d = deckMap[s.deckId];
        if (d != null && d.hasCrewmateRef()) {
          relevantRefs.add(d.crewmateRef!);
        }
      }
    }
    final crewmateRefs = relevantRefs;
    final crewmateNameMap = <String, String>{};
    if (crewmateRefs.isNotEmpty) {
      final docs = await Future.wait(crewmateRefs.map((r) => r.get()));
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final name = data?['name'] as String?;
        if (name == null || name.trim().isEmpty) continue;
        crewmateNameMap[doc.id] = name.trim();
        final uid = data?['userId'] as String?;
        if (uid != null && uid.isNotEmpty) {
          crewmateNameMap[uid] = name.trim();
        }
      }
    }

    // Compute summary
    int totalWins = 0;
    int totalLosses = 0;
    int totalDraws = 0;
    for (final m in matchups) {
      final result = _userResult(m, myDeckIds);
      if (result == null) continue;
      if (result > 0) totalWins++;
      else if (result < 0) totalLosses++;
      else totalDraws++;
    }

    final sortedMatchups = [...matchups]
      ..sort((a, b) => a.round.compareTo(b.round));

    return _TournamentData(
      matchups: sortedMatchups,
      deckMap: deckMap,
      crewmateNameMap: crewmateNameMap,
      myDeckIds: myDeckIds,
      totalWins: totalWins,
      totalLosses: totalLosses,
      totalDraws: totalDraws,
    );
  }

  /// Returns +1 if user won, -1 if user lost, 0 if draw, null if user not involved.
  int? _userResult(MatchupsRecord matchup, Set<String> myDeckIds) {
    if (matchup.scores.length < 2) return null;
    final s1 = matchup.scores.first;
    final s2 = matchup.scores.last;

    int myScore;
    int opponentScore;
    if (myDeckIds.contains(s1.deckId)) {
      myScore = s1.score;
      opponentScore = s2.score;
    } else if (myDeckIds.contains(s2.deckId)) {
      myScore = s2.score;
      opponentScore = s1.score;
    } else {
      return null; // User not involved in this matchup
    }

    if (myScore > opponentScore) return 1;
    if (myScore < opponentScore) return -1;
    return 0;
  }

  Widget _buildEmptyMatchups(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'No matchups recorded',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Cinzel Decorative',
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 18,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'This tournament has no matchup data yet.',
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

  Widget _buildSummaryHeader(
      BuildContext context, int matchCount, int wins, int losses, int draws) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statColumn(context, '$matchCount', 'Rounds'),
          _statColumn(context, '$wins', 'Wins',
              color: Color(0xFF2ECC71)),
          _statColumn(context, '$losses', 'Losses',
              color: Color(0xFFE74C3C)),
          if (draws > 0)
            _statColumn(context, '$draws', 'Draws',
                color: Color(0xFFF1C40F)),
        ],
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
                fontSize: 22,
              ),
        ),
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Noto Sans',
                color:
                    FlutterFlowTheme.of(context).primaryText.withOpacity(0.6),
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  Widget _buildMatchupList(BuildContext context, _TournamentData data) {
    final items = <Widget>[];
    int? lastRound;
    for (final matchup in data.matchups) {
      final round = matchup.round;
      if (round != lastRound) {
        lastRound = round;
        items.add(Padding(
          padding: EdgeInsets.fromLTRB(0, items.isEmpty ? 0 : 12, 0, 6),
          child: Text(
            round > 0 ? 'Round $round' : 'Round —',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Noto Sans',
                  color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
          ),
        ));
      }
      items.add(_buildMatchupCard(
          context, matchup, data.deckMap, data.myDeckIds, data.crewmateNameMap));
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: items,
    );
  }

  Widget _buildMatchupCard(BuildContext context, MatchupsRecord matchup,
      Map<String, DecksRecord> deckMap, Set<String> myDeckIds,
      Map<String, String> crewmateNameMap) {
    if (matchup.scores.length < 2) {
      return SizedBox.shrink();
    }

    final score1 = matchup.scores.first;
    final score2 = matchup.scores.last;
    final deck1 = deckMap[score1.deckId];
    final deck2 = deckMap[score2.deckId];
    final playerName1 = deck1 != null ? crewmateNameMap[deck1.crewmateId] : null;
    final playerName2 = deck2 != null ? crewmateNameMap[deck2.crewmateId] : null;

    // Determine result from user's perspective
    final result = _userResult(matchup, myDeckIds);
    Color resultColor = Color(0xFF95A5A6); // unknown
    String resultText = '—';
    if (result != null) {
      if (result > 0) {
        resultColor = Color(0xFF2ECC71);
        resultText = 'WIN';
      } else if (result < 0) {
        resultColor = Color(0xFFE74C3C);
        resultText = 'LOSS';
      } else {
        resultColor = Color(0xFFF1C40F);
        resultText = 'DRAW';
      }
    }

    return InkWell(
      onTap: () {
        context.pushNamed(
          'B4_MatchupView',
          queryParameters: {
            'matchupId':
                serializeParam(matchup.matchupId, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: resultColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            // Result badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                resultText,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: resultColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 8),
            // VS layout
            Row(
              children: [
                // Player 1 (left)
                Expanded(
                  child: _buildPlayerSide(
                    context,
                    deck1,
                    score1.score,
                    isLeft: true,
                    onAvatarTap: deck1 != null
                        ? () => showArchetypeEditor(context, deck1,
                              onSaved: () => setState(() => _refreshKey++))
                        : null,
                    playerName: playerName1,
                  ),
                ),
                // VS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Cinzel Decorative',
                          color: FlutterFlowTheme.of(context)
                              .primaryText
                              .withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Player 2 (right)
                Expanded(
                  child: _buildPlayerSide(
                    context,
                    deck2,
                    score2.score,
                    isLeft: false,
                    onAvatarTap: deck2 != null
                        ? () => showArchetypeEditor(context, deck2,
                              onSaved: () => setState(() => _refreshKey++))
                        : null,
                    playerName: playerName2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSide(
    BuildContext context,
    DecksRecord? deck,
    int score, {
    required bool isLeft,
    VoidCallback? onAvatarTap,
    String? playerName,
  }) {
    final deckName = (deck != null && deck.avatarName.isNotEmpty)
        ? deck.avatarName
        : deck?.name ?? 'Unknown';
    final colors = deck?.colors ?? [];
    final hasAvatar = deck != null && deck.avatarUrl.isNotEmpty;

    // Build avatar widget
    Widget avatarContent;
    if (hasAvatar) {
      avatarContent = Container(
        width: 36,
        height: 36,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: CachedNetworkImage(
          imageUrl: deck.avatarUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildInitialsAvatar(context, deckName),
          errorWidget: (context, url, error) =>
              _buildColorIconsOrInitials(context, deckName, colors),
        ),
      );
    } else if (colors.isNotEmpty) {
      avatarContent = _buildColorIconsOrInitials(context, deckName, colors);
    } else {
      avatarContent = _buildInitialsAvatar(context, deckName);
    }

    // Wrap with edit overlay + tap if no avatar
    Widget avatar = GestureDetector(
      onTap: onAvatarTap,
      child: Stack(
        children: [
          avatarContent,
          if (!hasAvatar && onAvatarTap != null)
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
                child: Icon(Icons.edit, size: 9, color: Colors.white),
              ),
            ),
        ],
      ),
    );

    // Score widget
    final scoreWidget = Text(
      '$score',
      style: FlutterFlowTheme.of(context).headlineSmall.override(
            fontFamily: 'Cinzel Decorative',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 24,
          ),
    );

    // Deck name
    final nameWidget = Text(
      deckName,
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

    // Color icons row
    Widget colorRow = SizedBox.shrink();
    if (colors.isNotEmpty) {
      colorRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((c) {
          final icon = _colorIcons[c.toUpperCase()];
          if (icon != null) {
            return Padding(
              padding: EdgeInsets.only(right: 2),
              child: Icon(icon, size: 12,
                  color: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.7)),
            );
          }
          return SizedBox.shrink();
        }).toList(),
      );
    }

    Widget? playerNameWidget;
    if (playerName != null && playerName.isNotEmpty) {
      playerNameWidget = Text(
        playerName,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'Noto Sans',
              color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.5),
              fontSize: 10,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: isLeft ? TextAlign.left : TextAlign.right,
      );
    }

    if (isLeft) {
      return Row(
        children: [
          avatar,
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (playerNameWidget != null) playerNameWidget,
                nameWidget,
                SizedBox(height: 2),
                colorRow,
              ],
            ),
          ),
          SizedBox(width: 4),
          scoreWidget,
        ],
      );
    } else {
      return Row(
        children: [
          scoreWidget,
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (playerNameWidget != null) playerNameWidget,
                nameWidget,
                SizedBox(height: 2),
                Align(alignment: Alignment.centerRight, child: colorRow),
              ],
            ),
          ),
          SizedBox(width: 8),
          avatar,
        ],
      );
    }
  }


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
              return Icon(icon, size: 10,
                  color: FlutterFlowTheme.of(context).primaryText);
            }
            return SizedBox.shrink();
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
}

/// Internal data holder for tournament detail.
class _TournamentData {
  final List<MatchupsRecord> matchups;
  final Map<String, DecksRecord> deckMap;
  final Map<String, String> crewmateNameMap;
  final Set<String> myDeckIds;
  final int totalWins;
  final int totalLosses;
  final int totalDraws;

  _TournamentData({
    required this.matchups,
    required this.deckMap,
    required this.crewmateNameMap,
    required this.myDeckIds,
    required this.totalWins,
    required this.totalLosses,
    required this.totalDraws,
  });
}
