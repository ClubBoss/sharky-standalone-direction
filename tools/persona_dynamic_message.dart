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
      'Usage: dart run tools/persona_dynamic_message.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final context = await _loadContext(moduleId);

  final next = context['next'] as String? ?? 'NONE';
  final transferStatus = context['transferStatus'] as String? ?? 'MODERATE';
  final difficulty = context['difficulty'] as String? ?? 'SAME';
  final theme = context['theme'] as String?;

  String message;
  if (next.startsWith('REPEAT')) {
    message =
        "Let's reinforce this topic together — revisit the core example and try the first drill again.";
  } else if (transferStatus == 'WEAK') {
    message =
        "You're close — review the scenario insight and replay the demo to lock in the idea.";
  } else if (difficulty == 'LOWER') {
    message =
        "Slow and steady — practice the basics and focus on clean decision patterns.";
  } else if (difficulty == 'HIGHER') {
    message =
        "Great momentum — try a tougher quiz variant or a timed drill to push your edge.";
  } else if (theme == 'advanced') {
    message =
        "Analyze the strategic layer — compare the scenario insight with your own play patterns.";
  } else {
    message = "Review the examples and keep building steady intuition.";
  }

  print('Message: $message');
}
