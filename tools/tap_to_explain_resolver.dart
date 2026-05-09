import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) return;
  final pattern = RegExp(r'\{\{explain:([a-zA-Z0-9_:-]+)\}\}');
  for (final dir
      in root
          .listSync(recursive: true)
          .whereType<Directory>()
          .where((d) => d.path.endsWith('${Platform.pathSeparator}v1'))) {
    final moduleId = dir.parent.path.split(Platform.pathSeparator).last;
    final theory = File('${dir.path}${Platform.pathSeparator}theory.md');
    if (!theory.existsSync()) continue;
    final explainFile = File(
      '${dir.path}${Platform.pathSeparator}explain.json',
    );
    final theoryText = theory.readAsStringSync();
    final keys = pattern
        .allMatches(theoryText)
        .map((m) => m.group(1))
        .whereType<String>()
        .toSet();
    final explanations = <String, String>{};
    if (explainFile.existsSync()) {
      try {
        final decoded = json.decode(explainFile.readAsStringSync());
        if (decoded is Map) {
          decoded.forEach((k, v) {
            if (k is String && v is String) {
              explanations[k] = v;
            }
          });
        }
      } catch (_) {}
    }
    final resolved = <String>[];
    final missing = <String>[];
    for (final key in keys) {
      if (explanations.containsKey(key)) {
        resolved.add(key);
      } else {
        missing.add(key);
      }
    }
    final summary = StringBuffer()
      ..writeln('module | keysFound | keysResolved | keysMissing')
      ..writeln(
        '$moduleId | ${keys.length} | ${resolved.length} | ${missing.length}',
      );
    final outFile = File('release/_reports/tap_to_explain_$moduleId.txt');
    outFile.parent.createSync(recursive: true);
    outFile.writeAsStringSync(summary.toString());
    stdout.write(summary);
  }
}
