import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/tools/v4_persona_mat_consistency_qa.dart'
    as tool;

Future<int> runV4PersonaMatConsistencyQA() async => 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final code = await tool.runV4PersonaMatConsistencyQA();
  if (code != 0) exit(code);
}
