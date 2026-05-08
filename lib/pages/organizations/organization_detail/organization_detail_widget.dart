import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/spicerack/spicerack_import.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'organization_detail_model.dart';
export 'organization_detail_model.dart';

// ─── Data classes ─────────────────────────────────────────────────────────────

class _PlayerRankEntry {
  final String crewmateId;
  final String playerName;
  int wins = 0;
  int losses = 0;
  int draws = 0;

  _PlayerRankEntry(this.crewmateId, this.playerName);

  int get total => wins + losses + draws;
  double get ratio => total == 0 ? 0 : wins / total;
}

class _ArchetypeEntry {
  final String label;
  int count = 0; // number of matchup appearances (each matchup = 2 slots)

  _ArchetypeEntry(this.label);
}

class _H2HEntry {
  final String opponentId;
  final String opponentName;
  int wins = 0;
  int losses = 0;
  int draws = 0;

  _H2HEntry(this.opponentId, this.opponentName);

  int get total => wins + losses + draws;
  double get ratio => total == 0 ? 0 : wins / total;
}

/// Detail view for a single organization. Shows members (from the `members`
/// subcollection) and the tournaments scoped to this org (latest first).
///
/// Reached either from [OrganizationListWidget] (`organizationPath` is the
/// document path) or from deep links carrying just [organizationId]. When
/// only the id is provided we look up the doc via the `organizationId`
/// field on the collection.
class OrganizationDetailWidget extends StatefulWidget {
  const OrganizationDetailWidget({
    Key? key,
    this.organizationId,
    this.organizationPath,
  }) : super(key: key);

  final String? organizationId;
  final String? organizationPath;

  @override
  State<OrganizationDetailWidget> createState() =>
      _OrganizationDetailWidgetState();
}

class _OrganizationDetailWidgetState extends State<OrganizationDetailWidget>
    with TickerProviderStateMixin {
  late OrganizationDetailModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<_OrgBundle>? _future;
  late TabController _tabController;

  // Drill-down: when non-null, show H2H view for this player.
  _PlayerRankEntry? _selectedPlayer;

  // Bulk-expand state: when running, the AppBar shows a spinner + progress
  // counter and the button is disabled.
  bool _isExpandingAll = false;
  int _expandDone = 0;
  int _expandTotal = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganizationDetailModel());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _selectedPlayer != null) {
        setState(() => _selectedPlayer = null);
      }
    });
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'OrganizationDetail'});
    _future = _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  /// Pull every match for every spicerack-backed tournament under this org.
  /// Tournaments are processed sequentially (each `expandTournament` already
  /// parallelises within itself, so going wider risks hammering Firestore),
  /// and the AppBar shows the running count while it works.
  Future<void> _expandAllTournaments(_OrgBundle bundle) async {
    final eligible = bundle.tournaments
        .where((t) => t.spicerackEventId != 0)
        .toList();
    if (eligible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Aucun tournoi Spicerack à charger.'),
      ));
      return;
    }

    final n = eligible.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Charger toutes les parties ?'),
        content: Text(
          'Télécharge les parties de TOUS les participants '
          'pour $n tournoi${n > 1 ? 's' : ''} de cette organisation.\n\n'
          'Actuellement seules vos parties sont enregistrées. '
          'Vous pouvez naviguer pendant le chargement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isExpandingAll = true;
      _expandDone = 0;
      _expandTotal = n;
    });

    final messenger = ScaffoldMessenger.of(context);
    final importer = SpicerackImporter();
    int succeeded = 0;

    for (var i = 0; i < eligible.length; i++) {
      final t = eligible[i];
      if (mounted) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text('⬇ Tournoi ${i + 1}/$n : ${t.name}'),
            duration: const Duration(seconds: 60),
          ));
      }
      try {
        await importer.expandTournament(spicerackEventId: t.spicerackEventId);
        succeeded++;
      } catch (e) {
        debugPrint('[OrgDetail] expand failed for ${t.tournamentId}: $e');
      }
      if (mounted) setState(() => _expandDone = i + 1);
    }

    if (!mounted) return;
    setState(() {
      _isExpandingAll = false;
      _future = _load();
    });
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('✓ $succeeded/$n tournois chargés avec succès.'),
        duration: const Duration(seconds: 4),
      ));
  }

  Future<_OrgBundle> _load() async {
    // Resolve the organization reference.
    DocumentReference? orgRef;
    if (widget.organizationPath != null &&
        widget.organizationPath!.isNotEmpty) {
      orgRef = FirebaseFirestore.instance.doc(widget.organizationPath!);
    } else if (widget.organizationId != null &&
        widget.organizationId!.isNotEmpty) {
      // Fallback: fetch by the organizationId field.
      final snap = await queryOrganizationsRecordOnce(
        queryBuilder: (q) =>
            q.where('organizationId', isEqualTo: widget.organizationId),
        singleRecord: true,
      );
      if (snap.isNotEmpty) orgRef = snap.first.reference;
    }

    if (orgRef == null) {
      throw StateError('No organization ref available');
    }

    final org = await OrganizationsRecord.getDocumentOnce(orgRef);

    // Members (subcollection) — no server-side orderBy to avoid composite index.
    final membersRaw = await queryOrganizationMembersRecordOnce(
      parent: orgRef,
    );
    // Sort client-side by joinedAt (null-safe).
    final members = [...membersRaw]
      ..sort((a, b) {
        final ta = a.joinedAt;
        final tb = b.joinedAt;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return ta.compareTo(tb);
      });

    // Tournaments scoped to this org — single where only, sort client-side.
    final tournamentsRaw = await queryTournamentsRecordOnce(
      queryBuilder: (q) =>
          q.where('organizationId', isEqualTo: org.organizationId),
    );
    final tournaments = [...tournamentsRaw]
      ..sort((a, b) {
        final ta = a.date;
        final tb = b.date;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta); // most recent first
      });

    // ── Player ranking + archetypes ───────────────────────────────────────────
    // All new sections are fault-tolerant so a Firestore issue doesn't break
    // the whole page.
    List<MatchupsRecord> matchups = [];
    Map<String, DecksRecord> deckMap = {};
    Map<String, String> crewmateNameMap = {};
    List<_PlayerRankEntry> ranking = [];
    List<_ArchetypeEntry> archetypes = [];

    try {
      // Load matchups via tournament IDs (more reliable than organizationId field).
      final tournamentIds = tournaments
          .map((t) => t.tournamentId)
          .where((id) => id.isNotEmpty)
          .toList();
      for (var i = 0; i < tournamentIds.length; i += 30) {
        final end = (i + 30) < tournamentIds.length ? i + 30 : tournamentIds.length;
        final chunk = tournamentIds.sublist(i, end);
        final fetched = await queryMatchupsRecordOnce(
          queryBuilder: (q) => q.where('tournamentId', whereIn: chunk),
        );
        matchups.addAll(fetched);
      }
      debugPrint('[OrgDetail] loaded ${matchups.length} matchups from ${tournamentIds.length} tournaments');
    } catch (e) {
      debugPrint('[OrgDetail] matchups query failed: $e');
    }

    try {
      // Collect all unique deckIds referenced by matchup scores.
      final allDeckIds = <String>{};
      for (final m in matchups) {
        for (final s in m.scores) {
          if (s.deckId.isNotEmpty) allDeckIds.add(s.deckId);
        }
      }

      // Batch-query those decks in chunks of 30 (Firestore whereIn limit).
      final deckList = allDeckIds.toList();
      for (var i = 0; i < deckList.length; i += 30) {
        final chunk = deckList.sublist(
            i, i + 30 > deckList.length ? deckList.length : i + 30);
        final fetched = await queryDecksRecordOnce(
          queryBuilder: (q) => q.where('deckId', whereIn: chunk),
        );
        for (final d in fetched) {
          if (d.deckId.isNotEmpty) deckMap[d.deckId] = d;
        }
      }
      debugPrint('[OrgDetail] loaded ${deckMap.length} decks');
    } catch (e) {
      debugPrint('[OrgDetail] deck query failed: $e');
    }

    try {
      // Resolve crewmate names from their refs (deduplicated).
      // We store the name under BOTH the Firestore doc ID and the userId so
      // the look-up succeeds regardless of which value deck.crewmateId carries.
      final crewmateRefs = deckMap.values
          .where((d) => d.hasCrewmateRef())
          .map((d) => d.crewmateRef!)
          .toSet();
      if (crewmateRefs.isNotEmpty) {
        final docs = await Future.wait(crewmateRefs.map((r) => r.get()));
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>?;
          final name = data?['name'] as String?;
          if (name == null || name.trim().isEmpty) continue;
          // Key by Firestore document ID.
          crewmateNameMap[doc.id] = name.trim();
          // Also key by userId (Firebase Auth UID) in case crewmateId on
          // the deck stores the UID rather than the Firestore document ID.
          final uid = data?['userId'] as String?;
          if (uid != null && uid.isNotEmpty) {
            crewmateNameMap[uid] = name.trim();
          }
        }
      }
      debugPrint('[OrgDetail] resolved ${crewmateNameMap.length} names');
    } catch (e) {
      debugPrint('[OrgDetail] crewmate name resolution failed: $e');
    }

    try {
      // Aggregate W/L/D per crewmate across all matchups.
      //
      // KEY FIX: we register every identified player and tally their results
      // for ALL matchups — even when the opponent is unnamed. Previously the
      // code skipped any matchup where either side lacked a resolved name,
      // which meant a named player's record only reflected games against other
      // named players (effectively only games against the current user).
      final rankMap = <String, _PlayerRankEntry>{};
      for (final m in matchups) {
        if (m.scores.length < 2) continue;
        final s1 = m.scores.first;
        final s2 = m.scores.last;
        final d1 = deckMap[s1.deckId];
        final d2 = deckMap[s2.deckId];

        final id1 = d1?.crewmateId ?? '';
        final id2 = d2?.crewmateId ?? '';

        // Need at least both sides identified to tally a result.
        if (id1.isEmpty || id2.isEmpty) continue;

        final name1 = crewmateNameMap[id1] ?? '';
        final name2 = crewmateNameMap[id2] ?? '';

        // Register both players (even if unnamed — their tallies still count
        // toward named opponents' records).
        rankMap.putIfAbsent(id1, () => _PlayerRankEntry(id1, name1));
        rankMap.putIfAbsent(id2, () => _PlayerRankEntry(id2, name2));

        final cmp = s1.score.compareTo(s2.score);
        if (cmp > 0) {
          rankMap[id1]!.wins++;
          rankMap[id2]!.losses++;
        } else if (cmp < 0) {
          rankMap[id1]!.losses++;
          rankMap[id2]!.wins++;
        } else {
          rankMap[id1]!.draws++;
          rankMap[id2]!.draws++;
        }
      }

      // Only surface players whose name was resolved — unnamed entries
      // (crewmateId with no matching crewmate doc) are silently dropped from
      // the display but their games still counted for named opponents above.
      ranking = rankMap.values
          .where((e) => e.playerName.isNotEmpty)
          .toList()
        ..sort((a, b) {
          final cmp = b.ratio.compareTo(a.ratio);
          return cmp != 0 ? cmp : b.total.compareTo(a.total);
        });
    } catch (e) {
      debugPrint('[OrgDetail] ranking aggregation failed: $e');
    }

    try {
      // Count archetype appearances.
      String deckLabel(DecksRecord? d) {
        if (d == null) return 'Unknown';
        if (d.avatarName.isNotEmpty) return d.avatarName;
        if (d.name.isNotEmpty) return d.name;
        return 'Unknown';
      }
      final archMap = <String, _ArchetypeEntry>{};
      for (final m in matchups) {
        for (final s in m.scores) {
          final label = deckLabel(deckMap[s.deckId]);
          if (label == 'Unknown') continue;
          archMap.putIfAbsent(label, () => _ArchetypeEntry(label)).count++;
        }
      }
      archetypes = archMap.values.toList()
        ..sort((a, b) => b.count.compareTo(a.count));
    } catch (e) {
      debugPrint('[OrgDetail] archetype aggregation failed: $e');
    }

    return _OrgBundle(
      org: org,
      members: members,
      tournaments: tournaments,
      ranking: ranking,
      archetypes: archetypes,
      matchups: matchups,
      deckMap: deckMap,
      crewmateNameMap: crewmateNameMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inDrillDown = _selectedPlayer != null;
    return AuthUserStreamWidget(
      builder: (context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          leading: inDrillDown
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => setState(() => _selectedPlayer = null),
                )
              : null,
          title: Text(
            inDrillDown ? _selectedPlayer!.playerName : 'Organisation',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Cinzel Decorative',
                  fontSize: 18,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
          actions: [
            // Hidden in drill-down (player H2H view) — only shown on the main
            // org tabs.
            if (!inDrillDown) ...[
              if (_isExpandingAll)
                // Live counter: spinner + "X/Y" text
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_expandDone/$_expandTotal',
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                FutureBuilder<_OrgBundle>(
                  future: _future,
                  builder: (context, snap) {
                    final bundle = snap.data;
                    if (bundle == null) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: 'Charger toutes les parties de chaque tournoi',
                      icon: Icon(
                        Icons.cloud_download_outlined,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 22,
                      ),
                      onPressed: () => _expandAllTournaments(bundle),
                    );
                  },
                ),
            ],
          ],
          // Hide the tab bar when drilling into player H2H.
          bottom: inDrillDown
              ? null
              : TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFE6486F),
                  indicatorWeight: 2,
                  labelColor: FlutterFlowTheme.of(context).primaryText,
                  unselectedLabelColor: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.45),
                  labelStyle: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                  tabs: const [
                    Tab(text: 'MEMBRES'),
                    Tab(text: 'TOURNOIS'),
                    Tab(text: 'STATS'),
                  ],
                ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF323236), Color(0xFFE6486F)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0, -1),
              end: AlignmentDirectional(0, 1),
            ),
          ),
          child: FutureBuilder<_OrgBundle>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(
                  child: SpinKitFadingFour(
                    color: Color(0xFFE6486F),
                    size: 44,
                  ),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load this organization.\n\n${snap.error}',
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            fontFamily: 'Noto Sans',
                            color: FlutterFlowTheme.of(context)
                                .primaryText
                                .withOpacity(0.8),
                          ),
                    ),
                  ),
                );
              }
              return _buildBody(context, snap.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, _OrgBundle bundle) {
    if (_selectedPlayer != null) {
      return _buildH2HBody(context, bundle, _selectedPlayer!);
    }

    return Column(
      children: [
        _headerCard(context, bundle),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMembresTab(context, bundle),
              _buildTournoisTab(context, bundle),
              _buildStatsTab(context, bundle),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header card (shown above all tabs) ────────────────────────────────────

  Widget _headerCard(BuildContext context, _OrgBundle bundle) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final org = bundle.org;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE6486F).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront,
                  color: Color(0xFFE6486F), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.name.isNotEmpty ? org.name : 'Organisation',
                    style: FlutterFlowTheme.of(context)
                        .titleMedium
                        .override(
                          fontFamily: 'Cinzel Decorative',
                          color: accent,
                          fontSize: 16,
                        ),
                  ),
                  if (org.kind.isNotEmpty)
                    Text(
                      org.kind.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        color: accent.withOpacity(0.55),
                        fontSize: 9,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    '${bundle.members.length} membre${bundle.members.length == 1 ? '' : 's'}  ·  '
                    '${bundle.tournaments.length} tournoi${bundle.tournaments.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      color: accent.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1 — Membres ───────────────────────────────────────────────────────

  Widget _buildMembresTab(BuildContext context, _OrgBundle bundle) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (bundle.members.isEmpty)
          _emptyLine(context, 'Aucun membre.'),
        for (final m in bundle.members) _memberRow(context, m),
      ],
    );
  }

  // ── Tab 2 — Tournois ──────────────────────────────────────────────────────

  Widget _buildTournoisTab(BuildContext context, _OrgBundle bundle) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (bundle.tournaments.isEmpty)
          _emptyLine(context, 'Aucun tournoi importé.'),
        for (final t in bundle.tournaments) _tournamentRow(context, t),
      ],
    );
  }

  // ── Tab 3 — Stats ─────────────────────────────────────────────────────────

  Widget _buildStatsTab(BuildContext context, _OrgBundle bundle) {
    final total = bundle.archetypes.fold<int>(0, (s, e) => s + e.count);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _sectionTitle(context, 'CLASSEMENT'),
        const SizedBox(height: 8),
        if (bundle.ranking.isEmpty)
          _emptyLine(context, 'Pas encore de données.'),
        for (var i = 0; i < bundle.ranking.length; i++)
          _rankingRow(context, i + 1, bundle.ranking[i], bundle),
        const SizedBox(height: 20),
        _sectionTitle(context, 'ARCHÉTYPES'),
        const SizedBox(height: 8),
        if (bundle.archetypes.isEmpty)
          _emptyLine(context, 'Pas encore de données.'),
        for (final a in bundle.archetypes) _archetypeRow(context, a, total),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Noto Sans',
          color:
              FlutterFlowTheme.of(context).primaryText.withOpacity(0.55),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _emptyLine(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Noto Sans',
          color:
              FlutterFlowTheme.of(context).primaryText.withOpacity(0.55),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _memberRow(BuildContext context, OrganizationMembersRecord m) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 16, color: accent.withOpacity(0.7)),
          ),
          const SizedBox(width: 10),
          Expanded(child: _MemberName(member: m)),
        ],
      ),
    );
  }

  Widget _tournamentRow(BuildContext context, TournamentsRecord t) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final dateStr = t.date != null
        ? DateFormat('MMM d, yyyy').format(t.date!)
        : '';
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'TournamentDetail',
          queryParameters: {
            'tournamentId': serializeParam(t.tournamentId, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 16, color: accent.withOpacity(0.6)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                t.name.isNotEmpty ? t.name : 'Untitled tournament',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: accent.withOpacity(0.85),
                  fontSize: 12,
                ),
              ),
            ),
            if (dateStr.isNotEmpty) ...[
              SizedBox(width: 8),
              Text(
                dateStr,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: accent.withOpacity(0.45),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _rankingRow(BuildContext context, int position, _PlayerRankEntry entry,
      _OrgBundle bundle) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final pct = entry.total == 0
        ? '—'
        : '${(entry.ratio * 100).toStringAsFixed(0)}%';

    // Medal colour for top 3.
    Color? posColor;
    if (position == 1) posColor = const Color(0xFFFFD700);
    if (position == 2) posColor = const Color(0xFFC0C0C0);
    if (position == 3) posColor = const Color(0xFFCD7F32);

    return GestureDetector(
      onTap: () => setState(() => _selectedPlayer = entry),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
        children: [
          // Position badge.
          SizedBox(
            width: 28,
            child: Text(
              '$position',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: posColor ?? accent.withOpacity(0.45),
                fontSize: posColor != null ? 14 : 12,
                fontWeight: posColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Player name.
          Expanded(
            child: Text(
              entry.playerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: accent.withOpacity(0.88),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // W-L-D record.
          Text(
            '${entry.wins}W-${entry.losses}L-${entry.draws}D',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              color: accent.withOpacity(0.55),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          // Win %.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE6486F).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pct,
              style: const TextStyle(
                fontFamily: 'Noto Sans',
                color: Color(0xFFE6486F),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Tap indicator.
          const SizedBox(width: 4),
          Icon(Icons.chevron_right,
              size: 14, color: accent.withOpacity(0.3)),
        ],
      ),
    ),   // Container
    );   // GestureDetector
  }

  Widget _archetypeRow(
      BuildContext context, _ArchetypeEntry entry, int total) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final pct = total == 0
        ? '—'
        : '${(entry.count / total * 100).toStringAsFixed(0)}%';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: accent.withOpacity(0.88),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.count} game${entry.count == 1 ? '' : 's'}',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              color: accent.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE6486F).withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pct,
              style: const TextStyle(
                fontFamily: 'Noto Sans',
                color: Color(0xFFE6486F),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── H2H drill-down ─────────────────────────────────────────────────────────

  List<_H2HEntry> _computeH2H(_OrgBundle bundle, _PlayerRankEntry player) {
    final map = <String, _H2HEntry>{};
    for (final m in bundle.matchups) {
      if (m.scores.length < 2) continue;
      final s1 = m.scores.first;
      final s2 = m.scores.last;
      final d1 = bundle.deckMap[s1.deckId];
      final d2 = bundle.deckMap[s2.deckId];
      final id1 = d1?.crewmateId ?? '';
      final id2 = d2?.crewmateId ?? '';

      final bool isP1 = id1 == player.crewmateId;
      final bool isP2 = id2 == player.crewmateId;
      if (!isP1 && !isP2) continue;

      final myScore = isP1 ? s1 : s2;
      final oppScore = isP1 ? s2 : s1;
      final oppId = isP1 ? id2 : id1;
      final oppName = bundle.crewmateNameMap[oppId] ?? '';
      if (oppName.isEmpty) continue;

      final key = oppId.isNotEmpty ? oppId : oppName;
      final h2h =
          map.putIfAbsent(key, () => _H2HEntry(oppId, oppName));

      final cmp = myScore.score.compareTo(oppScore.score);
      if (cmp > 0) h2h.wins++;
      else if (cmp < 0) h2h.losses++;
      else h2h.draws++;
    }
    return map.values.toList()
      ..sort((a, b) {
        final cmp = b.ratio.compareTo(a.ratio);
        return cmp != 0 ? cmp : b.total.compareTo(a.total);
      });
  }

  Widget _buildH2HBody(
      BuildContext context, _OrgBundle bundle, _PlayerRankEntry player) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final h2h = _computeH2H(bundle, player);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Player summary card.
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFE6486F).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6486F).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    player.playerName.isNotEmpty
                        ? player.playerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      color: Color(0xFFE6486F),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.playerName,
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${player.wins}V - ${player.losses}D - ${player.draws}N  ·  '
                      '${player.total == 0 ? '—' : '${(player.ratio * 100).toStringAsFixed(0)}%'}',
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        color: accent.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _sectionTitle(context, 'RÉSULTATS FACE À FACE'),
        const SizedBox(height: 8),
        if (h2h.isEmpty) _emptyLine(context, 'Aucun face-à-face trouvé.'),
        for (final entry in h2h) _h2hRow(context, entry),
      ],
    );
  }

  Widget _h2hRow(BuildContext context, _H2HEntry entry) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final pct = entry.total == 0
        ? '—'
        : '${(entry.ratio * 100).toStringAsFixed(0)}%';
    final resultColor = entry.wins > entry.losses
        ? const Color(0xFF2ECC71)
        : entry.losses > entry.wins
            ? const Color(0xFFE74C3C)
            : accent.withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.opponentName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: accent.withOpacity(0.88),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.wins}V-${entry.losses}D-${entry.draws}N',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              color: accent.withOpacity(0.55),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pct,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                color: resultColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolved fixture for the detail page. Grouping these together lets us use
/// a single [FutureBuilder] rather than nesting three.
class _OrgBundle {
  _OrgBundle({
    required this.org,
    required this.members,
    required this.tournaments,
    required this.ranking,
    required this.archetypes,
    required this.matchups,
    required this.deckMap,
    required this.crewmateNameMap,
  });
  final OrganizationsRecord org;
  final List<OrganizationMembersRecord> members;
  final List<TournamentsRecord> tournaments;
  final List<_PlayerRankEntry> ranking;
  final List<_ArchetypeEntry> archetypes;
  // Kept for lazy H2H computation.
  final List<MatchupsRecord> matchups;
  final Map<String, DecksRecord> deckMap;
  final Map<String, String> crewmateNameMap; // crewmateId → name
}

/// Resolves the `userRef` on a member into a display name. Kept as a
/// separate widget so the parent list doesn't stall on network fetches.
class _MemberName extends StatelessWidget {
  const _MemberName({Key? key, required this.member}) : super(key: key);
  final OrganizationMembersRecord member;

  @override
  Widget build(BuildContext context) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final userRef = member.userRef;
    if (userRef == null) {
      return Text(
        '—',
        style: TextStyle(
          fontFamily: 'Noto Sans',
          color: accent.withOpacity(0.75),
          fontSize: 13,
        ),
      );
    }
    return FutureBuilder<UsersRecord>(
      future: UsersRecord.getDocumentOnce(userRef),
      builder: (ctx, snap) {
        String label = '—';
        if (snap.hasData) {
          final u = snap.data!;
          if (u.displayName.isNotEmpty) {
            label = u.displayName;
          } else if (u.email.isNotEmpty) {
            label = u.email;
          }
        }
        return Text(
          label,
          style: TextStyle(
            fontFamily: 'Noto Sans',
            color: accent.withOpacity(0.85),
            fontSize: 13,
          ),
        );
      },
    );
  }
}
