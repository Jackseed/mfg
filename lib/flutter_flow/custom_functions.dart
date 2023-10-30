import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

dynamic replaceNullValues(dynamic jsonResult) {
  if (jsonResult == null) {
    // Return a JSON response with an empty array
    return {'data': []};
  } else {
    return jsonResult;
  }
}

String colorBooleansToString(
  bool isBlack,
  bool isBlue,
  bool isGreen,
  bool isWhite,
  bool isRed,
) {
  String res = '';

  if (isBlack) res = res + 'b';
  if (isBlue) res = res + 'u';
  if (isWhite) res = res + 'w';
  if (isGreen) res = res + 'g';
  if (isRed) res = res + 'r';

  // Convert the string into a list of characters
  List<String> resList = res.split('');

  // Sort the list of characters in alphabetical order
  resList.sort();

  // Join the sorted characters back into a new string
  String sortedRes = resList.join();

  return sortedRes;
}

List<String> booleansToArray(
  bool isBlack,
  bool isBlue,
  bool isGreen,
  bool isWhite,
  bool isRed,
) {
  List<String> res = [];

  if (isBlack) res.add('Black');
  if (isBlue) res.add('Blue');
  if (isWhite) res.add('White');
  if (isGreen) res.add('Green');
  if (isRed) res.add('Red');

  return res;
}

List<String> fromDeckNamesToIds(
  List<String>? deckNames,
  List<DecksRecord>? decks,
) {
  // deckNames or decks null return empty array
  if (deckNames == null || decks == null) {
    return [];
  }
  // map names to deckIds
  final Map<String, String> nameToId = {};
  for (final deck in decks) {
    nameToId[deck.name] = deck.deckId;
  }
  final List<String> deckIds = [];
  for (final name in deckNames) {
    final id = nameToId[name];
    if (id != null) {
      deckIds.add(id);
    }
  }
  return deckIds;
}

DateTime getTodayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime getDayAfterDate(DateTime date) {
  final gameDate = DateTime(date.year, date.month, date.day);
  final DateTime tomorrow = gameDate.add(Duration(days: 1));
  final DateTime dayAfter =
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

  return dayAfter;
}

DocumentReference fromCrewIdToRef(String docId) {
// return docRef based on docId
  return FirebaseFirestore.instance.collection('crews').doc(docId);
}
