import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) return;
  final report = StringBuffer();
  report.writeln('module_id | missing | jsonl_valid | extras');
  for (final v1Dir
      in root
          .listSync(recursive: true)
          .whereType<Directory>()
          .where((d) => d.path.endsWith('/v1'))) {
    final moduleId = v1Dir.parent.path.split(Platform.pathSeparator).last;
    final required = {
      'theory.md': false,
      'drills.jsonl': false,
      'demos.jsonl': false,
    };
    final optional = ['quiz.jsonl', 'recap.md', 'cheatsheet.md', 'rubric.md'];
    final files = <String>[];
    for (final file in v1Dir.listSync()) {
      if (file is File) files.add(file.path.split(Platform.pathSeparator).last);
    }
    files.sort();
    final missing = required.keys
        .where((name) => !files.contains(name))
        .toList();
    final existingJsons = files
        .where((name) => name.endsWith('.jsonl'))
        .where((name) => required.containsKey(name) || optional.contains(name))
        .toList();
    final jsonValid = existingJsons.every(
      (name) => _validateJsonLines(File('${v1Dir.path}/$name')),
    );
    final extras = files.where(
      (name) => !required.containsKey(name) && !optional.contains(name),
    );
    final sequence = [...required.keys, ...optional];
    var orderOk = true;
    var lastIndex = -1;
    for (final name in files) {
      final idx = sequence.indexOf(name);
      if (idx == -1) continue;
      if (idx < lastIndex) {
        orderOk = false;
        break;
      }
      lastIndex = idx;
    }
    final orderFlag = orderOk ? 'order-ok' : 'order-bad';
    report.writeln(
      '$moduleId | ${missing.isEmpty ? "none" : missing.join(",")} | ${jsonValid ? "ok" : "fail"} | ${extras.isEmpty ? "none" : extras.join(",")} | $orderFlag',
    );
  }
  final output = File('release/_reports/content_structure_audit.txt');
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(report.toString());
  stdout.write(report);
}

bool _validateJsonLines(File file) {
  if (!file.existsSync()) return true;
  final lines = file.readAsLinesSync();
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    try {
      json.decode(line);
    } catch (_) {
      return false;
    }
  }
  return true;
}
