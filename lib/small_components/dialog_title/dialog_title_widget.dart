import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dialog_title_model.dart';
export 'dialog_title_model.dart';

class DialogTitleWidget extends StatefulWidget {
  const DialogTitleWidget({
    Key? key,
    this.formTitle,
  }) : super(key: key);

  final String? formTitle;

  @override
  _DialogTitleWidgetState createState() => _DialogTitleWidgetState();
}

class _DialogTitleWidgetState extends State<DialogTitleWidget> {
  late DialogTitleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DialogTitleModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional(1.00, 0.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 0.0, 0.0),
              child: FlutterFlowIconButton(
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 48.0,
                icon: Icon(
                  Icons.close,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 28.0,
                ),
                onPressed: () async {
                  logFirebaseEvent('DIALOG_TITLE_COMP_close_ICN_ON_TAP');
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.00, 0.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
              child: Text(
                valueOrDefault<String>(
                  widget.formTitle,
                  '\"\"',
                ),
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Cinzel Decorative',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
