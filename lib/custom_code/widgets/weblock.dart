// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// made by bulgariamitko v0.1

import 'package:wakelock/wakelock.dart';

class Weblock extends StatefulWidget {
  const Weblock({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _WeblockState createState() => _WeblockState();
}

class _WeblockState extends State<Weblock> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Spacer(
            flex: 3,
          ),
          OutlinedButton(
            onPressed: () {
              // The following code will enable the wakelock on the device
              // using the wakelock plugin.
              setState(() {
                Wakelock.enable();
                // You could also use Wakelock.toggle(on: true);
              });
            },
            child: const Text('enable wakelock'),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {
              // The following code will disable the wakelock on the device
              // using the wakelock plugin.
              setState(() {
                Wakelock.disable();
                // You could also use Wakelock.toggle(on: false);
              });
            },
            child: const Text('disable wakelock'),
          ),
          const Spacer(
            flex: 2,
          ),
          FutureBuilder(
            future: Wakelock.enabled,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              final data = snapshot.data;
              // The use of FutureBuilder is necessary here to await the
              // bool value from the `enabled` getter.
              print(data);
              if (data == null) {
                // The Future is retrieved so fast that you will not be able
                // to see any loading indicator.
                return Container();
              }

              return Text('The wakelock is currently '
                  '${data ? 'enabled' : 'disabled'}.');
            },
          ),
          const Spacer(
            flex: 3,
          ),
        ],
      ),
    );
  }
}
