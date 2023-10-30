// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<String> createsMatchupid(
  String deckId1,
  String deckId2,
) async {
  List<String> deckIds = [deckId1, deckId2];
  deckIds.sort();
  //List<String> shorterDeckIds =
  //deckIds.map((item) => item.substring(0, 10)).toList();
  String sortedConcatenatedDeckIds = deckIds.join('');
  return sortedConcatenatedDeckIds;
}
