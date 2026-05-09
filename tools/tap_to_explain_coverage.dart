import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) return;
  final pattern = RegExp(r'\{\{explain:([a-zA-Z0-9_:-]+)\}\}');
  final modules = <_CoverageEntry>[];
  var totalRequired = 0;
  var totalDefined = 0;
  var totalMissing = 0;
  for (final dir
      in root
          .listSync(recursive: true)
          .whereType<Directory>()
          .where((d) => d.path.endsWith('${Platform.pathSeparator}v1'))) {
    final moduleId = dir.parent.path.split(Platform.pathSeparator).last;
    final theory = File('${dir.path}${Platform.pathSeparator}theory.md');
    if (!theory.existsSync()) continue;
    final theoryText = theory.readAsStringSync();
    final required = pattern
        .allMatches(theoryText)
        .map((m) => m.group(1))
        .whereType<String>()
        .toSet();
    final explainFile = File(
      '${dir.path}${Platform.pathSeparator}explain.json',
    );
    final defined = <String>{};
    if (explainFile.existsSync()) {
      try {
        final data = jsonDecodeSafe(explainFile.readAsStringSync());
        if (data is Map) {
          data.forEach((k, v) {
            if (k is String) defined.add(k);
          });
        }
      } catch (_) {}
    }
    final missing = required.difference(defined);
    final coverage = required.isEmpty ? 1.0 : defined.length / required.length;
    modules.add(
      _CoverageEntry(
        module: moduleId,
        required: required.length,
        defined: defined.length,
        missing: missing.length,
        coverage: coverage,
      ),
    );
    totalRequired += required.length;
    totalDefined += defined.length;
    totalMissing += missing.length;
  }
  modules.sort((a, b) => a.coverage.compareTo(b.coverage));
  final buffer = StringBuffer();
  buffer.writeln('==== TAP-TO-EXPLAIN COVERAGE MAP ====');
  buffer.writeln('module | required | defined | missing | coverage');
  for (final entry in modules) {
    buffer.writeln(
      '${entry.module.padRight(30)} | ${entry.required.toString().padLeft(3)} | ${entry.defined.toString().padLeft(3)} | ${entry.missing.toString().padLeft(3)} | ${entry.coverage.toStringAsFixed(2)}',
    );
  }
  final globalCoverage = totalRequired == 0
      ? 1.0
      : totalDefined / totalRequired;
  buffer.writeln('==== GLOBAL SUMMARY ====');
  buffer.writeln(
    'required | defined | missing | globalCoverage\n${totalRequired.toString().padLeft(8)} | ${totalDefined.toString().padLeft(7)} | ${totalMissing.toString().padLeft(7)} | ${globalCoverage.toStringAsFixed(2)}',
  );
  final out = File('release/_reports/tap_to_explain_coverage.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

dynamic jsonDecodeSafe(String input) {
  return JsonDecoder().convert(input);
}

class _CoverageEntry {
  _CoverageEntry({
    required this.module,
    required this.required,
    required this.defined,
    required this.missing,
    required this.coverage,
  });

  final String module;
  final int required;
  final int defined;
  final int missing;
  final double coverage;
}
