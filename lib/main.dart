import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_release_support_v1.dart';
export 'package:poker_analyzer/app/runtime_surface.dart' show appRoot;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Owner decision 2026-11-26: portrait only, also in code (plist already).
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  Act0ReleaseSupportV1.observeErrors();
  runApp(AppRoot());
}
