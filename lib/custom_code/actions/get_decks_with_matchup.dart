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

Future<List<DecksRecord>?> getDecksWithMatchup() async {
  //final QuerySnapshot matchupsSnapshot =
  //   await FirebaseFirestore.instance.collection('matchups').get();

  //Set<String> deckIds = {};
  //for (var matchupDoc in matchupsSnapshot.docs) {
  //List<String> ids = List.from(matchupDoc['deckIds']);
  //deckIds.addAll(ids);
  //}

  //final QuerySnapshot decksSnapshot = await FirebaseFirestore.instance
  //  .collection('decks')
  //.where('deckId', whereIn: deckIds.toList())
  // .get();

  // List<DecksRecord> decksIncludedInMatchups = decksSnapshot.docs.map((deckDoc) {
  // final deck = deckDoc.data();
  // if (deck != null) return DecksStruct(name: deck['name']);
  //return;
  // }).toList();

  //return decksIncludedInMatchups.length > 0 ? decksIncludedInMatchups : null;
//
}
