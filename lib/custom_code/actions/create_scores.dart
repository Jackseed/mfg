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

Future<List<ScoreStruct>> createScores(
  String deckId1,
  int score1,
  String deckId2,
  int score2,
) async {
  // create scores object with deckId and score fields
  List<ScoreStruct> scores = [];
  CollectionReference collection =
      FirebaseFirestore.instance.collection('decks');

  DocumentReference deck1Ref = collection.doc(deckId1);
  ScoreStruct score1Obj =
      ScoreStruct(deckId: deckId1, deckRef: deck1Ref, score: score1);

  DocumentReference deck2Ref = collection.doc(deckId2);
  ScoreStruct score2Obj =
      ScoreStruct(deckId: deckId2, deckRef: deck2Ref, score: score2);

  scores.add(score1Obj);
  scores.add(score2Obj);

  scores.sort((a, b) =>
      b.score.compareTo(a.score)); // Sort in descending order by score

  return scores;
}
