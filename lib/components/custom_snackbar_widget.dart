import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'custom_snackbar_model.dart';
export 'custom_snackbar_model.dart';

class CustomSnackbarWidget extends StatefulWidget {
  const CustomSnackbarWidget({
    Key? key,
    String? message,
  })  : this.message = message ?? 'No message',
        super(key: key);

  final String message;

  @override
  _CustomSnackbarWidgetState createState() => _CustomSnackbarWidgetState();
}

class _CustomSnackbarWidgetState extends State<CustomSnackbarWidget>
    with TickerProviderStateMixin {
  late CustomSnackbarModel _model;

  final animationsMap = {
    'containerOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: Offset(0.0, 100.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
  };

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomSnackbarModel());

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
      height: 60.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).tertiary,
      ),
      alignment: AlignmentDirectional(-1.00, 0.00),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
        child: Text(
          widget.message,
          textAlign: TextAlign.start,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Noto Sans',
                color: FlutterFlowTheme.of(context).primary,
                fontSize: 16.0,
              ),
        ),
      ),
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!);
  }
}
