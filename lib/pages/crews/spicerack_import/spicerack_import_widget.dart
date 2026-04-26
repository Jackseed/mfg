import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/spicerack/spicerack_service.dart';
import '/backend/spicerack/spicerack_import.dart';
import 'package:flutter/material.dart';
import 'spicerack_import_model.dart';
import 'spicerack_webview_login.dart';
export 'spicerack_import_model.dart';

class SpicerackImportWidget extends StatefulWidget {
  const SpicerackImportWidget({Key? key}) : super(key: key);

  @override
  State<SpicerackImportWidget> createState() => _SpicerackImportWidgetState();
}

class _SpicerackImportWidgetState extends State<SpicerackImportWidget> {
  late SpicerackImportModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _service = SpicerackService();

  // Event list
  List<SpicerackUserEventStatus> _events = [];
  Set<int> _selectedEventIds = {};

  // Import
  bool _isImporting = false;
  bool _isDone = false;
  bool _forceReimport = false;
  String _statusMessage = '';
  int _progressCurrent = 0;
  int _progressTotal = 1;
  int _importedCount = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpicerackImportModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'SpicerackImport'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Open WebView for Spicerack login → returns event data directly.
  Future<void> _openLogin() async {
    final result = await Navigator.of(context).push<List<dynamic>>(
      MaterialPageRoute(
        builder: (_) => const SpicerackWebViewLogin(),
      ),
    );

    if (result == null || result.isEmpty) return;

    // Parse the raw JSON into SpicerackUserEventStatus objects
    final allStatuses = result
        .cast<Map<String, dynamic>>()
        .map((json) => SpicerackUserEventStatus.fromJson(json))
        .toList();

    // Filter to 1v1 formats, sort by date descending
    final oneVsOne = allStatuses
        .where((e) => SpicerackService.oneVsOneFormats.contains(e.eventFormat))
        .toList();

    oneVsOne.sort((a, b) {
      final da = a.startDate;
      final db = b.startDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    setState(() {
      _events = oneVsOne;
      _selectedEventIds = oneVsOne.map((e) => e.eventId).toSet();
      _statusMessage = '${oneVsOne.length} 1v1 events found'
          '${allStatuses.length != oneVsOne.length ? ' (${allStatuses.length - oneVsOne.length} non-1v1 filtered out)' : ''}';
    });
  }

  void _toggleEvent(int eventId) {
    setState(() {
      if (_selectedEventIds.contains(eventId)) {
        _selectedEventIds.remove(eventId);
      } else {
        _selectedEventIds.add(eventId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedEventIds.length == _events.length) {
        _selectedEventIds.clear();
      } else {
        _selectedEventIds = _events.map((e) => e.eventId).toSet();
      }
    });
  }

  Future<void> _startImport() async {
    final selected = _events
        .where((e) => _selectedEventIds.contains(e.eventId))
        .toList();

    if (selected.isEmpty) return;

    setState(() {
      _isImporting = true;
      _statusMessage = 'Fetching event details...';
      _progressCurrent = 0;
      _progressTotal = selected.length;
    });

    try {
      // Step 1: Build full event results from public API
      final results = await _service.buildPlayerEventResults(
        statuses: selected,
        onProgress: (current, total, status) {
          if (mounted) {
            setState(() {
              _progressCurrent = current;
              _progressTotal = total;
              _statusMessage = status;
            });
          }
        },
      );

      if (results.isEmpty) {
        if (mounted) {
          setState(() {
            _isImporting = false;
            _statusMessage = 'No event data could be loaded.';
          });
        }
        return;
      }

      // Step 2: Import into Firestore
      setState(() {
        _statusMessage = 'Importing to Firestore...';
        _progressCurrent = 0;
        _progressTotal = results.length;
      });

      final importer = SpicerackImporter();
      final count = await importer.importEvents(
        events: results,
        forceReimport: _forceReimport,
        onProgress: (current, total, status) {
          if (mounted) {
            setState(() {
              _progressCurrent = current;
              _progressTotal = total;
              _statusMessage = status;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isImporting = false;
          _isDone = true;
          _importedCount = count;
          _statusMessage = 'Successfully imported $count events!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _statusMessage = 'Import error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Spicerack Import',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Cinzel Decorative',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 20.0,
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
                colors: [Color(0xFF323236), Color(0xFF2EC4B6)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isDone) return _buildDone();
    if (_events.isEmpty) return _buildLoginPrompt();
    return _buildEventList();
  }

  /// Login button screen.
  Widget _buildLoginPrompt() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login_rounded,
            color: FlutterFlowTheme.of(context).secondary,
            size: 72,
          ),
          SizedBox(height: 24),
          Text(
            'Connect your Spicerack account to import your tournament history.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Noto Sans',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 15,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _openLogin,
              icon: Icon(Icons.open_in_browser, size: 22),
              label: Text(
                'Connect to Spicerack',
                style: TextStyle(
                  fontFamily: 'Cinzel Decorative',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).secondary,
                foregroundColor: Colors.white,
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_statusMessage.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              _statusMessage,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Noto Sans',
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Selectable event list with import button.
  Widget _buildEventList() {
    final events = _events;
    final allSelected = _selectedEventIds.length == events.length &&
        events.isNotEmpty;

    return Column(
      children: [
        // Status + select all
        Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _statusMessage,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Noto Sans',
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 13,
                      ),
                ),
              ),
              TextButton(
                onPressed: _isImporting ? null : _toggleSelectAll,
                child: Text(
                  allSelected ? 'Deselect all' : 'Select all',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondary,
                    fontFamily: 'Noto Sans',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Force reimport toggle
        Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _forceReimport,
                  onChanged: _isImporting
                      ? null
                      : (v) => setState(() => _forceReimport = v ?? false),
                  activeColor: FlutterFlowTheme.of(context).tertiary,
                  checkColor: FlutterFlowTheme.of(context).primary,
                  side: BorderSide(
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.5),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Force re-import (deletes & re-creates existing data)',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Noto Sans',
                        color: FlutterFlowTheme.of(context)
                            .primaryText
                            .withOpacity(0.7),
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Event list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final evt = events[index];
              final isSelected = _selectedEventIds.contains(evt.eventId);
              final dateStr = evt.startDate != null
                  ? DateFormat('MMM d, yyyy').format(evt.startDate!)
                  : '';

              return InkWell(
                onTap: _isImporting
                    ? null
                    : () => _toggleEvent(evt.eventId),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FlutterFlowTheme.of(context)
                            .secondary
                            .withOpacity(0.15)
                        : FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? FlutterFlowTheme.of(context)
                              .secondary
                              .withOpacity(0.5)
                          : FlutterFlowTheme.of(context)
                              .primaryText
                              .withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isSelected
                            ? FlutterFlowTheme.of(context).secondary
                            : FlutterFlowTheme.of(context)
                                .primaryText
                                .withOpacity(0.4),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evt.eventName,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Noto Sans',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                            SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondary
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    evt.eventFormat,
                                    style: TextStyle(
                                      fontFamily: 'Noto Sans',
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${evt.matchesWon}W-${evt.matchesLost}L-${evt.matchesDrawn}D',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: 'Noto Sans',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText
                                            .withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    evt.organizerName,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily: 'Noto Sans',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText
                                              .withOpacity(0.5),
                                          fontSize: 11,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        dateStr,
                        style:
                            FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: 'Noto Sans',
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText
                                      .withOpacity(0.5),
                                  fontSize: 11,
                                ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Progress bar (during import)
        if (_isImporting)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progressTotal > 0
                      ? _progressCurrent / _progressTotal
                      : null,
                  backgroundColor: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).secondary),
                ),
                SizedBox(height: 8),
                Text(
                  _statusMessage,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Noto Sans',
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 12,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        // Import button
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isImporting || _selectedEventIds.isEmpty
                  ? null
                  : _startImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).tertiary,
                foregroundColor: FlutterFlowTheme.of(context).primary,
                disabledBackgroundColor: FlutterFlowTheme.of(context)
                    .primaryText
                    .withOpacity(0.2),
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isImporting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    )
                  : Text(
                      'Import ${_selectedEventIds.length} events',
                      style: TextStyle(
                        fontFamily: 'Cinzel Decorative',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Import done screen.
  Widget _buildDone() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: FlutterFlowTheme.of(context).secondary,
            size: 80,
          ),
          SizedBox(height: 24),
          Text(
            '$_importedCount events imported!',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: 'Cinzel Decorative',
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.safePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).secondary,
                foregroundColor: Colors.white,
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Back to Crew',
                style: TextStyle(
                  fontFamily: 'Cinzel Decorative',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
