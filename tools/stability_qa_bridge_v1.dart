import 'dart:io';

import 'package:poker_analyzer/ui_v2/theme_v3/qa/qa_motion_v3.dart';
import 'package:poker_analyzer/ui_v2/theme_v3/qa/visual_diagnostics_hub_v3.dart';
import 'package:poker_analyzer/ui_v2/theme_v3/visual_style_orchestrator_v3.dart';

void main() {
  _runAllowlistValidator();
  _printSection('ALLOWLIST QA', 'Allowlist validator executed.');
  _runSemanticValidator();
  _printSection('SEMANTIC QA', 'Semantic token validator executed.');

  final hub = VisualDiagnosticsHubV3();
  hub.initialize();
  final visualReport = hub.runFullDiagnostics();
  _printSection('VISUAL DIAGNOSTICS', visualReport);

  final resolverReport = runFullResolverQA();
  _printSection('RESOLVER QA', resolverReport);
  if (resolverReport.contains('FAIL')) {
    exit(2);
  }

  const motionQA = QAMotionV3();
  motionQA.validate();
  final motionReport = motionQA.report();
  _printSection('MOTION QA', motionReport);
  if (motionReport.contains('FAIL')) {
    exit(2);
  }
}

void _runAllowlistValidator() {
  print('Allowlist validator not available in this branch.');
}

void _runSemanticValidator() {
  print('Semantic token validator not available in this branch.');
}

void _printSection(String name, String output) {
  print('=== $name ===');
  print(output);
  print('----------------------');
}
