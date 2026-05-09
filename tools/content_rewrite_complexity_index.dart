import 'dart:io';

void main() {
  final patch = _readPatchPlans();
  final density = _readDensityIndex();
  final drafts = _readDraftIndex();
  final consistency = _readConsistency();
  final modules = <String>{}
    ..addAll(patch.keys)
    ..addAll(density.keys)
    ..addAll(drafts)
    ..addAll(consistency.keys);
  final entries = <_Entry>[];
  for (final module in modules) {
    final actionCount = patch[module]?.actionCount ?? 0;
    final densitySeverity = density[module]?.severity ?? 'LOW';
    double densityScore;
    if (densitySeverity == 'HIGH') {
      densityScore = 30.0;
    } else if (densitySeverity == 'MEDIUM') {
      densityScore = 15.0;
    } else {
      densityScore = 5.0;
    }
    final explainMissing = drafts.contains(module) ? 1 : 0;
    final struct = consistency[module];
    final structuralScore =
        (struct?.missing ?? 0) * 10 +
        (struct?.extras ?? 0) * 5 +
        (struct?.orderBad ?? 0) * 10;
    final score =
        (structuralScore + densityScore + explainMissing * 20 + actionCount * 2)
            .clamp(0, 100)
            .toDouble();
    final tier = score >= 75
        ? 'TIER 4'
        : score >= 55
        ? 'TIER 3'
        : score >= 35
        ? 'TIER 2'
        : 'TIER 1';
    entries.add(_Entry(module: module, score: score, tier: tier));
  }
  entries.sort((a, b) => b.score.compareTo(a.score));
  final buffer = StringBuffer();
  buffer.writeln('==== REWRITE COMPLEXITY INDEX ====');
  buffer.writeln('module | score | tier');
  double total = 0;
  for (final entry in entries) {
    buffer.writeln(
      '${entry.module.padRight(30)} | ${entry.score.toStringAsFixed(1)} | ${entry.tier}',
    );
    total += entry.score;
  }
  final avg = entries.isEmpty ? 0.0 : total / entries.length;
  final minScore = entries.isEmpty ? 0.0 : entries.last.score;
  final maxScore = entries.isEmpty ? 0.0 : entries.first.score;
  buffer.writeln('==== GLOBAL STATS ====');
  buffer.writeln('avg | ${avg.toStringAsFixed(1)}');
  buffer.writeln('min | ${minScore.toStringAsFixed(1)}');
  buffer.writeln('max | ${maxScore.toStringAsFixed(1)}');
  final out = File('release/_reports/rewrite_complexity_index.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

Map<String, _PatchRow> _readPatchPlans() {
  final file = File('release/_reports/patch_plans/_index.txt');
  final map = <String, _PatchRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final module = line.split('|').first.trim();
    final count = line.split('|').length;
    map[module] = _PatchRow(actionCount: count);
  }
  return map;
}

Map<String, _DensityRow> _readDensityIndex() {
  final file = File(
    'release/_reports/density_coherence_suggestions/_index.txt',
  );
  final map = <String, _DensityRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 4) continue;
    map[parts[0]] = _DensityRow(severity: parts[3]);
  }
  return map;
}

Set<String> _readDraftIndex() {
  final file = File('release/_reports/tap_to_explain_drafts/_index.txt');
  if (!file.existsSync()) return {};
  return file
      .readAsLinesSync()
      .skip(1)
      .map((line) => line.split('|').first.trim())
      .toSet();
}

Map<String, _ConsistencyRow> _readConsistency() {
  final file = File('release/_reports/content_consistency_map.txt');
  final map = <String, _ConsistencyRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 7) continue;
    final missing = parts[2] == 'ok' ? 0 : 1;
    final extras = parts[3] == 'none' ? 0 : parts[3].split(',').length;
    final orderBad = parts[4] == 'order-bad' ? 1 : 0;
    map[parts[1]] = _ConsistencyRow(
      missing: missing,
      extras: extras,
      orderBad: orderBad,
    );
  }
  return map;
}

class _Entry {
  _Entry({required this.module, required this.score, required this.tier});
  final String module;
  final double score;
  final String tier;
}

class _PatchRow {
  _PatchRow({required this.actionCount});
  final int actionCount;
}

class _DensityRow {
  _DensityRow({required this.severity});
  final String severity;
}

class _ConsistencyRow {
  _ConsistencyRow({
    required this.missing,
    required this.extras,
    required this.orderBad,
  });
  final int missing;
  final int extras;
  final int orderBad;
}
