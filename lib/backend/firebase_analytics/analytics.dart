import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import '../../auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';

const kMaxEventNameLength = 40;
const kMaxParameterLength = 100;

void logFirebaseEvent(String eventName, {Map<String?, dynamic>? parameters}) {
  // https://firebase.google.com/docs/reference/cpp/group/event-names
  assert(eventName.length <= kMaxEventNameLength);

  parameters ??= {};
  parameters.putIfAbsent(
      'user', () => currentUserUid.isEmpty ? currentUserUid : 'unset');
  parameters.removeWhere((k, v) => k == null || v == null);
  final params = <String, Object>{};
  for (final entry in parameters.entries) {
    if (entry.key == null || entry.value == null) continue;
    final key = entry.key!;
    if (entry.value is num) {
      params[key] = entry.value;
    } else {
      var valStr = entry.value.toString();
      if (valStr.length > kMaxParameterLength) {
        valStr = valStr.substring(0, min(valStr.length, kMaxParameterLength));
      }
      params[key] = valStr;
    }
  }

  FirebaseAnalytics.instance.logEvent(name: eventName, parameters: params);
}

void logFirebaseAuthEvent(User? user, String method) {
  final isSignup = user!.metadata.creationTime == user.metadata.lastSignInTime;
  final authEvent = isSignup ? 'sign_up' : 'login';
  logFirebaseEvent(authEvent, parameters: {'method': method});
}
