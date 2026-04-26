import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'organization_list_model.dart';
export 'organization_list_model.dart';

/// Lists every organization the current user is a member of, driven by the
/// denormalized `users/{uid}.organizationIds` array. Each row opens the
/// detail page (members + tournaments).
///
/// Orgs are auto-provisioned during Spicerack import; this screen is how
/// users verify their memberships and discover who else is in their LGS.
class OrganizationListWidget extends StatefulWidget {
  const OrganizationListWidget({Key? key}) : super(key: key);

  @override
  State<OrganizationListWidget> createState() => _OrganizationListWidgetState();
}

class _OrganizationListWidgetState extends State<OrganizationListWidget> {
  late OrganizationListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganizationListModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'OrganizationList'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Fetches every org doc the current user is a member of. Firestore
  /// `whereIn` caps at 30, so we chunk in case a user joined many events.
  Future<List<OrganizationsRecord>> _loadOrganizations() async {
    final ids = currentUserDocument?.organizationIds
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList() ??
        const <String>[];
    if (ids.isEmpty) return <OrganizationsRecord>[];

    final all = <OrganizationsRecord>[];
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, (i + 30).clamp(0, ids.length));
      final list = await queryOrganizationsRecordOnce(
        queryBuilder: (q) =>
            q.where(FieldPath.documentId, whereIn: chunk),
      );
      all.addAll(list);
    }
    // Stable sort: alphabetic by name.
    all.sort((a, b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return all;
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
            'Organizations',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Cinzel Decorative',
                  fontSize: 22,
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
            child: FutureBuilder<List<OrganizationsRecord>>(
              future: _loadOrganizations(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SpinKitFadingFour(
                      color: Color(0xFFE6486F),
                      size: 44,
                    ),
                  );
                }
                final orgs = snapshot.data!;
                if (orgs.isEmpty) return _buildEmpty(context);
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: orgs.length,
                  itemBuilder: (_, i) => _buildCard(context, orgs[i]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_mall_directory_outlined,
                color: FlutterFlowTheme.of(context).secondaryText, size: 80),
            SizedBox(height: 14),
            Text(
              "You aren't in any organization yet",
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Cinzel Decorative',
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 18,
                  ),
            ),
            SizedBox(height: 6),
            Text(
              'Import a tournament from Spicerack to join the store automatically.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Noto Sans',
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.6),
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, OrganizationsRecord org) {
    final accent = FlutterFlowTheme.of(context).primaryText;
    final kindBadge = _kindLabel(org.kind);

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'OrganizationDetail',
          queryParameters: {
            'organizationId':
                serializeParam(org.organizationId, ParamType.String),
            'organizationPath':
                serializeParam(org.reference.path, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kindColor(org.kind).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _kindIcon(org.kind),
                color: _kindColor(org.kind),
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.name.isNotEmpty ? org.name : 'Untitled organization',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Noto Sans',
                          color: accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (kindBadge.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kindColor(org.kind).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            kindBadge,
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              color: _kindColor(org.kind),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Text(
                        '${org.memberCount} member${org.memberCount == 1 ? '' : 's'}',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Noto Sans',
                              color: accent.withOpacity(0.55),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: accent.withOpacity(0.4), size: 20),
          ],
        ),
      ),
    );
  }

  String _kindLabel(String kind) {
    switch (kind) {
      case 'spicerack_store':
        return 'SPICERACK';
      case 'lgs':
        return 'LGS';
      case 'league':
        return 'LEAGUE';
      case 'online':
        return 'ONLINE';
      case 'other':
        return 'OTHER';
      default:
        return kind.toUpperCase();
    }
  }

  IconData _kindIcon(String kind) {
    switch (kind) {
      case 'spicerack_store':
        return Icons.storefront;
      case 'lgs':
        return Icons.store;
      case 'league':
        return Icons.military_tech;
      case 'online':
        return Icons.language;
      default:
        return Icons.groups;
    }
  }

  Color _kindColor(String kind) {
    switch (kind) {
      case 'spicerack_store':
        return Color(0xFFE6486F);
      case 'lgs':
        return Color(0xFFF39C12);
      case 'league':
        return Color(0xFF3498DB);
      case 'online':
        return Color(0xFF2ECC71);
      default:
        return Color(0xFF95A5A6);
    }
  }
}
