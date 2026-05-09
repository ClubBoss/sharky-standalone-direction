import 'dart:io';

import 'package:poker_analyzer/ui_v2/theme_v3/qa/visual_diagnostics_hub_v3.dart';

void main() {
  final hub = VisualDiagnosticsHubV3();
  hub.initialize();
  final report = hub.runGlobalVisualQA();
  print(report);
  if (report.contains('FAIL')) {
    exit(2);
  }
}
