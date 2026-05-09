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

Future<String?> _runCoach(String moduleId) async {
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

Future<String?> _runNavigation(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/persona_navigation_coach.dart',
    moduleId,
  ], runInShell: true);
  for (final line in result.stdout.toString().split('\n')) {
    if (line.startsWith('Nav:')) {
      return line.split(':').last.trim();
    }
  }
  return null;
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/persona_session_reflection.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final context = await _loadContext(moduleId);
  final coach = await _runCoach(moduleId) ?? 'steady';
  final navigation = await _runNavigation(moduleId) ?? 'advance';

  final next = context['next'] as String? ?? 'NONE';
  final transferStatus = context['transferStatus'] as String? ?? 'MODERATE';

  if (next.startsWith('REPEAT')) {
    print('Reflect: remediation');
    return;
  }
  if (coach == 'reinforce') {
    print('Reflect: fundamentals');
    return;
  }
  if (navigation == 'accelerate') {
    print('Reflect: mastery');
    return;
  }
  if (transferStatus == 'STRONG') {
    print('Reflect: strong_transfer');
    return;
  }
  if (transferStatus == 'WEAK') {
    print('Reflect: weak_transfer');
    return;
  }

  print('Reflect: steady_progress');
}
