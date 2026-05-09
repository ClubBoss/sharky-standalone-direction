import 'dart:convert';
import 'dart:io';

Future<int?> _runReadiness(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/module_readiness_engine.dart',
    moduleId,
  ], runInShell: true);
  final output = result.stdout.toString().split('\n');
  for (final line in output) {
    if (line.startsWith('Readiness')) {
      final segments = line.split(':');
      if (segments.length >= 2) {
        final scorePart = segments[1].trim().split('/').first;
        final value = int.tryParse(scorePart);
        if (value != null) {
          return value;
        }
      }
    }
  }
  return null;
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tools/difficulty_shaper.dart <moduleId>');
    exit(1);
  }

  final moduleId = args.first;
  final readiness = await _runReadiness(moduleId);
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
  final difficulty = json['difficulty'] as String?;
  final theme = json['theme'] as String?;

  String thresholdDifficulty() {
    if (readiness < 60) return 'LOWER';
    if (readiness < 90) return 'SAME';
    return 'HIGHER';
  }

  var suggestion = thresholdDifficulty();

  if (difficulty == 'intro' && readiness >= 90) {
    suggestion = 'SAME';
  }
  if (theme == 'advanced' && readiness < 60) {
    suggestion = 'SAME';
  }

  print('Difficulty: $suggestion');
  exit(0);
}
