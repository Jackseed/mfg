import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/spicerack/archetype_card_resolver.dart';
import '/backend/spicerack/archetype_service.dart';
import '/backend/spicerack/spicerack_import.dart';
import 'dart:async';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_icons.dart';
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
                        ? () => _showArchetypeEditor(deck1)
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
                        ? () => _showArchetypeEditor(deck2)
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

  /// Opens a bottom sheet to edit the deck archetype and fetch Scryfall art.
  Future<void> _showArchetypeEditor(DecksRecord deck) async {
    final nameController = TextEditingController(text: deck.name);
    final controller = TextEditingController(
      text: deck.avatarName.isNotEmpty ? deck.avatarName : '',
    );
    final moxfieldController = TextEditingController(
      text: deck.moxfieldUrl,
    );
    String? previewUrl = (deck.avatarUrl.isNotEmpty &&
            deck.avatarUrl.startsWith('http'))
        ? deck.avatarUrl
        : null;
    String? previewCardName =
        deck.avatarCardName.isNotEmpty ? deck.avatarCardName : null;
    bool searching = false;
    bool searchDone = false; // true after at least one search attempt

    // Existing decks for this crewmate — shown as selection chips under the
    // name field so the user can link this snapshot to a known deck.
    // Query only by crewId (single-field index, always available) and filter
    // crewmateId client-side to avoid missing composite index errors.
    final existingDecksFuture = deck.crewId.isNotEmpty
        ? queryDecksRecordOnce(
            queryBuilder: (q) =>
                q.where('crewId', isEqualTo: deck.crewId),
          ).then((all) => all
              .where((d) =>
                  deck.crewmateId.isEmpty ||
                  d.crewmateId == deck.crewmateId)
              .toList())
        : Future.value(<DecksRecord>[]);
    DecksRecord? selectedTemplate;

    // Live archetype suggestions — from Firestore `archetypes`, falling back to
    // the static known-archetype list when the collection is empty or offline.
    final archetypeService = ArchetypeService();
    List<_ArchetypeSuggestion> suggestions = [];

    // Scryfall card typeahead (for manual icon override).
    final iconController = TextEditingController();
    // Each entry: (name, artCropUrl). artCropUrl may be null for DFC / token.
    List<({String name, String? url})> iconSuggestions = [];
    bool iconLoading = false;
    // Manual debounce timer — avoids global EasyDebounce singleton issues.
    Timer? iconDebounce;
    bool iconNoResult = false;
    // Guard against callbacks firing after the sheet is closed and controllers
    // have been disposed (showModalBottomSheet awaits the exit animation).
    bool sheetActive = true;

    Future<List<_ArchetypeSuggestion>> fetchSuggestions(String text) async {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return [];

      // 1. Firestore-backed matches.
      final remote = await archetypeService.search(trimmed, limit: 8);
      final seen = <String>{};
      final merged = <_ArchetypeSuggestion>[];
      for (final a in remote) {
        final key = a.nameLower.isNotEmpty ? a.nameLower : a.name.toLowerCase();
        if (seen.add(key)) {
          merged.add(_ArchetypeSuggestion.fromRecord(a));
        }
      }

      // 2. Fill the rest from the static keyword map (offline / cold start).
      if (merged.length < 8) {
        final lower = trimmed.toLowerCase();
        for (final k in ArchetypeCardResolver.knownArchetypes) {
          if (!k.contains(lower)) continue;
          if (seen.add(k)) {
            merged.add(_ArchetypeSuggestion.fromStatic(k));
            if (merged.length >= 8) break;
          }
        }
      }
      return merged;
    }

    String toTitleCase(String s) => s
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              // Deck name field
              Text(
                'Nom du deck',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.5),
                      fontSize: 12,
                    ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: deck.name,
                  hintStyle: TextStyle(
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.4),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              // Existing decks for this player — tap to pre-fill the form
              FutureBuilder<List<DecksRecord>>(
                future: existingDecksFuture,
                builder: (ctx, snap) {
                  if (snap.hasError) {
                    debugPrint('[DeckPicker] error: ${snap.error}');
                  }
                  if (!snap.hasData) return const SizedBox.shrink();
                  debugPrint('[DeckPicker] loaded ${snap.data!.length} decks '
                      'for crewmateId=${deck.crewmateId}');
                  bool isPlaceholder(String name) {
                    final lower = name.toLowerCase().trim();
                    return lower.isEmpty ||
                        lower == 'unknown' ||
                        lower == 'unknown deck' ||
                        lower.endsWith("'s deck") ||
                        lower.endsWith("s deck");
                  }

                  final seen = <String>{};
                  final others = (snap.data!
                        ..sort((a, b) => a.name.compareTo(b.name)))
                      .where((d) =>
                          d.reference.id != deck.reference.id &&
                          !isPlaceholder(d.name) &&
                          seen.add(d.name))
                      .toList();
                  debugPrint('[DeckPicker] showing ${others.length} chips: '
                      '${others.map((d) => d.name).join(', ')}');
                  if (others.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: others.map((d) {
                          final isSelected = selectedTemplate?.reference.id ==
                              d.reference.id;
                          return ActionChip(
                            label: Text(
                              d.name,
                              style: TextStyle(
                                fontFamily: 'Noto Sans',
                                fontSize: 12,
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary
                                    : Colors.white,
                              ),
                            ),
                            backgroundColor: isSelected
                                ? FlutterFlowTheme.of(context).tertiary
                                : const Color(0xFF3A3A42),
                            side: BorderSide(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).tertiary
                                  : const Color(0xFF5A5A65),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            onPressed: () {
                              nameController.text = d.name;
                              controller.text = d.avatarName;
                              moxfieldController.text = d.moxfieldUrl;
                              setSheet(() {
                                selectedTemplate = d;
                                previewUrl =
                                    d.avatarUrl.isNotEmpty &&
                                            d.avatarUrl.startsWith('http')
                                        ? d.avatarUrl
                                        : null;
                                previewCardName = d.avatarCardName.isNotEmpty
                                    ? d.avatarCardName
                                    : null;
                                searchDone = previewUrl != null;
                                suggestions = [];
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16),
              Text(
                'Archétype',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.5),
                      fontSize: 12,
                    ),
              ),
              SizedBox(height: 12),
              // Input + search button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (val) async {
                        setSheet(() {
                          previewUrl = null;
                          searchDone = false;
                        });
                        final found = await fetchSuggestions(val);
                        // Guard against stale responses and post-dismiss callbacks.
                        // ctx.mounted is still true during the exit animation, so
                        // we also check sheetActive (set false before Navigator.pop).
                        if (!ctx.mounted || !sheetActive) return;
                        if (controller.text != val) return;
                        setSheet(() => suggestions = found);
                      },
                      style: TextStyle(
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontFamily: 'Noto Sans',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ex: Reanimator, Loam Pox...',
                        hintStyle: TextStyle(
                          color: FlutterFlowTheme.of(context)
                              .primaryText
                              .withOpacity(0.4),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context)
                            .primaryText
                            .withOpacity(0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: searching
                        ? null
                        : () async {
                            setSheet(() {
                              searching = true;
                              searchDone = false;
                            });
                            final term = controller.text.trim();
                            final url =
                                await ArchetypeCardResolver.resolve(term);
                            setSheet(() {
                              previewUrl = url;
                              previewCardName = url != null ? term : null;
                              searching = false;
                              searchDone = true;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).secondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: searching
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Chercher',
                            style: TextStyle(
                                fontFamily: 'Noto Sans', fontSize: 13)),
                  ),
                ],
              ),
              // Autocomplete suggestions
              if (suggestions.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: suggestions.map((s) {
                    final label = s.displayName.isNotEmpty
                        ? s.displayName
                        : toTitleCase(s.name);
                    return ActionChip(
                      label: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: const Color(0xFF3A3A42),
                      side: const BorderSide(
                        color: Color(0xFF5A5A65),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      onPressed: () async {
                        controller.text = label;
                        setSheet(() {
                          suggestions = [];
                          searching = true;
                          searchDone = false;
                          previewUrl = null;
                        });
                        // Prefer the pre-resolved avatar from the archetype
                        // record; fall back to Scryfall resolver.
                        String? url = s.avatarUrl;
                        String? cardName = s.avatarCardName;
                        if (url == null || url.isEmpty) {
                          url = await ArchetypeCardResolver.resolve(s.name);
                          cardName = url != null ? s.name : null;
                        }
                        setSheet(() {
                          previewUrl = url;
                          previewCardName = cardName;
                          searching = false;
                          searchDone = true;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              // Card preview / feedback
              if (previewUrl != null) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: previewUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFF2A2A2F),
                          child: const Icon(Icons.image_not_supported_outlined,
                              size: 24, color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Image trouvée !',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Noto Sans',
                              color: const Color(0xFF2ECC71),
                              fontSize: 12,
                            ),
                      ),
                    ),
                  ],
                ),
              ] else if (searchDone && !searching) ...[
                SizedBox(height: 12),
                Text(
                  'Aucune image trouvée. Tu peux quand même sauvegarder le nom.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Noto Sans',
                        color: const Color(0xFFF1C40F),
                        fontSize: 12,
                      ),
                ),
              ],
              SizedBox(height: 16),
              // Moxfield link (optional) — mirrored into spicerackDecks so
              // other crews inherit it on the next import.
              Text(
                'Lien Moxfield (optionnel)',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.5),
                      fontSize: 12,
                    ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: moxfieldController,
                keyboardType: TextInputType.url,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontFamily: 'Noto Sans',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'https://www.moxfield.com/decks/...',
                  hintStyle: TextStyle(
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.4),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.07),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 16),
              // Scryfall card typeahead — lets the user pick a specific card
              // as the deck avatar, overriding the auto-resolved archetype icon.
              Text(
                'Icône (carte Scryfall — optionnel)',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Noto Sans',
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.5),
                      fontSize: 12,
                    ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: iconController,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontFamily: 'Noto Sans',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'ex: Thoughtseize, Ragavan...',
                  hintStyle: TextStyle(
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.4),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.07),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixIcon: iconLoading
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: FlutterFlowTheme.of(context)
                                  .primaryText
                                  .withOpacity(0.5),
                            ),
                          ),
                        )
                      : null,
                ),
                onChanged: (val) {
                  iconDebounce?.cancel();
                  final query = val.trim();
                  if (query.length < 2) {
                    setSheet(() {
                      iconSuggestions = [];
                      iconLoading = false;
                      iconNoResult = false;
                    });
                    return;
                  }
                  setSheet(() { iconLoading = true; iconNoResult = false; });
                  iconDebounce =
                      Timer(const Duration(milliseconds: 600), () async {
                    if (!sheetActive) return;
                    debugPrint('[IconSearch] calling Scryfall for: "$query"');
                    final result = await ScryfallIlluByNameCall.call(
                        cardName: query);
                    if (!sheetActive) return;
                    debugPrint('[IconSearch] status=${result.statusCode} '
                        'succeeded=${result.succeeded} '
                        'body=${result.jsonBody?.toString().substring(0, (result.jsonBody?.toString().length ?? 0).clamp(0, 200))}');
                    final names =
                        ScryfallIlluByNameCall.names(result.jsonBody) ?? [];
                    final urls =
                        ScryfallIlluByNameCall.images(result.jsonBody) ?? [];
                    debugPrint('[IconSearch] names=$names urls.length=${urls.length}');
                    final suggestions = List.generate(
                      names.length.clamp(0, 6),
                      (i) => (
                        name: names[i],
                        url: i < urls.length ? urls[i] : null,
                      ),
                    );
                    setSheet(() {
                      iconSuggestions = suggestions;
                      iconNoResult = suggestions.isEmpty;
                      iconLoading = false;
                    });
                  });
                },
              ),
              if (iconSuggestions.isNotEmpty) ...[
                SizedBox(height: 8),
                // Card rows: art_crop thumbnail + card name, same pattern as
                // deck_form_widget so the user sees what they're picking.
                Column(
                  children: iconSuggestions.map((card) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        iconController.text = card.name;
                        setSheet(() {
                          iconSuggestions = [];
                          if (card.url != null) {
                            previewUrl = card.url;
                            previewCardName = card.name;
                            searchDone = true;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: card.url != null
                                  ? Image.network(
                                      card.url!,
                                      width: 48,
                                      height: 34,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(
                                              width: 48, height: 34),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 34,
                                      color: const Color(0xFF2A2A2F),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                card.name,
                                style: const TextStyle(
                                  fontFamily: 'Noto Sans',
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (iconNoResult && !iconLoading) ...[
                SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.sentiment_dissatisfied_outlined,
                      size: 16,
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.4)),
                  SizedBox(width: 6),
                  Text(
                    'Aucune carte trouvée',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 12,
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withOpacity(0.5),
                    ),
                  ),
                ]),
              ],
              SizedBox(height: 20),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    // Capture all values synchronously before any async work.
                    final deckNameValue = nameController.text.trim();
                    final archetypeName = controller.text.trim();
                    final moxfield = moxfieldController.text.trim();
                    final deckRef = deck.reference;
                    final savedPreviewUrl = previewUrl;
                    final savedPreviewCardName = previewCardName;
                    final savedTemplateRef = selectedTemplate?.reference;

                    // Close the sheet immediately so no controller is accessed
                    // after this point (avoids disposed-controller errors during
                    // the Firestore awaits that follow).
                    sheetActive = false;
                    iconDebounce?.cancel();
                    Navigator.of(ctx).pop();

                    // Async writes — controllers may be disposed by now but we
                    // only use local variables captured above.
                    DocumentReference? archetypeRef;
                    if (archetypeName.isNotEmpty) {
                      try {
                        final archetype =
                            await archetypeService.findOrCreate(archetypeName);
                        archetypeRef = archetype.reference;
                      } catch (_) {}
                    }
                    try {
                      await deckRef.update({
                        if (deckNameValue.isNotEmpty) 'name': deckNameValue,
                        'avatarName': archetypeName.isNotEmpty ? archetypeName : '',
                        if (archetypeRef != null) 'archetypeRef': archetypeRef,
                        if (savedPreviewUrl != null) 'avatarUrl': savedPreviewUrl,
                        if (savedPreviewCardName != null)
                          'avatarCardName': savedPreviewCardName,
                        if (moxfield.isNotEmpty) 'moxfieldUrl': moxfield,
                        if (savedTemplateRef != null)
                          'templateRef': savedTemplateRef,
                      });
                    } catch (_) {}
                    // setState will be called after showModalBottomSheet awaits
                    // (i.e. once the sheet is fully gone from the tree).
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).tertiary,
                    foregroundColor: FlutterFlowTheme.of(context).primary,
                    disabledBackgroundColor: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Sauvegarder',
                    style: TextStyle(
                      fontFamily: 'Cinzel Decorative',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // Navigator.pop() completes showModalBottomSheet immediately (before the
    // exit animation). Disposing controllers or calling setState right away
    // causes _AnimatedState.didUpdateWidget to addListener on disposed objects.
    // Wait for the animation to fully finish before cleaning up.
    sheetActive = false;
    iconDebounce?.cancel();
    await Future.delayed(const Duration(milliseconds: 400));
    nameController.dispose();
    controller.dispose();
    moxfieldController.dispose();
    iconController.dispose();
    if (mounted) setState(() => _refreshKey++);
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

/// Lightweight suggestion payload for the archetype bottom sheet. Wraps either
/// a live `ArchetypesRecord` (with pre-resolved avatar) or a keyword from the
/// static fallback map.
class _ArchetypeSuggestion {
  final String name;
  final String displayName;
  final String? avatarUrl;
  final String? avatarCardName;

  const _ArchetypeSuggestion({
    required this.name,
    required this.displayName,
    this.avatarUrl,
    this.avatarCardName,
  });

  factory _ArchetypeSuggestion.fromRecord(ArchetypesRecord rec) =>
      _ArchetypeSuggestion(
        name: rec.name,
        displayName: rec.name,
        avatarUrl: rec.hasAvatarUrl() && rec.avatarUrl.isNotEmpty
            ? rec.avatarUrl
            : null,
        avatarCardName:
            rec.hasAvatarCardName() && rec.avatarCardName.isNotEmpty
                ? rec.avatarCardName
                : null,
      );

  factory _ArchetypeSuggestion.fromStatic(String keyword) {
    final title = keyword
        .split(' ')
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return _ArchetypeSuggestion(name: keyword, displayName: title);
  }
}
