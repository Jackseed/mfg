import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAbKX_094_K985Wm-Gllvcassz9YiVzUeE",
            authDomain: "mtgf-cc634.firebaseapp.com",
            projectId: "mtgf-cc634",
            storageBucket: "mtgf-cc634.appspot.com",
            messagingSenderId: "114414332355",
            appId: "1:114414332355:web:e8d3b9c717399e7959f576"));
  } else {
    await Firebase.initializeApp();
  }
}
