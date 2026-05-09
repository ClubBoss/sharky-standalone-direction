import 'dart:io';

void main() {
  final patchPlans = _parsePatchPlans();
  final density = _parseDensity();
  final drafts = _parseDrafts();
  final consistency = _parseConsistency();
  final priorityBands = _parsePriorityIndex();
  final executionOrder = <_Entry>[];
  for (final module in patchPlans.keys) {
    final plan = patchPlans[module]!;
    final dens = density[module];
    final heat = consistency[module]?.heat ?? 'Warm';
    final priority = priorityBands[module] ?? 'MEDIUM';
    final actions = <String>[
      'structure fix hints: ${plan.action}',
      if (dens != null) 'density focus: ${dens.status}',
      if (drafts.contains(module)) 'generate explain draft',
    ];
    final package = StringBuffer();
    package.writeln('module: $module');
    package.writeln('priority: $priority');
    package.writeln('heat: $heat');
    package.writeln('requiredFiles: ${plan.requiredFiles}');
    package.writeln('actions:');
    for (final action in actions) {
      package.writeln('  - $action');
    }
    package.writeln('sequence: ${actions.join(' -> ')}');
    final outDir = Directory('release/_reports/correction_engine');
    outDir.createSync(recursive: true);
    File('${outDir.path}/$module.txt').writeAsStringSync(package.toString());
    executionOrder.add(_Entry(module: module, score: plan.score));
  }
  executionOrder.sort((a, b) => b.score.compareTo(a.score));
  final exec = StringBuffer();
  exec.writeln('Correction Engine Execution Plan');
  for (final entry in executionOrder) {
    exec.writeln(
      '${entry.module} | priorityScore=${entry.score.toStringAsFixed(1)}',
    );
  }
  File(
    'release/_reports/correction_engine/_execution_plan.txt',
  ).writeAsStringSync(exec.toString());
  stdout.write(exec.toString());
}

Map<String, _PatchPlan> _parsePatchPlans() {
  final file = File('release/_reports/patch_plans/_index.txt');
  final map = <String, _PatchPlan>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    final score = double.tryParse(parts[2]) ?? 0.0;
    map[parts[0]] = _PatchPlan(
      action: parts[2],
      score: score,
      requiredFiles: 'see patch plan',
    );
  }
  return map;
}

Map<String, _DensityEntry> _parseDensity() {
  final file = File(
    'release/_reports/density_coherence_suggestions/_index.txt',
  );
  final map = <String, _DensityEntry>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 4) continue;
    map[parts[0]] = _DensityEntry(status: parts[3]);
  }
  return map;
}

Set<String> _parseDrafts() {
  final file = File('release/_reports/tap_to_explain_drafts/_index.txt');
  if (!file.existsSync()) return {};
  return file
      .readAsLinesSync()
      .skip(1)
      .map((line) => line.split('|').first.trim())
      .toSet();
}

Map<String, _ConsistencyRow> _parseConsistency() {
  final file = File('release/_reports/content_consistency_map.txt');
  final map = <String, _ConsistencyRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 7) continue;
    map[parts[1]] = _ConsistencyRow(heat: parts[6]);
  }
  return map;
}

Map<String, String> _parsePriorityIndex() {
  final file = File('release/_reports/autofix_priority_index.txt');
  final map = <String, String>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    map[parts[0]] = parts[2];
  }
  return map;
}

class _Entry {
  _Entry({required this.module, required this.score});
  final String module;
  final double score;
}

class _PatchPlan {
  _PatchPlan({
    required this.action,
    required this.score,
    required this.requiredFiles,
  });
  final String action;
  final double score;
  final String requiredFiles;
}

class _DensityEntry {
  _DensityEntry({required this.status});
  final String status;
}

class _ConsistencyRow {
  _ConsistencyRow({required this.heat});
  final String heat;
}
