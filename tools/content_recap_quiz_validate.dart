import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('content/ missing');
    exit(1);
  }

  var failures = 0;

  for (final module in root.listSync().whereType<Directory>()) {
    final moduleId = module.uri.pathSegments.lastWhere(
      (segment) => segment.isNotEmpty,
    );

    final recap = File('${module.path}/recap.md');
    if (!recap.existsSync()) {
      print('[RECAP] $moduleId -> missing file');
      failures++;
    } else {
      final lines = recap.readAsLinesSync();
      final hasHeader = lines.any((line) => line.trim().startsWith('#'));
      if (!hasHeader) {
        print('[RECAP] $moduleId -> missing header');
        failures++;
      }
    }

    final quiz = File('${module.path}/quiz.jsonl');
    if (!quiz.existsSync()) {
      print('[QUIZ] $moduleId -> missing file');
      failures++;
      continue;
    }

    final content = quiz.readAsLinesSync();
    final nonEmpty = content.where((line) => line.trim().isNotEmpty).toList();
    if (nonEmpty.isEmpty) {
      print('[QUIZ] $moduleId -> empty');
      failures++;
      continue;
    }

    var lineNumber = 0;
    var invalid = false;
    for (final line in content) {
      lineNumber += 1;
      if (line.trim().isEmpty) continue;
      try {
        final decoded = jsonDecode(line);
        if (decoded is! Map) {
          throw FormatException('not an object');
        }
      } catch (e) {
        print('[QUIZ] $moduleId -> invalid jsonl at line $lineNumber');
        failures++;
        invalid = true;
        break;
      }
    }

    if (invalid) continue;
  }

  if (failures == 0) {
    print('Recap/Quiz OK');
    exit(0);
  }
  exit(1);
}
