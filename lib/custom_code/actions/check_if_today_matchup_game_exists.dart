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

import 'package:cloud_firestore/cloud_firestore.dart';

// Define the function
Future<bool> checkIfTodayMatchupGameExists(String matchupId) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Get the Firestore instance
  final firestoreInstance = FirebaseFirestore.instance;

  // Get the collection reference for the matchups collection
  final matchupsCollection = firestoreInstance.collection('games');

  // Query the collection for a document with the given matchupId
  final querySnapshot = await matchupsCollection
      .where('matchupId', isEqualTo: matchupId)
      .where('date', isGreaterThanOrEqualTo: today)
      .get();

  // Check if any documents were found
  return querySnapshot.docs.isNotEmpty;
}
