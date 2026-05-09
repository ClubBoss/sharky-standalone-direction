import 'dart:convert';
import 'dart:io';

void main() {
  final coverage = _loadCoverage();
  final draftDir = Directory('release/_reports/tap_to_explain_drafts');
  draftDir.createSync(recursive: true);
  final index = StringBuffer();
  index.writeln('module | keys');
  for (final entry in coverage.entries) {
    if (entry.value.missing == 0) continue;
    final dir = Directory('content/${entry.key}/v1');
    final theory = File('${dir.path}${Platform.pathSeparator}theory.md');
    if (!theory.existsSync()) continue;
    final text = theory.readAsStringSync().split('\n');
    final keys = _extractKeys(text);
    final explain = File('${dir.path}${Platform.pathSeparator}explain.json');
    final defined = _loadDefined(explain);
    final missing = keys.where((k) => !defined.contains(k)).toList()..sort();
    if (missing.isEmpty) continue;
    index.writeln('${entry.key} | ${missing.length}');
    final buffer = StringBuffer();
    buffer.writeln('Draft explanations for ${entry.key}');
    for (final key in missing) {
      final context = _findContext(text, key);
      buffer.writeln('key: $key');
      buffer.writeln('context: $context');
      buffer.writeln('draft: Placeholder explanation for $key.');
      buffer.writeln('suggestion: Replace this with a proper explanation.');
      buffer.writeln('---');
    }
    File(
      '${draftDir.path}/${entry.key}.txt',
    ).writeAsStringSync(buffer.toString());
  }
  File('${draftDir.path}/_index.txt').writeAsStringSync(index.toString());
  stdout.write(index.toString());
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

Set<String> _loadDefined(File explain) {
  if (!explain.existsSync()) return {};
  try {
    final data = jsonDecodeSafe(explain.readAsStringSync());
    if (data is Map) return data.keys.whereType<String>().toSet();
  } catch (_) {}
  return {};
}

Set<String> _extractKeys(List<String> lines) {
  final pattern = RegExp(r'\{\{explain:([a-zA-Z0-9_:-]+)\}\}');
  final keys = <String>{};
  for (final line in lines) {
    for (final match in pattern.allMatches(line)) {
      keys.add(match.group(1)!);
    }
  }
  return keys;
}

String _findContext(List<String> lines, String key) {
  final pattern = RegExp(r'\{\{explain:' + RegExp.escape(key) + r'\}\}');
  for (final line in lines) {
    if (pattern.hasMatch(line)) return line.trim();
  }
  return 'Refer to relevant theory section around $key.';
}

dynamic jsonDecodeSafe(String input) => JsonDecoder().convert(input);

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
