import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:poker_analyzer/firebase_options.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_settings_quiet_control_v1.dart';
export 'package:poker_analyzer/app/runtime_surface.dart' show appRoot;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore feedback gates before the first learner interaction.
  if (kAct0SettingsQuietControlPreviewV1) {
    await AppSettingsService.instance.load();
  }
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
