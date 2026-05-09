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
      final parts = line.split(':');
      if (parts.length >= 2) {
        final scorePart = parts[1].trim().split('/').first;
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
    stderr.writeln('Usage: dart run tools/next_module_advisor.dart <moduleId>');
    exit(1);
  }

  final moduleId = args.first;
  final score = await _runReadiness(moduleId);
  if (score == null) {
    stderr.writeln('Unable to determine readiness for $moduleId');
    exit(1);
  }

  if (score < 80) {
    print('Next: REPEAT $moduleId');
    exit(0);
  }

  final metadataFile = File('content/$moduleId/metadata.json');
  if (!metadataFile.existsSync()) {
    stderr.writeln('metadata.json missing for $moduleId');
    exit(1);
  }

  final metadata = metadataFile.readAsStringSync();
  final json = metadata.isEmpty
      ? <String, dynamic>{}
      : jsonDecode(metadata) as Map<String, dynamic>;

  final next = json['next'] as String?;
  final difficulty = json['difficulty'] as String?;

  if (next != null && next.isNotEmpty) {
    print('Next: $next');
    exit(0);
  }

  if (difficulty == 'intro') {
    print('Next: NONE (end of intro series)');
    exit(0);
  }

  print('Next: NONE');
  exit(0);
}
