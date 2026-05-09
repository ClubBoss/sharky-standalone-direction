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

Future<String?> _loadCoach(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/persona_difficulty_coach.dart',
    moduleId,
  ], runInShell: true);
  for (final line in result.stdout.toString().split('\n')) {
    if (line.startsWith('Coach:')) {
      return line.split(':').last.trim();
    }
  }
  return null;
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/persona_navigation_coach.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final context = await _loadContext(moduleId);
  final coach = await _loadCoach(moduleId) ?? 'steady';

  final next = context['next'] as String? ?? 'NONE';
  final difficulty = context['difficulty'] as String? ?? 'SAME';
  final transferStatus = context['transferStatus'] as String? ?? 'MODERATE';

  if (next.startsWith('REPEAT')) {
    print('Nav: repeat');
    return;
  }
  if (coach == 'reinforce' || next == 'NONE') {
    print('Nav: stay');
    return;
  }
  if (coach == 'challenge' && transferStatus == 'STRONG') {
    print('Nav: accelerate');
    return;
  }
  if (difficulty == 'HIGHER') {
    print('Nav: advance');
    return;
  }
  print('Nav: advance');
}
