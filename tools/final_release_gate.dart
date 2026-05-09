import 'dart:convert';
import 'dart:io';

Future<String> _runCmd(List<String> cmd) async {
  final result = await Process.run(cmd.first, cmd.sublist(1), runInShell: true);
  return result.exitCode == 0 ? 'PASS' : 'FAIL';
}

Future<String> _runJsonCmd(List<String> cmd) async {
  final result = await Process.run(cmd.first, cmd.sublist(1), runInShell: true);
  if (result.exitCode != 0) {
    return 'FAIL';
  }
  try {
    jsonDecode(result.stdout.toString());
    return 'PASS';
  } catch (_) {
    return 'FAIL';
  }
}

String _checkDesignTokens() {
  final files = [
    'lib/ui_v2/design/design_tokens.dart',
    'lib/ui_v2/design/design_layout.dart',
    'lib/ui_v2/design/design_containers.dart',
    'lib/ui_v2/design/design_typography.dart',
    'lib/ui_v2/design/design_interactions.dart',
  ];
  for (final file in files) {
    if (!File(file).existsSync()) {
      return 'FAIL';
    }
  }
  return 'PASS';
}

Future<void> main(List<String> args) async {
  stdout.writeln('FINAL-RELEASE-GATE');
  final analyzer = await _runCmd(['flutter', 'analyze']);
  final tests = await _runCmd(['dart', 'test', '-r', 'expanded']);
  final regression = await _runCmd([
    'dart',
    'run',
    'tools/regression_gate.dart',
  ]);
  final snapshot = await _runCmd([
    'dart',
    'run',
    'tools/regression_snapshot.dart',
    'compare',
  ]);
  final content = await _runCmd([
    'dart',
    'run',
    'tools/content_cohesion_check.dart',
  ]);
  final persona = await _runJsonCmd([
    'dart',
    'run',
    'tools/persona_advice_api.dart',
    'core:intro:001',
  ]);
  final design = _checkDesignTokens();

  print('FINAL-RELEASE-GATE:');
  print('analyzer: $analyzer');
  print('tests: $tests');
  print('regression: $regression');
  print('snapshot: $snapshot');
  print('content: $content');
  print('persona: $persona');
  print('design: $design');

  if ([
    analyzer,
    tests,
    regression,
    snapshot,
    content,
    persona,
    design,
  ].every((status) => status == 'PASS')) {
    exit(0);
  }
  exit(1);
}
