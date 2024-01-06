import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/page_component/deck_form/deck_form_widget.dart';
import '/small_components/deck_view/deck_view_widget.dart';
import '/flutter_flow/request_manager.dart';

import 'c1_deck_list_widget.dart' show C1DeckListWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class C1DeckListModel extends FlutterFlowModel<C1DeckListWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  /// Query cache managers for this widget.

  final _deckListQueryManager = StreamRequestManager<List<DecksRecord>>();
  Stream<List<DecksRecord>> deckListQuery({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<DecksRecord>> Function() requestFn,
  }) =>
      _deckListQueryManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearDeckListQueryCache() => _deckListQueryManager.clear();
  void clearDeckListQueryCacheKey(String? uniqueKey) =>
      _deckListQueryManager.clearRequest(uniqueKey);

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {
    unfocusNode.dispose();

    /// Dispose query cache managers for this widget.

    clearDeckListQueryCache();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
