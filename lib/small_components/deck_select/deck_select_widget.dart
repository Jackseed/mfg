import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/page_component/deck_form/deck_form_widget.dart';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'deck_select_model.dart';
export 'deck_select_model.dart';

class DeckSelectWidget extends StatefulWidget {
  const DeckSelectWidget({
    Key? key,
    String? deckOwnerName,
    required this.deckNumber,
    String? initiallySelectedDeck,
  })  : this.deckOwnerName = deckOwnerName ?? 'empty',
        this.initiallySelectedDeck = initiallySelectedDeck ?? 'empty',
        super(key: key);

  final String deckOwnerName;
  final int? deckNumber;
  final String initiallySelectedDeck;

  @override
  _DeckSelectWidgetState createState() => _DeckSelectWidgetState();
}

class _DeckSelectWidgetState extends State<DeckSelectWidget> {
  late DeckSelectModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeckSelectModel());

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

    return AuthUserStreamWidget(
      builder: (context) => StreamBuilder<List<CrewmatesRecord>>(
        stream: queryCrewmatesRecord(
          parent: currentUserDocument?.crewRef,
          queryBuilder: (crewmatesRecord) => crewmatesRecord.where(
            'name',
            isEqualTo: widget.deckOwnerName != '' ? widget.deckOwnerName : null,
          ),
          singleRecord: true,
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
          List<CrewmatesRecord> rowCrewmatesRecordList = snapshot.data!;
          // Return an empty Container when the item does not exist.
          if (snapshot.data!.isEmpty) {
            return Container();
          }
          final rowCrewmatesRecord = rowCrewmatesRecordList.isNotEmpty
              ? rowCrewmatesRecordList.first
              : null;
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<List<DecksRecord>>(
                stream: queryDecksRecord(
                  queryBuilder: (decksRecord) => decksRecord.where(
                    'crewmateId',
                    isEqualTo: rowCrewmatesRecord?.reference.id != ''
                        ? rowCrewmatesRecord?.reference.id
                        : null,
                  ),
                )..listen((snapshot) async {
                    List<DecksRecord> deckSelectDecksRecordList = snapshot;
                    if (_model.deckSelectPreviousSnapshot != null &&
                        !const ListEquality(DecksRecordDocumentEquality())
                            .equals(deckSelectDecksRecordList,
                                _model.deckSelectPreviousSnapshot)) {
                      logFirebaseEvent(
                          'DECK_SELECT_Deck_select_ON_DATA_CHANGE');
                      if ((int deckNumber) {
                        return deckNumber == 1 ? true : false;
                      }(widget.deckNumber!)) {
                        setState(() {
                          FFAppState().deck1Selected = false;
                        });
                      } else {
                        setState(() {
                          FFAppState().deck2Selected = false;
                        });
                      }

                      setState(() {});
                    }
                    _model.deckSelectPreviousSnapshot = snapshot;
                  }),
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
                  List<DecksRecord> deckSelectDecksRecordList = snapshot.data!;
                  return FlutterFlowDropDown<String>(
                    controller: _model.deckSelectValueController ??=
                        FormFieldController<String>(
                      _model.deckSelectValue ??=
                          (String initiallySelectedDeck) {
                        return initiallySelectedDeck == 'empty'
                            ? null
                            : initiallySelectedDeck;
                      }(widget.initiallySelectedDeck),
                    ),
                    options:
                        deckSelectDecksRecordList.map((e) => e.name).toList(),
                    onChanged: (val) async {
                      setState(() => _model.deckSelectValue = val);
                      logFirebaseEvent(
                          'DECK_SELECT_Deck_select_ON_FORM_WIDGET_S');
                      if ((int deckNumber) {
                        return deckNumber == 1 ? true : false;
                      }(widget.deckNumber!)) {
                        setState(() {
                          FFAppState().deck1Selected = true;
                        });
                      } else {
                        setState(() {
                          FFAppState().deck2Selected = true;
                        });
                      }
                    },
                    width: 300.0,
                    height: 50.0,
                    textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily: 'Noto Sans',
                          color: valueOrDefault<Color>(
                            (String initiallySelectedDeck) {
                              return initiallySelectedDeck != 'empty';
                            }(widget.initiallySelectedDeck)
                                ? Color(0xFFBDBDBD)
                                : FlutterFlowTheme.of(context).primary,
                            FlutterFlowTheme.of(context).primary,
                          ),
                          fontSize: 18.0,
                        ),
                    hintText: valueOrDefault<String>(
                      deckSelectDecksRecordList
                                  .map((e) => e.name)
                                  .toList()
                                  .length ==
                              0
                          ? valueOrDefault<String>(
                              (String languageCode) {
                                return languageCode == 'fr'
                                    ? 'Pas de deck, créez-en un (+) '
                                    : 'No deck, create one  (+)';
                              }(FFLocalizations.of(context).languageCode),
                              'No deck, create one  (+)',
                            )
                          : valueOrDefault<String>(
                              (String languageCode) {
                                return languageCode == 'fr'
                                    ? 'Sélectionnez un deck'
                                    : 'Select a deck';
                              }(FFLocalizations.of(context).languageCode),
                              'Select a deck',
                            ),
                      'Select a deck',
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24.0,
                    ),
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    elevation: 2.0,
                    borderColor: FlutterFlowTheme.of(context).primaryBackground,
                    borderWidth: 2.0,
                    borderRadius: 8.0,
                    margin:
                        EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                    hidesUnderline: true,
                    disabled: widget.initiallySelectedDeck != 'empty',
                    isSearchable: false,
                    isMultiSelect: false,
                  );
                },
              ),
              if (widget.initiallySelectedDeck == 'empty')
                Builder(
                  builder: (context) => Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        Icons.add,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        logFirebaseEvent('DECK_SELECT_COMP_add_ICN_ON_TAP');
                        await showAlignedDialog(
                          context: context,
                          isGlobal: true,
                          avoidOverflow: false,
                          targetAnchor: AlignmentDirectional(0.0, 0.0)
                              .resolve(Directionality.of(context)),
                          followerAnchor: AlignmentDirectional(0.0, 0.0)
                              .resolve(Directionality.of(context)),
                          builder: (dialogContext) {
                            return Material(
                              color: Colors.transparent,
                              child: DeckFormWidget(),
                            );
                          },
                        ).then((value) => setState(() {}));
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
