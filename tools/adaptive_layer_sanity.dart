import 'dart:convert';
import 'dart:io';

Future<bool> _runAndCheck(List<String> command, String expect) async {
  final result = await Process.run(
    command.first,
    command.sublist(1),
    runInShell: true,
  );
  if (result.exitCode != 0) {
    return false;
  }
  final output = result.stdout.toString();
  if (expect == 'json') {
    try {
      jsonDecode(output);
      return true;
    } catch (_) {
      return false;
    }
  }
  return output.contains(expect);
}

Future<void> main(List<String> args) async {
  const moduleId = 'core:intro:001';
  final checks = <String, bool>{
    'readiness': await _runAndCheck([
      'dart',
      'run',
      'tools/module_readiness_engine.dart',
      moduleId,
    ], 'Readiness'),
    'advisor': await _runAndCheck([
      'dart',
      'run',
      'tools/next_module_advisor.dart',
      moduleId,
    ], 'Next:'),
    'difficulty': await _runAndCheck([
      'dart',
      'run',
      'tools/difficulty_shaper.dart',
      moduleId,
    ], 'Difficulty:'),
    'transfer': await _runAndCheck([
      'dart',
      'run',
      'tools/transfer_score_engine.dart',
      moduleId,
    ], 'Transfer'),
    'planner': await _runAndCheck([
      'dart',
      'run',
      'tools/learning_path_planner_v2.dart',
      moduleId,
    ], 'Plan:'),
    'context': await _runAndCheck([
      'dart',
      'run',
      'tools/persona_context_bridge.dart',
      moduleId,
    ], 'json'),
    'advice': await _runAndCheck([
      'dart',
      'run',
      'tools/persona_advice_api.dart',
      moduleId,
    ], 'json'),
  };

  print('ADAPTIVE:');
  checks.forEach((key, value) {
    print('$key: ${value ? 'PASS' : 'FAIL'}');
  });

  if (checks.values.every((v) => v)) {
    exit(0);
  }
  exit(1);
}
