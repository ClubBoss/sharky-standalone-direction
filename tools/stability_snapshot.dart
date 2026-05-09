import 'dart:convert';
import 'dart:io';

Future<String> _runProcess(List<String> command) async {
  final result = await Process.run(
    command.first,
    command.sublist(1),
    runInShell: true,
  );
  return result.exitCode == 0 ? 'PASS' : 'FAIL';
}

Future<String> _checkPersona() async {
  final result = await Process.run('dart', [
    'run',
    'tools/persona_advice_api.dart',
    'core:intro:001',
  ], runInShell: true);
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
    'lib/ui_v2/design/design_typography.dart',
    'lib/ui_v2/design/design_containers.dart',
    'lib/ui_v2/design/design_interactions.dart',
  ];
  for (final path in files) {
    if (!File(path).existsSync()) {
      return 'FAIL';
    }
  }
  return 'PASS';
}

Future<void> main(List<String> args) async {
  final analyze = await _runProcess(['flutter', 'analyze']);
  final tests = await _runProcess(['dart', 'test', '--concurrency=1']);
  final persona = await _checkPersona();
  final tokens = _checkDesignTokens();

  print('SNAPSHOT:');
  print('analyze: $analyze');
  print('tests: $tests');
  print('persona_advice: $persona');
  print('design_tokens: $tokens');
}
