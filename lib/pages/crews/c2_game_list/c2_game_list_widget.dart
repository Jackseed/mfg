import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_icons.dart';
import '/page_component/archetype_editor/archetype_editor_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'c2_game_list_model.dart';
export 'c2_game_list_model.dart';

class C2GameListWidget extends StatefulWidget {
  const C2GameListWidget({
    Key? key,
    required this.filteredDeckList,
    required this.deckId,
  }) : super(key: key);

  final List<String>? filteredDeckList;
  final String? deckId;

  @override
  _C2GameListWidgetState createState() => _C2GameListWidgetState();
}

class _C2GameListWidgetState extends State<C2GameListWidget> {
  late C2GameListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => C2GameListModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'C2_GameList'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('C2_GAME_LIST_C2_GameList_ON_INIT_STATE');
      // Get deck
      logFirebaseEvent('C2_GameList_Getdeck');
      _model.deck = await queryDecksRecordOnce(
        queryBuilder: (decksRecord) => decksRecord.where(
          'deckId',
          isEqualTo: widget.deckId,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      // Get crewmate owner
      logFirebaseEvent('C2_GameList_Getcrewmateowner');
      _model.crewmateOwner =
          await CrewmatesRecord.getDocumentOnce(_model.deck!.crewmateRef!);
      // Set filter as closed
      logFirebaseEvent('C2_GameList_Setfilterasclosed');
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Tournament name cache (tournamentId → name, null while loading)
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

  static String _formatGameDate(DateTime d, String locale) {
    if (locale == 'fr') {
      const m = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    }
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  static const _colorIcons = {
    'W': FFIcons.kwhite,
    'U': FFIcons.kblue,
    'B': FFIcons.kblack,
    'R': FFIcons.kred,
    'G': FFIcons.kgreen,
  };

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
      builder: (context) => FutureBuilder<List<DecksRecord>>(
        future: queryDecksRecordOnce(
          queryBuilder: (decksRecord) => decksRecord
              .where(
                'crewId',
                isEqualTo: valueOrDefault(currentUserDocument?.crewId, '') != ''
                    ? valueOrDefault(currentUserDocument?.crewId, '')
                    : null,
              )
              .orderBy('name'),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              body: Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SpinKitFadingFour(color: Color(0xFFE6486F), size: 50.0),
                ),
              ),
            );
          }
          final allCrewDecks = snapshot.data!;
          // Build deck lookup map: deckId UUID → DecksRecord and ref.id → DecksRecord
          final deckById = <String, DecksRecord>{};
          for (final d in allCrewDecks) {
            if (d.deckId.isNotEmpty) deckById[d.deckId] = d;
            deckById[d.reference.id] = d;
          }

          return GestureDetector(
            onTap: () => _model.unfocusNode.canRequestFocus
                ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                : FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  logFirebaseEvent('C2_GAME_LIST_FloatingActionButton_0o5bg5');
                  context.pushNamed(
                    'B2_AddMatchup',
                    queryParameters: {
                      'playerName1': serializeParam(
                        _model.crewmateOwner?.name,
                        ParamType.String,
                      ),
                      'deckName1': serializeParam(
                        _model.deck?.name,
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                },
                backgroundColor: FlutterFlowTheme.of(context).primary,
                icon: Icon(Icons.add),
                elevation: 8.0,
                label: Text(
                  FFLocalizations.of(context).getText('14kzysds'),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: true,
                title: Text(
                  valueOrDefault<String>(_model.deck?.name, 'Matchs'),
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Cinzel Decorative',
                        fontSize: 24.0,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                centerTitle: true,
                elevation: 4.0,
              ),
              body: SafeArea(
                top: true,
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0, -1),
                      child: _buildGameStatsStrip(context, allCrewDecks),
                    ),
                    StreamBuilder<List<GamesRecord>>(
                      stream: queryGamesRecord(
                        queryBuilder: (q) => q
                            .where(
                              'crewId',
                              isEqualTo:
                                  valueOrDefault(currentUserDocument?.crewId, '') != ''
                                      ? valueOrDefault(currentUserDocument?.crewId, '')
                                      : null,
                            )
                            .where(
                              'deckIds',
                              arrayContains: widget.deckId != '' ? widget.deckId : null,
                            )
                            .orderBy('date', descending: true),
                      ),
                      builder: (context, gamesSnap) {
                        if (!gamesSnap.hasData) {
                          return Center(
                            child: SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: SpinKitFadingFour(
                                color: FlutterFlowTheme.of(context).primary,
                                size: 40.0,
                              ),
                            ),
                          );
                        }
                        final games = gamesSnap.data!;
                        if (games.isEmpty) {
                          return _buildEmptyGames(context);
                        }

                        // Group by "YYYY-MM-DD|tournamentId"
                        final locale = FFLocalizations.of(context).languageCode;
                        final grouped = <String, List<GamesRecord>>{};
                        for (final g in games) {
                          if (g.date == null) continue;
                          final dateKey =
                              '${g.date!.year}-${g.date!.month.toString().padLeft(2, '0')}-${g.date!.day.toString().padLeft(2, '0')}';
                          final tournId = g.tournamentId;
                          final key = '$dateKey|$tournId';
                          grouped.putIfAbsent(key, () => []).add(g);
                          if (tournId.isNotEmpty) {
                            _loadTournamentName(tournId, g.tournamentRef);
                          }
                        }
                        final groupKeys = grouped.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        // Build flat item list with section headers
                        final items = <Widget>[];
                        for (final key in groupKeys) {
                          final parts = key.split('|');
                          final dateStr = parts[0];
                          final tournId =
                              parts.length > 1 ? parts[1] : '';
                          final dp = dateStr.split('-');
                          final d = DateTime(int.parse(dp[0]),
                              int.parse(dp[1]), int.parse(dp[2]));
                          String headerLabel = _formatGameDate(d, locale);
                          final tournName = tournId.isNotEmpty
                              ? _tournamentNames[tournId]
                              : null;
                          if (tournName != null && tournName.isNotEmpty) {
                            headerLabel = '$headerLabel · $tournName';
                          }
                          items.add(Padding(
                            padding:
                                const EdgeInsets.fromLTRB(4, 16, 0, 8),
                            child: Text(
                              headerLabel,
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    fontFamily: 'Cinzel Decorative',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 13,
                                  ),
                            ),
                          ));
                          for (final g in grouped[key]!) {
                            items.add(
                                _buildGameCard(context, g, deckById));
                          }
                        }

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
                          child: ListView(
                            padding:
                                const EdgeInsets.fromLTRB(16, 68, 16, 110),
                            children: items,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyGames(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_outlined,
                color: FlutterFlowTheme.of(context).secondaryText, size: 60),
            const SizedBox(height: 16),
            Text(
              'Aucune partie enregistrée',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Cinzel Decorative',
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 18,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    GamesRecord game,
    Map<String, DecksRecord> deckById,
  ) {
    return FutureBuilder<List<PlayersRecord>>(
      future: queryPlayersRecordOnce(
        parent: game.reference,
        queryBuilder: (q) => q.orderBy('score', descending: true),
      ),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            height: 70,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE6486F),
                ),
              ),
            ),
          );
        }
        final players = snap.data!;
        if (players.length < 2) return const SizedBox.shrink();

        // Identify my player vs opponent by matching deckRef to focused deck
        final myRefId = _model.deck?.reference.id;
        PlayersRecord myPlayer = players.first;
        PlayersRecord oppPlayer = players.last;
        for (final p in players) {
          if (p.deckRef?.id == myRefId) {
            myPlayer = p;
          } else {
            oppPlayer = p;
          }
        }

        final myScore = myPlayer.score;
        final oppScore = oppPlayer.score;
        final resultColor = myScore > oppScore
            ? const Color(0xFF2ECC71)
            : myScore < oppScore
                ? const Color(0xFFE74C3C)
                : const Color(0xFFF1C40F);
        final resultText = myScore > oppScore
            ? 'WIN'
            : myScore < oppScore
                ? 'LOSS'
                : 'DRAW';

        // Resolve deck records for display
        final myDeck = _model.deck;
        final oppDeckId = game.deckIds
            .where((id) => id != widget.deckId)
            .firstOrNull;
        final oppDeck = oppDeckId != null ? deckById[oppDeckId] : null;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGamePlayerSide(context, myDeck, myScore,
                        isLeft: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  Expanded(
                    child: _buildGamePlayerSide(context, oppDeck, oppScore,
                        isLeft: false),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGamePlayerSide(
    BuildContext context,
    DecksRecord? deck,
    int score, {
    required bool isLeft,
  }) {
    final label = deck?.avatarName.isNotEmpty == true
        ? deck!.avatarName
        : deck?.name.isNotEmpty == true
            ? deck!.name
            : 'Unknown';
    final colors = deck?.colors ?? [];

    Widget avatarWidget;
    if (deck != null && deck.avatarUrl.isNotEmpty) {
      avatarWidget = Container(
        width: 36,
        height: 36,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: CachedNetworkImage(
          imageUrl: deck.avatarUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _buildInitialsAvatar(context, label),
        ),
      );
    } else if (colors.isNotEmpty) {
      avatarWidget = Container(
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
              return icon != null
                  ? Icon(icon,
                      size: 10,
                      color: FlutterFlowTheme.of(context).primaryText)
                  : const SizedBox.shrink();
            }).toList(),
          ),
        ),
      );
    } else {
      avatarWidget = _buildInitialsAvatar(context, label);
    }

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
        onTap: () => showArchetypeEditor(context, deck,
            onSaved: () => setState(() {})),
        child: avatarWidget,
      );
    }
    final avatar = avatarWidget;

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

    final scoreWidget = Text(
      '$score',
      style: FlutterFlowTheme.of(context).headlineSmall.override(
            fontFamily: 'Cinzel Decorative',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 24,
          ),
    );

    if (isLeft) {
      return Row(children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(child: nameWidget),
        const SizedBox(width: 4),
        scoreWidget,
      ]);
    } else {
      return Row(children: [
        scoreWidget,
        const SizedBox(width: 4),
        Expanded(child: nameWidget),
        const SizedBox(width: 8),
        avatar,
      ]);
    }
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

  /// Compact stats bar rendered at the top of the game list. Queries the same
  /// games stream the list uses (hits Firestore cache) and rolls up:
  ///   • total games played / wins / losses / draws / win rate
  ///   • top 3 opponent archetypes faced (by the deck in focus)
  Widget _buildGameStatsStrip(
    BuildContext context,
    List<DecksRecord> allCrewDecks,
  ) {
    return StreamBuilder<List<GamesRecord>>(
      stream: queryGamesRecord(
        queryBuilder: (gamesRecord) => gamesRecord
            .where(
              'crewId',
              isEqualTo:
                  valueOrDefault(currentUserDocument?.crewId, '') != ''
                      ? valueOrDefault(currentUserDocument?.crewId, '')
                      : null,
            )
            .where(
              'deckIds',
              arrayContains: widget.deckId != '' ? widget.deckId : null,
            ),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox(height: 58);
        final games = snapshot.data!;

        // Tally opponent archetypes faced by the deck in focus. We can't roll
        // up wins/losses here without another subcollection query (scores live
        // on `games/{id}/players/*`) — those are already displayed per-row in
        // the list below, so we stick to cheap aggregates derivable from the
        // games list itself: total games + most-faced opponents.
        final opponentTally = <String, int>{};
        final opponentAvatars = <String, String>{};

        final deckById = <String, DecksRecord>{};
        for (final d in allCrewDecks) {
          if (d.deckId.isNotEmpty) deckById[d.deckId] = d;
        }

        for (final g in games) {
          // Opponent deckId = the entry in deckIds that isn't the focused deck.
          final opponentDeckId = g.deckIds
              .where((id) => id != widget.deckId)
              .firstOrNull;
          if (opponentDeckId == null || opponentDeckId.isEmpty) continue;
          final oppDeck = deckById[opponentDeckId];
          if (oppDeck == null) continue;
          final label = oppDeck.avatarName.trim().isNotEmpty
              ? oppDeck.avatarName.trim()
              : oppDeck.name.trim();
          if (label.isEmpty) continue;
          final key = label.toLowerCase();
          opponentTally[key] = (opponentTally[key] ?? 0) + 1;
          if (!opponentAvatars.containsKey(key) &&
              oppDeck.hasAvatarUrl() &&
              oppDeck.avatarUrl.isNotEmpty) {
            opponentAvatars[key] = oppDeck.avatarUrl;
          }
        }

        final total = games.length;
        if (total == 0) return SizedBox(height: 58);

        final topOpponents = opponentTally.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topSlice = topOpponents.take(3).toList();

        final accent = FlutterFlowTheme.of(context).primaryText;

        return Container(
          margin: EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: total games played with this deck.
              Row(
                children: [
                  _miniStat(context, '$total', 'games'),
                  if (opponentTally.isNotEmpty) ...[
                    SizedBox(width: 10),
                    _miniStat(
                      context,
                      '${opponentTally.length}',
                      'opponents',
                    ),
                  ],
                ],
              ),
              // Right: top 3 opponent archetypes (avatars only, tooltip = name).
              if (topSlice.isNotEmpty)
                Row(
                  children: [
                    for (final entry in topSlice)
                      Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Tooltip(
                          message:
                              '${_prettify(entry.key)} \u00d7 ${entry.value}',
                          child: _avatarChip(
                            opponentAvatars[entry.key],
                            entry.value.toString(),
                            accent: accent,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  String _prettify(String lowerKey) {
    if (lowerKey.isEmpty) return lowerKey;
    return lowerKey[0].toUpperCase() + lowerKey.substring(1);
  }

  Widget _miniStat(BuildContext context, String value, String label,
      {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cinzel Decorative',
            color: color ?? FlutterFlowTheme.of(context).primaryText,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Noto Sans',
            color: FlutterFlowTheme.of(context)
                .primaryText
                .withOpacity(0.55),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _avatarChip(String? url, String badge, {required Color accent}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withOpacity(0.25), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: url != null && url.isNotEmpty
              ? Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                        Icons.style,
                        size: 14,
                        color: accent.withOpacity(0.5),
                      ))
              : Icon(Icons.style, size: 14, color: accent.withOpacity(0.5)),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
