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

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/persona_difficulty_coach.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final context = await _loadContext(moduleId);

  final next = context['next'] as String? ?? 'NONE';
  final difficulty = context['difficulty'] as String? ?? 'SAME';
  final transferStatus = context['transferStatus'] as String? ?? 'MODERATE';

  if (next.startsWith('REPEAT')) {
    print('Coach: reinforce');
    return;
  }
  if (difficulty == 'LOWER') {
    print('Coach: reinforce');
    return;
  }
  if (transferStatus == 'WEAK') {
    print('Coach: reinforce');
    return;
  }
  if (difficulty == 'HIGHER' || transferStatus == 'STRONG') {
    print('Coach: challenge');
    return;
  }

  print('Coach: steady');
}
