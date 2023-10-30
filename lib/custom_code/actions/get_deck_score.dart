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

Future<DeckScoreStruct> getDeckScore(String deckId) async {
  final matchupsCollection = FirebaseFirestore.instance.collection('matchups');
  final querySnapshot =
      await matchupsCollection.where('deckIds', arrayContains: deckId).get();

  int wins = 0;
  int losses = 0;

  for (final doc in querySnapshot.docs) {
    final matchup = doc.data();
    final scores = (matchup['scores'] as List<dynamic>)
        .map((score) =>
            ScoreStruct(deckId: score['deckId'], score: score['score']))
        .toList();

    for (final score in scores) {
      if (score.deckId == deckId) {
        wins += score.score;
      } else {
        losses += score.score;
      }
    }
  }
  final totalMatches = wins + losses;
  final winrate = totalMatches > 0 ? wins / totalMatches.toDouble() : 0.0;

  return DeckScoreStruct(wins: wins, losses: losses, winrate: winrate);
}
