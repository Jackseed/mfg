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

Future<List<ScoreStruct>> updateScores(
  String deckId1,
  int score1,
  String deckId2,
  int score2,
  List<ScoreStruct> existingScores,
) async {
  // Iterate over the existing scores array
  for (var score in existingScores) {
    String currentDeckId = score.deckId;

    // Check if the deck ID matches deckId1 or deckId2
    if (currentDeckId == deckId1) {
      // Update the score field for deckId1
      score.score = score.score + score1;
    } else if (currentDeckId == deckId2) {
      // Update the score field for deckId2
      score.score = score.score + score2;
    }
  }
  existingScores.sort((a, b) => b.score.compareTo(a.score));

  return existingScores;
}
