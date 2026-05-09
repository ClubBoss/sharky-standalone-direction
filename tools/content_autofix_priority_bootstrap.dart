import 'dart:io';

void main() {
  final consistency = _loadConsistency();
  final tte = _loadPriority();
  final scorecards = _loadScorecards();
  final modules = <String>{}
    ..addAll(consistency.keys)
    ..addAll(tte.keys)
    ..addAll(scorecards.keys);
  final entries = <_Entry>[];
  for (final module in modules) {
    final cons = consistency[module];
    final tteRow = tte[module];
    final card = scorecards[module];
    final score = cons?.score ?? double.nan;
    final heat = cons?.heat ?? 'Warm';
    final priorityScore =
        (score.isNaN ? 0 : score) +
        (heat == 'Hot'
            ? 1.0
            : heat == 'Warn'
            ? 0.5
            : 0.0);
    final missingExplain = tteRow?.missing ?? 0;
    entries.add(
      _Entry(
        module: module,
        priority: priorityScore,
        heat: heat,
        structure: card?.structure ?? 'n/a',
        density: card?.density ?? 'n/a',
        tteMissing: missingExplain,
        summary: card?.suggestions ?? ['Review scorecard'],
      ),
    );
  }
  entries.sort((a, b) => b.priority.compareTo(a.priority));
  final bootstrap = StringBuffer();
  bootstrap.writeln('==== AUTOFIX PRIORITY BOOTSTRAP ====');
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    bootstrap.writeln(
      '${i + 1}. ${entry.module} | priority=${entry.priority.toStringAsFixed(2)} heat=${entry.heat}',
    );
    bootstrap.writeln('   structure: ${entry.structure}');
    bootstrap.writeln('   density: ${entry.density}');
    bootstrap.writeln('   missing explain keys: ${entry.tteMissing}');
    bootstrap.writeln('   fix plan:');
    for (final suggestion in entry.summary) {
      bootstrap.writeln('     - $suggestion');
    }
  }
  final index = StringBuffer();
  index.writeln('module | priority | heat');
  for (final entry in entries) {
    final band = entry.priority >= 1.5
        ? 'CRITICAL'
        : entry.priority >= 1.0
        ? 'HIGH'
        : entry.priority >= 0.5
        ? 'MEDIUM'
        : 'LOW';
    index.writeln(
      '${entry.module} | ${entry.priority.toStringAsFixed(2)} | $band',
    );
  }
  final out = File('release/_reports/autofix_priority_bootstrap.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(bootstrap.toString());
  stdout.write(bootstrap);
  final idx = File('release/_reports/autofix_priority_index.txt');
  idx.writeAsStringSync(index.toString());
}

Map<String, _ConsistencyRow> _loadConsistency() {
  final file = File('release/_reports/content_consistency_map.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _ConsistencyRow>{};
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 7) continue;
    final score = double.tryParse(parts[5]) ?? 0;
    rows[parts[1]] = _ConsistencyRow(
      module: parts[1],
      score: score,
      heat: parts[6],
    );
  }
  return rows;
}

Map<String, _TTPriorityRow> _loadPriority() {
  final file = File('release/_reports/tap_to_explain_priority_map.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _TTPriorityRow>{};
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    rows[parts[1]] = _TTPriorityRow(
      module: parts[1],
      missing: int.tryParse(parts[3]) ?? 0,
      heat: parts[5],
    );
  }
  return rows;
}

Map<String, _ScorecardRow> _loadScorecards() {
  final file = File('release/_reports/scorecards/_index.txt');
  if (!file.existsSync()) return {};
  final map = <String, _ScorecardRow>{};
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    map[parts[0]] = _ScorecardRow(
      module: parts[0],
      structure: parts[1],
      density: parts[2],
      suggestions: ['Check scorecard'],
    );
  }
  return map;
}

class _Entry {
  _Entry({
    required this.module,
    required this.priority,
    required this.heat,
    required this.structure,
    required this.density,
    required this.tteMissing,
    required this.summary,
  });

  final String module;
  final double priority;
  final String heat;
  final String structure;
  final String density;
  final int tteMissing;
  final List<String> summary;
}

class _ConsistencyRow {
  _ConsistencyRow({
    required this.module,
    required this.score,
    required this.heat,
  });

  final String module;
  final double score;
  final String heat;
}

class _TTPriorityRow {
  _TTPriorityRow({
    required this.module,
    required this.missing,
    required this.heat,
  });

  final String module;
  final int missing;
  final String heat;
}

class _ScorecardRow {
  _ScorecardRow({
    required this.module,
    required this.structure,
    required this.density,
    required this.suggestions,
  });

  final String module;
  final String structure;
  final String density;
  final List<String> suggestions;
}
