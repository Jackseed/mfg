import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'organization_detail_model.dart';
export 'organization_detail_model.dart';

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

class _OrganizationDetailWidgetState extends State<OrganizationDetailWidget> {
  late OrganizationDetailModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<_OrgBundle>? _future;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganizationDetailModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'OrganizationDetail'});
    _future = _load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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

    // Members (subcollection). We use the generated query helper scoped to
    // this parent ref.
    final members = await queryOrganizationMembersRecordOnce(
      parent: orgRef,
      queryBuilder: (q) => q.orderBy('joinedAt'),
    );

    // Tournaments scoped to this org. Fall back to a single query on
    // organizationId.
    final tournaments = await queryTournamentsRecordOnce(
      queryBuilder: (q) => q
          .where('organizationId', isEqualTo: org.organizationId)
          .orderBy('date', descending: true),
    );

    return _OrgBundle(org: org, members: members, tournaments: tournaments);
  }

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          title: Text(
            'Organization',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Cinzel Decorative',
                  fontSize: 20,
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
                begin: AlignmentDirectional(0, -1),
                end: AlignmentDirectional(0, 1),
              ),
            ),
            child: FutureBuilder<_OrgBundle>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(
                    child: SpinKitFadingFour(
                      color: Color(0xFFE6486F),
                      size: 44,
                    ),
                  );
                }
                if (snap.hasError || !snap.hasData) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Could not load this organization.',
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
      ),
    );
  }

  Widget _buildBody(BuildContext context, _OrgBundle bundle) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final org = bundle.org;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Header card.
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFFE6486F).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.storefront,
                    color: Color(0xFFE6486F), size: 26),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name.isNotEmpty ? org.name : 'Untitled organization',
                      style: FlutterFlowTheme.of(context)
                          .titleMedium
                          .override(
                            fontFamily: 'Cinzel Decorative',
                            color: accent,
                            fontSize: 18,
                          ),
                    ),
                    if (org.kind.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          org.kind.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            color: accent.withOpacity(0.6),
                            fontSize: 10,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '${bundle.members.length} member${bundle.members.length == 1 ? '' : 's'}  ·  '
                        '${bundle.tournaments.length} tournament${bundle.tournaments.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          color: accent.withOpacity(0.65),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _sectionTitle(context, 'MEMBERS'),
        SizedBox(height: 8),
        if (bundle.members.isEmpty)
          _emptyLine(context, 'No members yet.'),
        for (final m in bundle.members) _memberRow(context, m),
        SizedBox(height: 20),
        _sectionTitle(context, 'TOURNAMENTS'),
        SizedBox(height: 8),
        if (bundle.tournaments.isEmpty)
          _emptyLine(context, 'No tournaments imported yet.'),
        for (final t in bundle.tournaments) _tournamentRow(context, t),
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
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person,
                size: 16, color: accent.withOpacity(0.7)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _MemberName(member: m),
          ),
          if (m.role == 'admin')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFF1C40F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: Color(0xFFF1C40F),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
}

/// Resolved fixture for the detail page. Grouping these together lets us use
/// a single [FutureBuilder] rather than nesting three.
class _OrgBundle {
  _OrgBundle({
    required this.org,
    required this.members,
    required this.tournaments,
  });
  final OrganizationsRecord org;
  final List<OrganizationMembersRecord> members;
  final List<TournamentsRecord> tournaments;
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
        member.uid.isNotEmpty ? member.uid : '—',
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
        String label = member.uid.isNotEmpty ? member.uid : '—';
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
