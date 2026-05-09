import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_cohesion_check.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final moduleDir = Directory('content/$moduleId');
  if (!moduleDir.existsSync()) {
    stderr.writeln('Module directory missing');
    exit(1);
  }

  var failed = false;

  final recap = File('${moduleDir.path}/recap.md');
  if (!recap.existsSync() || recap.readAsStringSync().length < 100) {
    print('[COHESION] $moduleId -> recap too short');
    failed = true;
  }

  final quizFile = File('${moduleDir.path}/quiz.jsonl');
  if (!quizFile.existsSync()) {
    print('[COHESION] $moduleId -> quiz too small');
    failed = true;
  } else {
    final lines = quizFile
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .toList();
    var count = 0;
    for (final line in lines) {
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map) {
          count++;
        }
      } catch (_) {}
    }
    if (count < 3) {
      print('[COHESION] $moduleId -> quiz too small');
      failed = true;
    }
  }

  bool sectionValid(String section) {
    final dir = Directory('${moduleDir.path}/$section');
    if (!dir.existsSync()) return false;
    for (final file in dir.listSync().whereType<File>()) {
      if (file.lengthSync() > 0) return true;
    }
    return false;
  }

  if (!sectionValid('drills')) {
    print('[COHESION] $moduleId -> no valid drills');
    failed = true;
  }
  if (!sectionValid('demos')) {
    print('[COHESION] $moduleId -> no valid demos');
    failed = true;
  }

  if (failed) {
    exit(1);
  }

  print('Cohesion OK');
  exit(0);
}
