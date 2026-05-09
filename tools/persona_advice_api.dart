import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> _loadContext(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/persona_context_bridge.dart',
    moduleId,
  ], runInShell: true);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(1);
  }
  return jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
}

Future<String?> _runCli(String moduleId, String tool, String prefix) async {
  final result = await Process.run('dart', [
    'run',
    'tools/$tool.dart',
    moduleId,
  ], runInShell: true);
  for (final line in result.stdout.toString().split('\n')) {
    if (line.startsWith(prefix)) {
      return line.split(':').last.trim();
    }
  }
  return null;
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tools/persona_advice_api.dart <moduleId>');
    exit(1);
  }

  final moduleId = args.first;
  final context = await _loadContext(moduleId);

  final message = await _runCli(moduleId, 'persona_dynamic_message', 'Message');
  final coach = await _runCli(moduleId, 'persona_difficulty_coach', 'Coach');
  final nav = await _runCli(moduleId, 'persona_navigation_coach', 'Nav');
  final reflection = await _runCli(
    moduleId,
    'persona_session_reflection',
    'Reflect',
  );

  final payload = {
    'moduleId': moduleId,
    'readiness': context['readiness'],
    'difficulty': context['difficulty'],
    'next': context['next'],
    'transferScore': context['transferScore'],
    'transferStatus': context['transferStatus'],
    'theme': context['theme'],
    'moduleDifficulty': context['moduleDifficulty'],
    'hasScenario': context['hasScenario'],
    'hasLinks': context['hasLinks'],
    'message': message,
    'coach': coach,
    'nav': nav,
    'reflection': reflection,
  };

  print(jsonEncode(payload));
}
