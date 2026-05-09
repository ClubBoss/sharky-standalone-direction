import 'dart:convert';
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
        final score = parts[1].trim().split('/').first;
        final value = int.tryParse(score);
        if (value != null) return value;
      }
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

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/adaptive_hint_engine.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final readiness = await _runReadiness(moduleId);
  if (readiness == null) {
    stderr.writeln('Unable to compute readiness');
    exit(1);
  }

  final difficulty = await _runDifficulty(moduleId) ?? 'SAME';

  final metadataFile = File('content/$moduleId/metadata.json');
  final theme = metadataFile.existsSync()
      ? (jsonDecode(metadataFile.readAsStringSync())
                as Map<String, dynamic>)['theme']
            as String?
      : null;
  final moduleDifficulty = metadataFile.existsSync()
      ? (jsonDecode(metadataFile.readAsStringSync())
                as Map<String, dynamic>)['difficulty']
            as String?
      : 'core';

  if (readiness < 60) {
    print('Hint: Focus on fundamentals. Revisit recap and the first drill.');
    return;
  }

  if (difficulty == 'LOWER') {
    print('Hint: Slow down. Work through the demo example again.');
    return;
  }

  if (difficulty == 'HIGHER') {
    print('Hint: Try a harder drill variant or a timed quiz iteration.');
    return;
  }

  if (difficulty == 'SAME') {
    if (theme == 'advanced' || moduleDifficulty == 'advanced') {
      print('Hint: Analyze the scenario insight and compare to your own play.');
      return;
    }
    print('Hint: Review the key examples and check your reasoning.');
  }
}
