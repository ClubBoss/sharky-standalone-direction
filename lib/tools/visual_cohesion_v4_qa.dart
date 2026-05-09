import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/tools/visual_cohesion_v4_qa.dart' as tool;

Future<int> runV4CohesionQA() async => 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final code = await tool.runV4CohesionQA();
  if (code != 0) exit(code);
}
