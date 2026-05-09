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
  String? scoreLine;
  String? status;
  for (final line in result.stdout.toString().split('\n')) {
    if (line.startsWith('Transfer')) {
      scoreLine = line;
    } else if (line.startsWith('Status:')) {
      status = line.split(':').last.trim();
    }
  }
  if (scoreLine == null) return null;
  final parts = scoreLine.split(':');
  if (parts.length < 2) return null;
  final scorePart = parts[1].trim().split('/').first;
  final transferParts = scoreLine.split('→');
  final nextId = transferParts.length > 1
      ? transferParts[1].split(':').first.trim()
      : 'NONE';
  return {
    'score': int.tryParse(scorePart)?.toString() ?? '0',
    'status': status ?? 'MODERATE',
    'next': nextId,
  };
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/persona_context_bridge.dart <moduleId>',
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

  final metadataFile = File('content/$moduleId/metadata.json');
  final metadataExists = metadataFile.existsSync();
  final metadata = metadataExists
      ? jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};

  final theme = metadata['theme'] as String?;
  final moduleDifficulty = metadata['difficulty'] as String?;
  final hasScenario = metadata.containsKey('scenario');
  final hasLinks = metadata.containsKey('links');

  final payload = {
    'moduleId': moduleId,
    'readiness': readiness,
    'difficulty': difficulty,
    'next': next,
    'transferScore': transferScore,
    'transferStatus': transferStatus,
    'theme': theme,
    'moduleDifficulty': moduleDifficulty,
    'hasScenario': hasScenario,
    'hasLinks': hasLinks,
  };

  print(jsonEncode(payload));
}
