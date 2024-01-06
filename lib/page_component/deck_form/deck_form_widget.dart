import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/custom_snackbar_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/small_components/crewmate_select/crewmate_select_widget.dart';
import '/small_components/dialog_title/dialog_title_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'deck_form_model.dart';
export 'deck_form_model.dart';

class DeckFormWidget extends StatefulWidget {
  const DeckFormWidget({Key? key}) : super(key: key);

  @override
  _DeckFormWidgetState createState() => _DeckFormWidgetState();
}

class _DeckFormWidgetState extends State<DeckFormWidget> {
  late DeckFormModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeckFormModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('DECK_FORM_COMP_DeckForm_ON_INIT_STATE');
      // Get all avatars
      logFirebaseEvent('DeckForm_Getallavatars');
      _model.avatars = await queryImagesRecordOnce(
        queryBuilder: (imagesRecord) => imagesRecord.where(
          'type',
          isEqualTo: 'avatar',
        ),
        limit: 20,
      );
      // Set initial variable values
      logFirebaseEvent('DeckForm_Setinitialvariablevalues');
      setState(() {
        _model.areCardsLoaded = false;
        _model.isWhite = false;
        _model.isRed = false;
        _model.isBlue = false;
        _model.isBlack = false;
        _model.isGreen = false;
        _model.randomAvatarNumber = valueOrDefault<int>(
          random_data.randomInteger(
              0,
              valueOrDefault<int>(
                valueOrDefault<int>(
                      _model.avatars?.length,
                      0,
                    ) -
                    1,
                0,
              )),
          0,
        );
        _model.noResult = false;
      });
    });

    _model.nameInputController ??= TextEditingController();
    _model.nameInputFocusNode ??= FocusNode();

    _model.avatarInputController ??= TextEditingController();
    _model.avatarInputFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF323236), Color(0xFFE6486F)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
      ),
      child: Stack(
        children: [
          Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dialogTitleModel,
                    updateCallback: () => setState(() {}),
                    child: DialogTitleWidget(
                      formTitle: FFLocalizations.of(context).getText(
                        '1ehdr4fj' /* NEW DECK */,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 8.0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'knpd4bkz' /* Deck name */,
                        ),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Cinzel Decorative',
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontSize: 18.0,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(28.0, 0.0, 20.0, 12.0),
                    child: TextFormField(
                      controller: _model.nameInputController,
                      focusNode: _model.nameInputFocusNode,
                      autofocus: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelStyle: FlutterFlowTheme.of(context).labelMedium,
                        hintText: FFLocalizations.of(context).getText(
                          'r1tsialq' /* Type the name you want */,
                        ),
                        hintStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Noto Sans',
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primaryText,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).primaryText,
                        prefixIcon: Icon(
                          FFIcons.kcards,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Noto Sans',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                      validator: _model.nameInputControllerValidator
                          .asValidator(context),
                    ),
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 20.0,
                    endIndent: 20.0,
                    color: FlutterFlowTheme.of(context).accent4,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'j233lymk' /* Avatar selection */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Cinzel Decorative',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            28.0, 8.0, 28.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              children: [
                                if (!valueOrDefault<bool>(
                                  _model.switchValue,
                                  false,
                                ))
                                  Material(
                                    color: Colors.transparent,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                          width: 10.0,
                                        ),
                                      ),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          '8elg5isn' /* Random card */,
                                        ),
                                        textAlign: TextAlign.start,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                if (valueOrDefault<bool>(
                                  _model.switchValue,
                                  true,
                                ))
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      logFirebaseEvent(
                                          'DECK_FORM_COMP_Text_nkzaw07s_ON_TAP');
                                      logFirebaseEvent('Text_set_form_field');
                                      setState(() {
                                        _model.switchValue = false;
                                      });
                                      // Set a random avatar
                                      logFirebaseEvent('Text_Setarandomavatar');
                                      setState(() {
                                        _model.selectedAvatar =
                                            valueOrDefault<String>(
                                          _model
                                              .avatars?[
                                                  _model.randomAvatarNumber]
                                              ?.image
                                              ?.first
                                              ?.downloadURL,
                                          'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tfGVufDB8fDB8fHww&w=1000&q=80',
                                        );
                                        _model.selectedCardName = 'Avatar';
                                      });
                                    },
                                    child: Text(
                                      FFLocalizations.of(context).getText(
                                        '197t4btp' /* Random card */,
                                      ),
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Noto Sans',
                                            fontSize: 14.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    4.0, 0.0, 4.0, 0.0),
                                child: Switch.adaptive(
                                  value: _model.switchValue ??= true,
                                  onChanged: (newValue) async {
                                    setState(
                                        () => _model.switchValue = newValue!);

                                    if (!newValue!) {
                                      logFirebaseEvent(
                                          'DECK_FORM_Switch_2m8fzfvk_ON_TOGGLE_OFF');
                                      // Set a random avatar
                                      logFirebaseEvent(
                                          'Switch_Setarandomavatar');
                                      setState(() {
                                        _model.selectedAvatar =
                                            valueOrDefault<String>(
                                          _model
                                              .avatars?[
                                                  _model.randomAvatarNumber]
                                              ?.image
                                              ?.first
                                              ?.downloadURL,
                                          'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tfGVufDB8fDB8fHww&w=1000&q=80',
                                        );
                                        _model.selectedCardName = 'Avatar';
                                      });
                                    }
                                  },
                                  activeColor:
                                      FlutterFlowTheme.of(context).tertiary,
                                  activeTrackColor:
                                      FlutterFlowTheme.of(context).disabledText,
                                  inactiveTrackColor:
                                      FlutterFlowTheme.of(context).tertiary,
                                  inactiveThumbColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                            ),
                            Stack(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              children: [
                                if (valueOrDefault<bool>(
                                  _model.switchValue,
                                  true,
                                ))
                                  Material(
                                    color: Colors.transparent,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                          width: 10.0,
                                        ),
                                      ),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          '37yhvz7t' /* Card search */,
                                        ),
                                        textAlign: TextAlign.start,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Noto Sans',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                if (!valueOrDefault<bool>(
                                  _model.switchValue,
                                  false,
                                ))
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      logFirebaseEvent(
                                          'DECK_FORM_COMP_Text_jd48txew_ON_TAP');
                                      logFirebaseEvent('Text_set_form_field');
                                      setState(() {
                                        _model.switchValue = true;
                                      });
                                    },
                                    child: Text(
                                      FFLocalizations.of(context).getText(
                                        'rfkcb5xm' /* Card search */,
                                      ),
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Noto Sans',
                                            fontSize: 14.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (valueOrDefault<bool>(
                        _model.switchValue,
                        true,
                      ))
                        Container(
                          decoration: BoxDecoration(),
                          child: Visibility(
                            visible: (String? selectedCard) {
                              return (selectedCard == null) |
                                  (selectedCard == 'Avatar');
                            }(_model.selectedCardName),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  28.0, 12.0, 20.0, 12.0),
                              child: TextFormField(
                                controller: _model.avatarInputController,
                                focusNode: _model.avatarInputFocusNode,
                                onChanged: (_) => EasyDebounce.debounce(
                                  '_model.avatarInputController',
                                  Duration(milliseconds: 2000),
                                  () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_avatar_input_ON_TEXTFIELD_CHAN');
                                    logFirebaseEvent(
                                        'avatar_input_update_component_state');
                                    setState(() {
                                      _model.areCardsLoaded = false;
                                    });
                                    logFirebaseEvent(
                                        'avatar_input_backend_call');
                                    _model.apiResultlta =
                                        await ScryfallIlluByNameCall.call(
                                      cardName:
                                          _model.avatarInputController.text,
                                    );
                                    if ((_model.apiResultlta?.succeeded ??
                                        true)) {
                                      if ((List<String>? resultData) {
                                        return (resultData != null) &
                                            (resultData != []);
                                      }((getJsonField(
                                        functions.replaceNullValues(
                                            (_model.apiResultlta?.jsonBody ??
                                                '')),
                                        r'''$.data[:]''',
                                        true,
                                      ) as List)
                                          .map<String>((s) => s.toString())
                                          .toList())) {
                                        // Display results
                                        logFirebaseEvent(
                                            'avatar_input_Displayresults');
                                        setState(() {
                                          _model.areCardsLoaded = true;
                                          _model.noResult = false;
                                        });
                                      } else {
                                        // No result
                                        logFirebaseEvent(
                                            'avatar_input_Noresult');
                                        setState(() {
                                          _model.noResult = true;
                                        });
                                      }
                                    } else {
                                      // No result
                                      logFirebaseEvent('avatar_input_Noresult');
                                      setState(() {
                                        _model.noResult = true;
                                      });
                                    }

                                    setState(() {});
                                  },
                                ),
                                autofocus: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        fontFamily: 'Noto Sans',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  hintText: FFLocalizations.of(context).getText(
                                    '4y7jf1r1' /* Type a card name to search */,
                                  ),
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Noto Sans',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  prefixIcon: Icon(
                                    FFIcons.kp,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Noto Sans',
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                validator: _model.avatarInputControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                        ),
                      if (!valueOrDefault<bool>(
                        _model.switchValue,
                        false,
                      ))
                        Stack(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 12.0, 20.0, 12.0),
                              child: Container(
                                width: 120.0,
                                height: 120.0,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.network(
                                  valueOrDefault<String>(
                                    _model.avatars?[_model.randomAvatarNumber]
                                        ?.image?.first?.downloadURL,
                                    'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tfGVufDB8fDB8fHww&w=1000&q=80',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            FlutterFlowIconButton(
                              borderRadius: 40.0,
                              borderWidth: 1.0,
                              buttonSize: 50.0,
                              fillColor: Color(0x42000000),
                              icon: Icon(
                                Icons.refresh,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 28.0,
                              ),
                              onPressed: () async {
                                logFirebaseEvent(
                                    'DECK_FORM_COMP_refresh_ICN_ON_TAP');
                                // Random new avatar
                                logFirebaseEvent('IconButton_Randomnewavatar');
                                setState(() {
                                  _model.randomAvatarNumber =
                                      valueOrDefault<int>(
                                    random_data.randomInteger(
                                        0,
                                        valueOrDefault<int>(
                                          valueOrDefault<int>(
                                                _model.avatars?.length,
                                                0,
                                              ) -
                                              1,
                                          0,
                                        )),
                                    0,
                                  );
                                });
                                // Update selectedAvatar
                                logFirebaseEvent(
                                    'IconButton_UpdateselectedAvatar');
                                setState(() {
                                  _model.selectedAvatar =
                                      valueOrDefault<String>(
                                    _model.avatars?[_model.randomAvatarNumber]
                                        ?.image?.first?.downloadURL,
                                    'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tfGVufDB8fDB8fHww&w=1000&q=80',
                                  );
                                  _model.selectedCardName = 'Avatar';
                                });
                              },
                            ),
                          ],
                        ),
                      if (valueOrDefault<bool>(
                        (_model.avatarInputController.text.length > 0) &&
                            ((String? selectedCard) {
                              return (selectedCard == null) |
                                  (selectedCard == 'Avatar');
                            }(_model.selectedCardName)) &&
                            valueOrDefault<bool>(
                              _model.switchValue,
                              true,
                            ),
                        true,
                      ))
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                          ),
                          child: Stack(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            children: [
                              if (!_model.areCardsLoaded && !_model.noResult)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/output-onlinegiftools.gif',
                                    width: 300.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (_model.areCardsLoaded)
                                Builder(
                                  builder: (context) {
                                    final searchedCards = getJsonField(
                                      functions.replaceNullValues(
                                          (_model.apiResultlta?.jsonBody ??
                                              '')),
                                      r'''$.data''',
                                    ).toList();
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      itemCount: searchedCards.length,
                                      itemBuilder:
                                          (context, searchedCardsIndex) {
                                        final searchedCardsItem =
                                            searchedCards[searchedCardsIndex];
                                        return Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              logFirebaseEvent(
                                                  'DECK_FORM_COMP_item_container_ON_TAP');
                                              logFirebaseEvent(
                                                  'item_container_update_component_state');
                                              setState(() {
                                                _model.selectedAvatar =
                                                    getJsonField(
                                                  searchedCardsItem,
                                                  r'''$.image_uris.art_crop''',
                                                ).toString();
                                                _model.selectedCardName =
                                                    getJsonField(
                                                  searchedCardsItem,
                                                  r'''$.name''',
                                                ).toString();
                                              });
                                            },
                                            child: Material(
                                              color: Colors.transparent,
                                              elevation: 1.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                              child: Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                height: 85.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 4.0,
                                                      color: Color(0x00323236),
                                                      offset: Offset(0.0, 2.0),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.2,
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.2,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.network(
                                                        valueOrDefault<String>(
                                                          getJsonField(
                                                            searchedCardsItem,
                                                            r'''$.image_uris.art_crop''',
                                                          )?.toString(),
                                                          'https://cdn.pixabay.com/photo/2017/05/21/20/53/fern-2332262_1280.jpg',
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  20.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Text(
                                                        valueOrDefault<String>(
                                                          getJsonField(
                                                            searchedCardsItem,
                                                            r'''$.name''',
                                                          )?.toString(),
                                                          '\"\"',
                                                        ).maybeHandleOverflow(
                                                          maxChars: 15,
                                                          replacement: '…',
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              if (_model.noResult)
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      FFIcons.kcentaur,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 90.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 24.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'n9szxckm' /* We couldn't find this card */,
                                        ),
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Cinzel Decorative',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 4.0, 0.0, 0.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            '940nz249' /* Try to spell it differently or... */,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Noto Sans',
                                                fontSize: 12.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      if (valueOrDefault<bool>(
                        (String? selectedCard, String selectedCardName) {
                          return (selectedCard != null) &
                              (selectedCardName != 'Avatar');
                        }(
                            _model.selectedCardName,
                            valueOrDefault<String>(
                              _model.selectedCardName,
                              'Avatar',
                            )),
                        false,
                      ))
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.8,
                              height: 85.0,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    color: Color(0x00323236),
                                    offset: Offset(0.0, 2.0),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.2,
                                    height:
                                        MediaQuery.sizeOf(context).width * 0.2,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.network(
                                      _model.selectedAvatar!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      _model.selectedCardName!
                                          .maybeHandleOverflow(
                                        maxChars: 15,
                                        replacement: '…',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional(1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 4.0, 0.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'DECK_FORM_COMP_Icon_82mv02wk_ON_TAP');
                                            logFirebaseEvent(
                                                'Icon_update_component_state');
                                            setState(() {
                                              _model.areCardsLoaded = true;
                                              _model.selectedAvatar = null;
                                              _model.selectedCardName = null;
                                            });
                                          },
                                          child: Icon(
                                            Icons.cancel_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 20.0,
                    endIndent: 20.0,
                    color: FlutterFlowTheme.of(context).accent4,
                  ),
                  Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 8.0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'c2uagd1d' /* Deck owner */,
                        ),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Cinzel Decorative',
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontSize: 18.0,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 12.0),
                    child: AuthUserStreamWidget(
                      builder: (context) =>
                          FutureBuilder<List<CrewmatesRecord>>(
                        future: queryCrewmatesRecordOnce(
                          parent: currentUserDocument?.crewRef,
                          queryBuilder: (crewmatesRecord) =>
                              crewmatesRecord.orderBy('name'),
                        ),
                        builder: (context, snapshot) {
                          // Customize what your widget looks like when it's loading.
                          if (!snapshot.hasData) {
                            return Center(
                              child: SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: SpinKitFadingFour(
                                  color: Color(0xFFE6486F),
                                  size: 50.0,
                                ),
                              ),
                            );
                          }
                          List<CrewmatesRecord>
                              crewmateSelectCrewmatesRecordList =
                              snapshot.data!;
                          return wrapWithModel(
                            model: _model.crewmateSelectModel,
                            updateCallback: () => setState(() {}),
                            updateOnChange: true,
                            child: CrewmateSelectWidget(
                              playerToRemoveFromList: '',
                              playerList: crewmateSelectCrewmatesRecordList
                                  .map((e) => e.name)
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 20.0,
                    endIndent: 20.0,
                    color: FlutterFlowTheme.of(context).accent4,
                  ),
                  Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 8.0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'fuz1fad9' /* Select your colors */,
                        ),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Cinzel Decorative',
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontSize: 18.0,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 12.0),
                    child: Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Stack(
                          children: [
                            if (!valueOrDefault<bool>(
                              _model.isBlack,
                              true,
                            ))
                              Align(
                                alignment: AlignmentDirectional(0.7, 1.0),
                                child: FlutterFlowIconButton(
                                  borderColor: Color(0x004B39EF),
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFFCDCDCD),
                                  icon: Icon(
                                    FFIcons.kblack,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_black_unactive_ON_TAP');
                                    logFirebaseEvent(
                                        'black_unactive_update_component_state');
                                    setState(() {
                                      _model.isBlack = true;
                                    });
                                  },
                                ),
                              ),
                            if (_model.isBlack)
                              Align(
                                alignment: AlignmentDirectional(0.7, 1.0),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFF4A4A4A),
                                  icon: Icon(
                                    FFIcons.kblack,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_black_active_ON_TAP');
                                    logFirebaseEvent(
                                        'black_active_update_component_state');
                                    setState(() {
                                      _model.isBlack = false;
                                    });
                                  },
                                ),
                              ),
                            if (!_model.isWhite)
                              Align(
                                alignment: AlignmentDirectional(0.0, -1.0),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFFFFFDEF),
                                  icon: Icon(
                                    FFIcons.kwhite,
                                    color: Color(0xFFCFCFCF),
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_white_unactive_ON_TAP');
                                    logFirebaseEvent(
                                        'white_unactive_update_component_state');
                                    setState(() {
                                      _model.isWhite = true;
                                    });
                                  },
                                ),
                              ),
                            if (_model.isWhite)
                              Align(
                                alignment: AlignmentDirectional(0.0, -1.0),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFFF3ECA0),
                                  icon: Icon(
                                    FFIcons.kwhite,
                                    color: Color(0xFF535353),
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_white_active_ON_TAP');
                                    logFirebaseEvent(
                                        'white_active_update_component_state');
                                    setState(() {
                                      _model.isWhite = false;
                                    });
                                  },
                                ),
                              ),
                            if (!valueOrDefault<bool>(
                              _model.isRed,
                              false,
                            ))
                              Align(
                                alignment: AlignmentDirectional(-0.7, 1.0),
                                child: FlutterFlowIconButton(
                                  borderColor: Color(0x004B39EF),
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFFFCE4DA),
                                  icon: Icon(
                                    FFIcons.kred,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_red_unactive_ON_TAP');
                                    logFirebaseEvent(
                                        'red_unactive_update_component_state');
                                    setState(() {
                                      _model.isRed = true;
                                    });
                                  },
                                ),
                              ),
                            if (_model.isRed)
                              Align(
                                alignment: AlignmentDirectional(-0.7, 1.0),
                                child: FlutterFlowIconButton(
                                  borderColor: Color(0x004B39EF),
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFFFB8080),
                                  icon: Icon(
                                    FFIcons.kred,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_red_active_ON_TAP');
                                    logFirebaseEvent(
                                        'red_active_update_component_state');
                                    setState(() {
                                      _model.isRed = false;
                                    });
                                  },
                                ),
                              ),
                            if (!_model.isBlue)
                              Align(
                                alignment: AlignmentDirectional(1.0, -0.3),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFFCCDCE9),
                                  icon: Icon(
                                    FFIcons.kblue,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_blue_unactive_ON_TAP');
                                    logFirebaseEvent(
                                        'blue_unactive_update_component_state');
                                    setState(() {
                                      _model.isBlue = true;
                                    });
                                  },
                                ),
                              ),
                            if (_model.isBlue)
                              Align(
                                alignment: AlignmentDirectional(1.0, -0.3),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFF59A4E7),
                                  icon: Icon(
                                    FFIcons.kblue,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_blue_active_ON_TAP');
                                    logFirebaseEvent(
                                        'blue_active_update_component_state');
                                    setState(() {
                                      _model.isBlue = false;
                                    });
                                  },
                                ),
                              ),
                            if (!_model.isGreen)
                              Align(
                                alignment: AlignmentDirectional(-1.0, -0.3),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFFC7E6B8),
                                  icon: Icon(
                                    FFIcons.kgreen,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_green_unactive_ON_TAP');
                                    logFirebaseEvent(
                                        'green_unactive_update_component_state');
                                    setState(() {
                                      _model.isGreen = true;
                                    });
                                  },
                                ),
                              ),
                            if (_model.isGreen)
                              Align(
                                alignment: AlignmentDirectional(-1.0, -0.3),
                                child: FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFF7BBC60),
                                  icon: Icon(
                                    FFIcons.kgreen,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    logFirebaseEvent(
                                        'DECK_FORM_COMP_green_active_ON_TAP');
                                    logFirebaseEvent(
                                        'green_active_update_component_state');
                                    setState(() {
                                      _model.isGreen = false;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (false)
                    Container(
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 20.0, 0.0, 0.0),
                              child: Text(
                                FFLocalizations.of(context).getText(
                                  'hqgzwgzm' /* Select your background */,
                                ),
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .override(
                                      fontFamily: 'Noto Sans',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      fontSize: 18.0,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 12.0, 20.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 40.0,
                                  borderWidth: 1.0,
                                  buttonSize: 50.0,
                                  fillColor: Color(0x42000000),
                                  icon: Icon(
                                    Icons.refresh,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 28.0,
                                  ),
                                  onPressed: () {
                                    print('RandomBackgroundButton pressed ...');
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: FutureBuilder<List<ImagesRecord>>(
                                    future: queryImagesRecordOnce(),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: SpinKitFadingFour(
                                              color: Color(0xFFE6486F),
                                              size: 50.0,
                                            ),
                                          ),
                                        );
                                      }
                                      List<ImagesRecord> imageImagesRecordList =
                                          snapshot.data!;
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          imageImagesRecordList[
                                                  random_data.randomInteger(
                                                      0,
                                                      imageImagesRecordList
                                                              .length -
                                                          1)]
                                              .image
                                              .first
                                              .downloadURL,
                                          width: 200.0,
                                          height: 120.0,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 40.0,
                                  borderWidth: 1.0,
                                  buttonSize: 50.0,
                                  fillColor: Color(0x42000000),
                                  icon: Icon(
                                    Icons.photo_size_select_actual,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 28.0,
                                  ),
                                  onPressed: () {
                                    print('SelectBackgroundButton pressed ...');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        logFirebaseEvent('DECK_FORM_COMP_save_button_ON_TAP');
                        final firestoreBatch =
                            FirebaseFirestore.instance.batch();
                        try {
                          logFirebaseEvent(
                              'save_button_update_component_state');
                          setState(() {
                            _model.showSnackbar = false;
                          });
                          if (_model.nameInputController.text != null &&
                              _model.nameInputController.text != '') {
                            if (_model.crewmateSelectModel.playerSelectValue !=
                                    null &&
                                _model.crewmateSelectModel.playerSelectValue !=
                                    '') {
                              if (_model.selectedCardName != null &&
                                  _model.selectedCardName != '') {
                                // Get all crew decks
                                logFirebaseEvent('save_button_Getallcrewdecks');
                                _model.crewDecks = await queryDecksRecordOnce(
                                  queryBuilder: (decksRecord) =>
                                      decksRecord.where(
                                    'crewId',
                                    isEqualTo: valueOrDefault(
                                        currentUserDocument?.crewId, ''),
                                  ),
                                );
                                if (!(_model.crewDecks!
                                    .map((e) => valueOrDefault<String>(
                                          e.name,
                                          'empty',
                                        ))
                                    .toList()
                                    .contains(
                                        _model.nameInputController.text))) {
                                  // Get Crewmate
                                  logFirebaseEvent('save_button_GetCrewmate');
                                  _model.crewmate =
                                      await queryCrewmatesRecordOnce(
                                    parent: currentUserDocument?.crewRef,
                                    queryBuilder: (crewmatesRecord) =>
                                        crewmatesRecord.where(
                                      'name',
                                      isEqualTo: _model.crewmateSelectModel
                                          .playerSelectValue,
                                    ),
                                    singleRecord: true,
                                  ).then((s) => s.firstOrNull);
                                  // Create Deck
                                  logFirebaseEvent('save_button_CreateDeck');

                                  var decksRecordReference =
                                      DecksRecord.collection.doc();
                                  firestoreBatch.set(decksRecordReference, {
                                    ...createDecksRecordData(
                                      name: _model.nameInputController.text,
                                      avatarUrl: _model.selectedAvatar,
                                      avatarName: _model.selectedCardName,
                                      crewId: valueOrDefault(
                                          currentUserDocument?.crewId, ''),
                                      crewmateId: _model.crewmate?.reference.id,
                                      crewmateRef: _model.crewmate?.reference,
                                    ),
                                    ...mapToFirestore(
                                      {
                                        'colors': functions.booleansToArray(
                                            _model.isBlack,
                                            _model.isBlue,
                                            _model.isGreen,
                                            _model.isWhite,
                                            _model.isRed),
                                      },
                                    ),
                                  });
                                  _model.deck =
                                      DecksRecord.getDocumentFromData({
                                    ...createDecksRecordData(
                                      name: _model.nameInputController.text,
                                      avatarUrl: _model.selectedAvatar,
                                      avatarName: _model.selectedCardName,
                                      crewId: valueOrDefault(
                                          currentUserDocument?.crewId, ''),
                                      crewmateId: _model.crewmate?.reference.id,
                                      crewmateRef: _model.crewmate?.reference,
                                    ),
                                    ...mapToFirestore(
                                      {
                                        'colors': functions.booleansToArray(
                                            _model.isBlack,
                                            _model.isBlue,
                                            _model.isGreen,
                                            _model.isWhite,
                                            _model.isRed),
                                      },
                                    ),
                                  }, decksRecordReference);
                                  if (_model.crewmate?.userId != null &&
                                      _model.crewmate?.userId != '') {
                                    // Update User
                                    logFirebaseEvent('save_button_UpdateUser');

                                    firestoreBatch.update(
                                        _model.crewmate!.userReference!, {
                                      ...mapToFirestore(
                                        {
                                          'deckIds': FieldValue.arrayUnion(
                                              [_model.deck?.reference.id]),
                                        },
                                      ),
                                    });
                                  }
                                  // Leave form
                                  logFirebaseEvent('save_button_Leaveform');
                                  Navigator.pop(context);
                                  // Deck saved!
                                  logFirebaseEvent('save_button_Decksaved!');
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        valueOrDefault<String>(
                                          FFLocalizations.of(context)
                                              .getVariableText(
                                            enText: 'Deck saved!',
                                            frText: 'Deck sauvegardé !',
                                          ),
                                          'Deck saved!',
                                        ),
                                        style: GoogleFonts.getFont(
                                          'Noto Sans',
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).tertiary,
                                    ),
                                  );
                                } else {
                                  // Deck name already taken
                                  logFirebaseEvent(
                                      'save_button_Decknamealreadytaken');
                                  setState(() {
                                    _model.showSnackbar = true;
                                    _model.snackbarMessage =
                                        valueOrDefault<String>(
                                      FFLocalizations.of(context)
                                          .getVariableText(
                                        enText: 'Deck name already taken',
                                        frText: 'Ce nom de deck est déjà pris',
                                      ),
                                      'Deck name already taken',
                                    );
                                  });
                                  logFirebaseEvent('save_button_wait__delay');
                                  await Future.delayed(
                                      const Duration(milliseconds: 4000));
                                  logFirebaseEvent(
                                      'save_button_update_component_state');
                                  setState(() {
                                    _model.showSnackbar = false;
                                  });
                                }
                              } else {
                                // You need an avatar
                                logFirebaseEvent('save_button_Youneedanavatar');
                                setState(() {
                                  _model.showSnackbar = true;
                                  _model.snackbarMessage =
                                      valueOrDefault<String>(
                                    FFLocalizations.of(context).getVariableText(
                                      enText: 'You need an avatar',
                                      frText: 'L\'avatar est requis',
                                    ),
                                    'You need an avatar',
                                  );
                                });
                                logFirebaseEvent('save_button_wait__delay');
                                await Future.delayed(
                                    const Duration(milliseconds: 4000));
                                logFirebaseEvent(
                                    'save_button_update_component_state');
                                setState(() {
                                  _model.showSnackbar = false;
                                });
                              }
                            } else {
                              // You need to select a deck owner
                              logFirebaseEvent(
                                  'save_button_Youneedtoselectadeckowner');
                              setState(() {
                                _model.showSnackbar = true;
                                _model.snackbarMessage = valueOrDefault<String>(
                                  FFLocalizations.of(context).getVariableText(
                                    enText: 'You need to select a deck owner',
                                    frText:
                                        'Le propriétaire du deck est requis',
                                  ),
                                  'You need to select a deck owner',
                                );
                              });
                              logFirebaseEvent('save_button_wait__delay');
                              await Future.delayed(
                                  const Duration(milliseconds: 4000));
                              logFirebaseEvent(
                                  'save_button_update_component_state');
                              setState(() {
                                _model.showSnackbar = false;
                              });
                            }
                          } else {
                            // You need a deck name
                            logFirebaseEvent('save_button_Youneedadeckname');
                            setState(() {
                              _model.showSnackbar = true;
                              _model.snackbarMessage = valueOrDefault<String>(
                                FFLocalizations.of(context).getVariableText(
                                  enText: 'You need a deck name',
                                  frText: 'Le nom du deck est requis',
                                ),
                                'You need a deck name',
                              );
                            });
                            logFirebaseEvent('save_button_wait__delay');
                            await Future.delayed(
                                const Duration(milliseconds: 4000));
                            logFirebaseEvent(
                                'save_button_update_component_state');
                            setState(() {
                              _model.showSnackbar = false;
                            });
                          }
                        } finally {
                          await firestoreBatch.commit();
                        }

                        setState(() {});
                      },
                      text: FFLocalizations.of(context).getText(
                        'elbpjfvc' /* Save */,
                      ),
                      icon: Icon(
                        Icons.save,
                        size: 24.0,
                      ),
                      options: FFButtonOptions(
                        width: 280.0,
                        height: 56.0,
                        padding: EdgeInsets.all(0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleLarge,
                        elevation: 3.0,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_model.showSnackbar)
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.customSnackbarModel,
                updateCallback: () => setState(() {}),
                child: CustomSnackbarWidget(
                  message: _model.snackbarMessage!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
