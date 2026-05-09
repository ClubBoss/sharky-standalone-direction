import 'dart:io';

void main() {
  final report = File('release/_reports/tap_to_explain_coverage.txt');
  if (!report.existsSync()) return;
  final lines = report.readAsLinesSync();
  if (lines.length <= 1) return;
  final entries = <_Entry>[];
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    final module = parts[0];
    final coverage = double.tryParse(parts[4]) ?? 0.0;
    final missing = int.tryParse(parts[3]) ?? 0;
    final priority = (missing * 2) + (1 - coverage) * 100;
    final heat = coverage >= 0.9
        ? 'OK'
        : coverage >= 0.6
        ? 'WARN'
        : 'CRIT';
    entries.add(
      _Entry(
        module: module,
        coverage: coverage,
        missing: missing,
        priority: priority,
        heat: heat,
      ),
    );
  }
  entries.sort((a, b) => b.priority.compareTo(a.priority));
  final buffer = StringBuffer();
  buffer.writeln('==== TAP-TO-EXPLAIN PRIORITY MAP ====');
  buffer.writeln('rank | module | coverage | missing | priority | heat');
  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    buffer.writeln(
      '${(i + 1).toString().padLeft(4)} | ${e.module.padRight(30)} | ${e.coverage.toStringAsFixed(2)} | ${e.missing.toString().padLeft(3)} | ${e.priority.toStringAsFixed(1)} | ${e.heat}',
    );
  }
  final avgCoverage = entries.isEmpty
      ? 1.0
      : entries.map((e) => e.coverage).reduce((a, b) => a + b) / entries.length;
  final counts = {
    'OK': entries.where((e) => e.heat == 'OK').length,
    'WARN': entries.where((e) => e.heat == 'WARN').length,
    'CRIT': entries.where((e) => e.heat == 'CRIT').length,
  };
  buffer.writeln('==== GLOBAL STATS ====');
  buffer.writeln('total modules | ${entries.length}');
  buffer.writeln('avg coverage  | ${avgCoverage.toStringAsFixed(2)}');
  buffer.writeln(
    'heat breakdown | OK=${counts['OK']} WARN=${counts['WARN']} CRIT=${counts['CRIT']}',
  );
  final out = File('release/_reports/tap_to_explain_priority_map.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

class _Entry {
  _Entry({
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
