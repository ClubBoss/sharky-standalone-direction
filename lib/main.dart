import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
export 'package:poker_analyzer/app/runtime_surface.dart' show appRoot;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppRoot());
}
