import 'dart:io';

Future<int?> _runReadiness(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/module_readiness_engine.dart',
    moduleId,
  ], runInShell: true);
  for (final line in result.stdout.toString().split('\n')) {
    if (line.startsWith('Readiness')) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        final scorePart = parts[1].trim().split('/').first;
        final value = int.tryParse(scorePart);
        if (value != null) return value;
      }
    }
  }
  return null;
}

Future<String?> _runNext(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/next_module_advisor.dart',
    moduleId,
  ], runInShell: true);
  for (final line in result.stdout.toString().split('\n')) {
    if (line.startsWith('Next:')) {
      return line.split(':').last.trim();
    }
  }
  return null;
}

Future<String?> _runDifficulty(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/difficulty_shaper.dart',
    moduleId,
  ], runInShell: true);
  for (final line in result.stdout.toString().split('\n')) {
    if (line.startsWith('Difficulty:')) {
      return line.split(':').last.trim();
    }
  }
  return null;
}

Future<Map<String, String>?> _runTransfer(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/transfer_score_engine.dart',
    moduleId,
  ], runInShell: true);
  final lines = result.stdout.toString().split('\n');
  String? scoreLine;
  String? status;
  String? nextLine;
  for (final line in lines) {
    if (line.startsWith('Transfer')) {
      scoreLine = line;
    } else if (line.startsWith('Status:')) {
      status = line.split(':').last.trim();
    }
  }
  if (scoreLine == null) return null;
  final scorePart = scoreLine.split(':').last.trim().split('/').first;
  final scoreValue = int.tryParse(scorePart);
  final nextId = scoreLine.split('→').last.split(':').first.trim();
  return {
    'score': scoreValue?.toString() ?? '0',
    'status': status ?? 'MODERATE',
    'next': nextId,
  };
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/learning_path_planner_v2.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final readiness = await _runReadiness(moduleId);
  if (readiness == null) {
    stderr.writeln('Unable to compute readiness');
    exit(1);
  }

  final next = await _runNext(moduleId) ?? 'NONE';
  final difficulty = await _runDifficulty(moduleId) ?? 'SAME';
  final transfer = await _runTransfer(moduleId);
  final transferScore = transfer != null
      ? int.tryParse(transfer['score'] ?? '') ?? 0
      : 0;
  final transferStatus = transfer != null
      ? transfer['status'] ?? 'MODERATE'
      : 'MODERATE';

  if (next.startsWith('REPEAT') || readiness < 60) {
    print('Plan:');
    print('- Remediate current module');
    print('- Focus: recap, drill #1, demo walkthrough');
    print('- Difficulty: LOWER');
    print('- Next: REPEAT');
    return;
  }

  if (next == 'NONE') {
    print('Plan:');
    print('- Complete current module (final node)');
    print('- Difficulty: SAME');
    print('- Next: NONE');
    return;
  }

  print('Plan:');
  print('- Current readiness: $readiness');
  print('- Difficulty suggestion: $difficulty');
  print('- Transfer strength: $transferStatus');
  print('- Recommended next module: $next');
  if (transferScore < 50) {
    print('- Suggested focus: Reinforce drills + scenario insight');
  } else if (transferScore < 80) {
    print('- Suggested focus: Review examples + attempt timed quiz');
  } else {
    print('- Suggested focus: Proceed normally with confidence');
  }
}
