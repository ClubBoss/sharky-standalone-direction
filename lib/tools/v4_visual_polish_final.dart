import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/tools/v4_visual_polish_final.dart' as tool;

Future<int> runV4VisualPolishFinal() async => 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final code = await tool.runV4VisualPolishFinal();
  if (code != 0) exit(code);
}
