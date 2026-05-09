import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('content/ missing');
    exit(1);
  }

  var failed = false;
  final validatorFiles = ['quiz.jsonl'];
  final sections = ['drills', 'demos'];

  for (final module in root.listSync().whereType<Directory>()) {
    final moduleId = module.uri.pathSegments.lastWhere(
      (segment) => segment.isNotEmpty,
    );

    final jsonlTargets = <File>[];
    for (final fileName in validatorFiles) {
      jsonlTargets.add(File('${module.path}/$fileName'));
    }
    for (final section in sections) {
      final dir = Directory('${module.path}/$section');
      if (dir.existsSync()) {
        jsonlTargets.addAll(
          dir.listSync().whereType<File>().where(
            (file) => file.path.endsWith('.jsonl'),
          ),
        );
      }
    }

    for (final file in jsonlTargets) {
      if (!file.existsSync()) {
        print('[JSONL] $moduleId ${file.uri.pathSegments.last} -> missing');
        failed = true;
        continue;
      }
      final lines = file.readAsLinesSync();
      final nonEmpty = lines.where((line) => line.trim().isNotEmpty).toList();
      if (nonEmpty.isEmpty) {
        print('[JSONL] $moduleId ${file.uri.pathSegments.last} -> empty');
        failed = true;
        continue;
      }
      var lineNumber = 0;
      for (final line in lines) {
        lineNumber += 1;
        if (line.trim().isEmpty) continue;
        try {
          final decoded = jsonDecode(line);
          if (decoded is! Map) {
            throw FormatException('not object');
          }
        } catch (e) {
          print(
            '[JSONL] $moduleId ${file.uri.pathSegments.last} -> line $lineNumber invalid JSON',
          );
          failed = true;
          break;
        }
      }
    }

    try {
      File('${module.path}/metadata.json').readAsStringSync();
      File('${module.path}/recap.md').readAsStringSync();
      File('${module.path}/quiz.jsonl').readAsStringSync();
      for (final section in sections) {
        final dir = Directory('${module.path}/$section');
        if (!dir.existsSync()) {
          throw Exception('missing $section directory');
        }
        dir.listSync(); // just iterate
      }
      print('[EXPORT] $moduleId OK');
    } catch (e) {
      print('[EXPORT] $moduleId FAIL -> $e');
      failed = true;
    }
  }

  if (failed) {
    exit(1);
  }
  print('JSONL Hygiene OK');
  exit(0);
}
