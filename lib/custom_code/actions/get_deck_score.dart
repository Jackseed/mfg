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
  int matchWins = 0;
  int matchLosses = 0;

  for (final doc in querySnapshot.docs) {
    final matchup = doc.data();
    final rawScores = matchup['scores'];
    if (rawScores == null || rawScores is! List) continue;

    final scores = (rawScores as List<dynamic>)
        .map((score) =>
            ScoreStruct(deckId: score['deckId'], score: score['score']))
        .toList();

    int myGameScore = 0;
    int oppGameScore = 0;

    for (final score in scores) {
      if (score.deckId == deckId) {
        myGameScore = score.score;
        wins += score.score;
      } else {
        oppGameScore += score.score;
        losses += score.score;
      }
    }

    // Determine BO3 match outcome
    if (myGameScore > oppGameScore) {
      matchWins++;
    } else if (myGameScore < oppGameScore) {
      matchLosses++;
    }
    // Equal scores = draw, not counted as win or loss
  }

  final totalGames = wins + losses;
  final winrate = totalGames > 0 ? wins / totalGames.toDouble() : 0.0;

  return DeckScoreStruct(
    wins: wins,
    losses: losses,
    winrate: winrate,
    matchWins: matchWins,
    matchLosses: matchLosses,
  );
}
