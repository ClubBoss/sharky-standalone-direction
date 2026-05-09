import 'dart:convert';
import 'dart:io';

void main() {
  final coverage = _loadCoverage();
  final priority = _loadPriority();
  final report = StringBuffer();
  report.writeln('==== TAP-TO-EXPLAIN AUTO-FIX SUGGESTIONS ====');
  final modulesWithMissing = <String, int>{};
  var totalMissingKeys = 0;
  for (final entry in coverage.entries) {
    final heat = priority[entry.key]?.heat ?? 'WARN';
    final moduleDir = Directory('content/${entry.key}/v1');
    final theory = File('${moduleDir.path}${Platform.pathSeparator}theory.md');
    final explain = File(
      '${moduleDir.path}${Platform.pathSeparator}explain.json',
    );
    final requiredKeys = _extractKeys(theory);
    final definedKeys = _loadExplainKeys(explain);
    final missing = requiredKeys.difference(definedKeys);
    if (missing.isEmpty) continue;
    modulesWithMissing[entry.key] = missing.length;
    totalMissingKeys += missing.length;
    report.writeln('module: ${entry.key}');
    report.writeln('heat: $heat');
    report.writeln('missing: [${missing.join(', ')}]');
    report.writeln('suggestions:');
    for (final key in missing.toList()..sort()) {
      report.writeln('  - add $key to explain.json (stub: {"$key": "TODO"})');
    }
    report.writeln('recommended order: ${missing.toList()..sort()}');
    report.writeln(
      'recommended structure: {"${missing.first}": "Explain the rationale"}',
    );
    report.writeln('----------------------------------------------');
  }
  report.writeln('==== GLOBAL SUMMARY ====');
  report.writeln('modules with missing keys: ${modulesWithMissing.length}');
  report.writeln('total missing keys: $totalMissingKeys');
  report.writeln('top modules:');
  final sortedTop = modulesWithMissing.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (var i = 0; i < sortedTop.length && i < 10; i++) {
    report.writeln(
      '${i + 1}. ${sortedTop[i].key} (${sortedTop[i].value} missing)',
    );
  }
  final out = File('release/_reports/tap_to_explain_autofix.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(report.toString());
  stdout.write(report);
}

Map<String, _CoverageRow> _loadCoverage() {
  final file = File('release/_reports/tap_to_explain_coverage.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _CoverageRow>{};
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    rows[parts[0]] = _CoverageRow(
      module: parts[0],
      required: int.tryParse(parts[1]) ?? 0,
      defined: int.tryParse(parts[2]) ?? 0,
      missing: int.tryParse(parts[3]) ?? 0,
      coverage: double.tryParse(parts[4]) ?? 0.0,
    );
  }
  return rows;
}

Map<String, _PriorityRow> _loadPriority() {
  final file = File('release/_reports/tap_to_explain_priority_map.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _PriorityRow>{};
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    final module = parts[1];
    final coverage = double.tryParse(parts[2]) ?? 0.0;
    final missing = int.tryParse(parts[3]) ?? 0;
    final heat = parts[5];
    rows[module] = _PriorityRow(
      module: module,
      coverage: coverage,
      missing: missing,
      priority: double.tryParse(parts[4]) ?? 0.0,
      heat: heat,
    );
  }
  return rows;
}

Set<String> _extractKeys(File theory) {
  if (!theory.existsSync()) return {};
  final text = theory.readAsStringSync();
  final pattern = RegExp(r'\{\{explain:([a-zA-Z0-9_:-]+)\}\}');
  return pattern
      .allMatches(text)
      .map((m) => m.group(1))
      .whereType<String>()
      .toSet();
}

Set<String> _loadExplainKeys(File explain) {
  if (!explain.existsSync()) return {};
  try {
    final data = json.decode(explain.readAsStringSync());
    if (data is! Map) return {};
    return data.keys.whereType<String>().toSet();
  } catch (_) {
    return {};
  }
}

class _CoverageRow {
  _CoverageRow({
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

class _PriorityRow {
  _PriorityRow({
    required this.module,
    required this.coverage,
    required this.missing,
    required this.priority,
    required this.heat,
  });

  final String module;
  final double coverage;
  final int missing;
  final double priority;
  final String heat;
}
