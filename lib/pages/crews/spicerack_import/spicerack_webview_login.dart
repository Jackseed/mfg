import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Opens a WebView to spicerack.gg.
/// After the user logs in, calls the event-statuses API from within the
/// WebView (so the session cookie is automatically sent) and returns the
/// raw JSON list via Navigator.pop.
class SpicerackWebViewLogin extends StatefulWidget {
  const SpicerackWebViewLogin({Key? key}) : super(key: key);

  @override
  State<SpicerackWebViewLogin> createState() => _SpicerackWebViewLoginState();
}

class _SpicerackWebViewLoginState extends State<SpicerackWebViewLogin> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFetchingEvents = false;
  bool _gotData = false;
  String _statusText = 'Log in to your Spicerack account';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SpicerackBridge',
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: _onPageFinished,
      ))
      ..loadRequest(Uri.parse('https://www.spicerack.gg/events/history'));
  }

  Future<void> _onPageFinished(String url) async {
    if (mounted) setState(() => _isLoading = false);

    // After every page load, try to fetch event statuses.
    // If the user isn't logged in yet, the API will return 401/403
    // and we auto-click the "Log in" button to open the login modal.
    if (!_isFetchingEvents && !_gotData) {
      _fetchEventStatuses();
    }
  }

  /// Inject JS to call the event-statuses API and return data via bridge.
  void _fetchEventStatuses() {
    setState(() {
      _isFetchingEvents = true;
    });

    _controller.runJavaScript('''
      (async function() {
        try {
          const response = await fetch('https://api.spicerack.gg/api/event-statuses/', {
            credentials: 'include',
            headers: { 'Accept': 'application/json' }
          });
          if (response.status === 401 || response.status === 403) {
            // Not logged in yet — auto-click the "Log in" button
            SpicerackBridge.postMessage(JSON.stringify({
              notLoggedIn: true
            }));
            // Try to click the login button to open the modal
            setTimeout(() => {
              const buttons = document.querySelectorAll('button, a');
              for (const btn of buttons) {
                const text = btn.textContent.trim().toLowerCase();
                if (text === 'log in' || text === 'login' || text === 'sign in') {
                  btn.click();
                  break;
                }
              }
            }, 500);
            return;
          }
          if (!response.ok) {
            SpicerackBridge.postMessage(JSON.stringify({
              error: true,
              message: 'HTTP ' + response.status
            }));
            return;
          }
          const data = await response.json();
          SpicerackBridge.postMessage(JSON.stringify({
            error: false,
            data: data
          }));
        } catch (e) {
          SpicerackBridge.postMessage(JSON.stringify({
            error: true,
            message: e.toString()
          }));
        }
      })();
    ''');
  }

  /// Handle messages from the JS bridge.
  void _onBridgeMessage(JavaScriptMessage message) {
    try {
      final json = jsonDecode(message.message);

      // Not logged in yet — reset and let user continue browsing
      if (json['notLoggedIn'] == true) {
        if (mounted) {
          setState(() {
            _isFetchingEvents = false;
            _statusText = 'Log in to your Spicerack account';
          });
        }
        return;
      }

      if (json['error'] == true) {
        print('[SpicerackLogin] API error: ${json['message']}');
        if (mounted) {
          setState(() {
            _isFetchingEvents = false;
            _statusText = 'Error: ${json['message']}';
          });
        }
        return;
      }

      // Success — return the raw event data
      final data = json['data'] as List;
      print('[SpicerackLogin] Got ${data.length} event statuses!');
      _gotData = true;
      if (mounted) {
        setState(() {
          _statusText = 'Found ${data.length} events!';
        });
        Navigator.of(context).pop(data);
      }
    } catch (e) {
      print('[SpicerackLogin] Bridge parse error: $e');
      if (mounted) {
        setState(() {
          _isFetchingEvents = false;
          _statusText = 'Error parsing response.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: FlutterFlowTheme.of(context).primaryText),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: Text(
          'Connect to Spicerack',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Cinzel Decorative',
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 16.0,
              ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isFetchingEvents && !_isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.9),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FlutterFlowTheme.of(context).secondary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusText,
                        style:
                            FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: 'Noto Sans',
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
                                  fontSize: 13,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
