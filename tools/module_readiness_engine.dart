import 'dart:convert';
import 'dart:io';

bool _hasSemanticFiles(Directory dir) {
  for (final file in dir.listSync().whereType<File>()) {
    if (file.lengthSync() >= 300) {
      return true;
    }
  }
  return false;
}

bool _hasSemanticCheckpoints(Directory dir) {
  for (final file in dir.listSync().whereType<File>().where(
    (file) => file.path.endsWith('.md'),
  )) {
    if (file.lengthSync() >= 300) {
      return true;
    }
  }
  return false;
}

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/module_readiness_engine.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final moduleDir = Directory('content/$moduleId');
  if (!moduleDir.existsSync()) {
    stderr.writeln('Module directory missing');
    exit(1);
  }

  var score = 0;

  final recap = File('${moduleDir.path}/recap.md');
  if (recap.existsSync() && recap.readAsStringSync().length >= 300) {
    score += 20;
  }

  final quiz = File('${moduleDir.path}/quiz.jsonl');
  if (quiz.existsSync()) {
    final lines = quiz
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .toList();
    var valid = 0;
    for (final line in lines) {
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map) valid++;
      } catch (_) {}
    }
    if (valid >= 5) score += 20;
  }

  final drillsDir = Directory('${moduleDir.path}/drills');
  if (drillsDir.existsSync() && _hasSemanticFiles(drillsDir)) {
    score += 20;
  }

  final demosDir = Directory('${moduleDir.path}/demos');
  if (demosDir.existsSync() && _hasSemanticFiles(demosDir)) {
    score += 20;
  }

  final checkpointDir = Directory('${moduleDir.path}/checkpoints');
  if (checkpointDir.existsSync() && _hasSemanticCheckpoints(checkpointDir)) {
    score += 20;
  }

  final metadata = File('${moduleDir.path}/metadata.json');
  if (metadata.existsSync()) {
    final json =
        jsonDecode(metadata.readAsStringSync()) as Map<String, dynamic>;
    if (json.containsKey('scenario')) {
      score += 10;
    }
  }

  print('Readiness $moduleId: $score/110');
  if (score < 80) {
    print('Status: NOT READY');
    exit(2);
  }
  print('Status: READY');
  exit(0);
}
