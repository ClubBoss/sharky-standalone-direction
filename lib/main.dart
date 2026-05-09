import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:poker_analyzer/firebase_options.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
export 'package:poker_analyzer/app/runtime_surface.dart' show appRoot;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await _initFirebaseIfAvailable();
  runApp(AppRoot());
}

/*
Future<void> _initFirebaseIfAvailable() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization skipped: $error');
  }
}
*/
