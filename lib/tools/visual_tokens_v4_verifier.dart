import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/tools/visual_tokens_v4_verifier.dart' as tool;

Future<int> runV4VisualTokensVerification() async => 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final code = await tool.runV4VisualTokensVerification();
  if (code != 0) exit(code);
}
