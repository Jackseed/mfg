import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/custom_snackbar_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'deck_edit_widget.dart' show DeckEditWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DeckEditModel extends FlutterFlowModel<DeckEditWidget> {
  ///  Local state fields for this component.

  bool isBlack = true;

  bool areCardsLoaded = true;

  String? selectedAvatar;

  String? selectedCardName;

  bool isWhite = true;

  bool isRed = true;

  bool isBlue = true;

  bool isGreen = true;

  bool noResult = false;

  int randomAvatarNumber = 0;

  bool originalAvatar = true;

  bool showSnackbar = false;

  String? snackbarMessage;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Firestore Query - Query a collection] action in DeckEdit widget.
  List<ImagesRecord>? avatars;
  // Model for DialogTitle component.
  late DialogTitleModel dialogTitleModel;
  // State field(s) for NameInput widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputController;
  String? Function(BuildContext, String?)? nameInputControllerValidator;
  // State field(s) for Switch widget.
  bool? switchValue;
  // State field(s) for avatar_input widget.
  FocusNode? avatarInputFocusNode;
  TextEditingController? avatarInputController;
  String? Function(BuildContext, String?)? avatarInputControllerValidator;
  // Stores action output result for [Backend Call - API (Scryfall illu by name)] action in avatar_input widget.
  ApiCallResponse? apiResultlta;
  // Stores action output result for [Firestore Query - Query a collection] action in save_button widget.
  List<DecksRecord>? crewDecks;
  // Model for CustomSnackbar component.
  late CustomSnackbarModel customSnackbarModel;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    dialogTitleModel = createModel(context, () => DialogTitleModel());
    customSnackbarModel = createModel(context, () => CustomSnackbarModel());
  }

  void dispose() {
    dialogTitleModel.dispose();
    nameInputFocusNode?.dispose();
    nameInputController?.dispose();

    avatarInputFocusNode?.dispose();
    avatarInputController?.dispose();

    customSnackbarModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
