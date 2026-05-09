import 'dart:convert';
import 'dart:io';

Future<int?> _readiness(String moduleId) async {
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

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/transfer_score_engine.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final readiness = await _readiness(moduleId);
  if (readiness == null) {
    stderr.writeln('Unable to compute readiness for $moduleId');
    exit(1);
  }

  final metadataFile = File('content/$moduleId/metadata.json');
  if (!metadataFile.existsSync()) {
    stderr.writeln('metadata.json missing for $moduleId');
    exit(1);
  }

  final json =
      jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>;
  final next = json['next'] as String?;
  final theme = json['theme'] as String?;
  final difficulty = json['difficulty'] as String?;
  final links = json['links'] as Map<String, dynamic>?;
  final scenario = json['scenario'] as Map<String, dynamic>?;

  if (next == null || next.isEmpty) {
    print('Transfer: NONE');
    exit(0);
  }

  var score = 0;
  if (readiness >= 80) score += 30;
  if (links != null &&
      links.keys.toSet().containsAll({
        'recap_to_quiz',
        'quiz_to_drills',
        'drills_to_demos',
        'demos_to_checkpoint',
      })) {
    score += 20;
  }
  if (scenario != null &&
      scenario.containsKey('setup') &&
      scenario.containsKey('problem') &&
      scenario.containsKey('insight') &&
      scenario.containsKey('transition')) {
    score += 20;
  }
  if (difficulty != 'intro') {
    score += 20;
  }
  if (theme == 'advanced') {
    score += 10;
  }

  score = score.clamp(0, 100);

  print('Transfer $moduleId → $next: $score/100');
  if (score < 50) {
    print('Status: WEAK');
  } else if (score < 80) {
    print('Status: MODERATE');
  } else {
    print('Status: STRONG');
  }
  exit(0);
}
