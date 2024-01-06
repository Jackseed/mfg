import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/small_components/crewmate_select/crewmate_select_widget.dart';
import '/small_components/deck_select/deck_select_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'player_form_model.dart';
export 'player_form_model.dart';

class PlayerFormWidget extends StatefulWidget {
  const PlayerFormWidget({
    Key? key,
    this.crewmateList,
    String? formTitle,
    required this.deckNumber,
    String? playerName,
    String? deckName,
    required this.playerNameToRemoveFromList,
  })  : this.formTitle = formTitle ?? '\"\"',
        this.playerName = playerName ?? 'empty',
        this.deckName = deckName ?? 'empty',
        super(key: key);

  final List<String>? crewmateList;
  final String formTitle;
  final int? deckNumber;
  final String playerName;
  final String deckName;
  final String? playerNameToRemoveFromList;

  @override
  _PlayerFormWidgetState createState() => _PlayerFormWidgetState();
}

class _PlayerFormWidgetState extends State<PlayerFormWidget> {
  late PlayerFormModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlayerFormModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('PLAYER_FORM_PlayerForm_ON_INIT_STATE');
      if (widget.deckName != 'empty') {
        if ((int deckNumber) {
          return deckNumber == 1 ? true : false;
        }(widget.deckNumber!)) {
          logFirebaseEvent('PlayerForm_update_app_state');
          setState(() {
            FFAppState().deck1Selected = true;
          });
        } else {
          logFirebaseEvent('PlayerForm_update_app_state');
          setState(() {
            FFAppState().deck2Selected = true;
          });
        }
      }
    });

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

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.45,
        ),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: Stack(
                alignment: AlignmentDirectional(0.0, 0.0),
                children: [
                  SvgPicture.asset(
                    'assets/images/Vector_(1).svg',
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    fit: BoxFit.fitHeight,
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Text(
                      widget.formTitle,
                      textAlign: TextAlign.start,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Noto Sans',
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 32.0,
                                fontWeight: FontWeight.normal,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
              child: wrapWithModel(
                model: _model.crewmateSelectModel,
                updateCallback: () => setState(() {}),
                updateOnChange: true,
                child: CrewmateSelectWidget(
                  selectedPlayer: widget.playerName,
                  playerList: widget.crewmateList,
                  playerToRemoveFromList: widget.playerNameToRemoveFromList!,
                ),
              ),
            ),
            wrapWithModel(
              model: _model.deckSelectModel,
              updateCallback: () => setState(() {}),
              updateOnChange: true,
              child: DeckSelectWidget(
                deckOwnerName: (String initallySelectedPlayerName) {
                  return initallySelectedPlayerName == 'empty';
                }(widget.playerName)
                    ? _model.crewmateSelectModel.playerSelectValue
                    : widget.playerName,
                deckNumber: widget.deckNumber!,
                initiallySelectedDeck: widget.deckName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
