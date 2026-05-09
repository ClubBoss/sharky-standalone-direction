import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _contentRoot = 'content';
const String _reportsDir = 'release/_reports';
const String _exportsDir = 'release/_exports';
const String _snapshotJsonPath = 'release/_exports/curriculum_snapshot.json';
const String _summaryPath = 'release/_reports/curriculum_snapshot_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _refinementSummaryPath =
    'release/_reports/drill_refinement_summary.txt';
const String _metaSummaryPath =
    'release/_reports/meta_review_consistency_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final packs = await _collectPackSnapshots();
  if (packs.isEmpty) {
    stdout.writeln('curriculum_snapshot_exporter: no content packs found.');
    return;
  }

  final refinement = await _readRefinementSummary();
  final meta = await _readMetaSummary();

  final export = _buildExport(packs);
  _ensureExportsDir();
  await File(
    _snapshotJsonPath,
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(export.toJson()));

  await _withReportsWritable(() async {
    await _writeSummary(export, refinement, meta);
    await _appendTelemetry(
      packs: export.packs.length,
      modules: export.totals.modules,
      avgScore: export.totals.avgClarity,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'curriculum_snapshot_exporter: '
    '${export.packs.length} packs / ${export.totals.modules} modules exported.',
  );
}

Future<List<_PackSnapshot>> _collectPackSnapshots() async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];
  final packs = <String, _PackSnapshot>{};

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.jsonl')) continue;
    final packId = _packIdFromPath(entity.path);
    final snapshot = packs.putIfAbsent(packId, () => _PackSnapshot(packId));
    final lines = await entity.readAsLines();
    for (var lineNo = 0; lineNo < lines.length; lineNo++) {
      final raw = lines[lineNo].trim();
      if (raw.isEmpty || raw.startsWith('#')) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          snapshot.registerModule(decoded);
        }
      } catch (_) {
        // ignore malformed rows, surfaced elsewhere.
      }
    }
  }

  final list = packs.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  list.forEach((snapshot) => snapshot.finalize());
  return list;
}

_SnapshotExport _buildExport(List<_PackSnapshot> packs) {
  final packExports = packs.map((p) => p.toExport()).toList();
  final totals = _Totals(
    packs: packExports.length,
    modules: packExports.fold<int>(0, (sum, p) => sum + p.modules),
    avgCompletion: _average(packExports.map((p) => p.completionPct).toList()),
    avgClarity: _average(packExports.map((p) => p.avgClarity).toList()),
    avgReactionQuality: _average(
      packExports.map((p) => p.reactionQuality).toList(),
    ),
  );
  return _SnapshotExport(
    generated: DateTime.now(),
    packs: packExports,
    totals: totals,
  );
}

Future<_RefinementSummary?> _readRefinementSummary() async {
  final file = File(_refinementSummaryPath);
  if (!await file.exists()) return null;
  double? avgClarity;
  double? avgCoverage;
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Average clarity score:')) {
      avgClarity = double.tryParse(trimmed.split(':').last.trim());
    } else if (trimmed.startsWith('Average coverage score:')) {
      avgCoverage = double.tryParse(trimmed.split(':').last.trim());
    }
  }
  return _RefinementSummary(avgClarity: avgClarity, avgCoverage: avgCoverage);
}

Future<_MetaSummary?> _readMetaSummary() async {
  final file = File(_metaSummaryPath);
  if (!await file.exists()) return null;
  int? issues;
  double? coverage;
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Issues detected:')) {
      issues = int.tryParse(trimmed.split(':').last.trim());
    } else if (trimmed.startsWith('Coverage:')) {
      final pct = trimmed.split(':').last.trim().replaceAll('%', '');
      coverage = double.tryParse(pct);
    }
  }
  return _MetaSummary(issues: issues, coveragePct: coverage);
}

Future<void> _writeSummary(
  _SnapshotExport export,
  _RefinementSummary? refinement,
  _MetaSummary? meta,
) async {
  final buffer = StringBuffer()
    ..writeln('CURRICULUM SNAPSHOT SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${export.generated.toIso8601String()}')
    ..writeln('Packs: ${export.packs.length}')
    ..writeln('Modules: ${export.totals.modules}')
    ..writeln(
      'Avg completion: ${export.totals.avgCompletion.toStringAsFixed(2)}%',
    )
    ..writeln(
      'Avg clarity: ${export.totals.avgClarity.toStringAsFixed(3)} '
      ' / Avg reaction quality: ${export.totals.avgReactionQuality.toStringAsFixed(3)}',
    )
    ..writeln();

  if (refinement != null) {
    buffer
      ..writeln('Drill refinement summary:')
      ..writeln('- Average clarity score: ${refinement.avgClarity ?? 'n/a'}')
      ..writeln('- Average coverage score: ${refinement.avgCoverage ?? 'n/a'}')
      ..writeln();
  }

  if (meta != null) {
    buffer
      ..writeln('Meta review summary:')
      ..writeln('- Issues detected: ${meta.issues ?? 'n/a'}')
      ..writeln('- Coverage: ${meta.coveragePct?.toStringAsFixed(2) ?? 'n/a'}%')
      ..writeln();
  }

  final lowestClarity = [...export.packs]
    ..sort((a, b) => a.avgClarity.compareTo(b.avgClarity));
  final lowestReaction = [...export.packs]
    ..sort((a, b) => a.reactionQuality.compareTo(b.reactionQuality));

  buffer
    ..writeln('Lowest clarity packs')
    ..writeln('| Pack | Modules | Avg Clarity | Completion |')
    ..writeln('|------|---------|-------------|------------|');
  for (final pack in lowestClarity.take(8)) {
    buffer.writeln(
      '| ${pack.id} | ${pack.modules} | '
      '${pack.avgClarity.toStringAsFixed(3)} | '
      '${pack.completionPct.toStringAsFixed(1)}% |',
    );
  }
  buffer.writeln();

  buffer
    ..writeln('Lowest reaction quality packs')
    ..writeln('| Pack | Unique Reactions | Modules | Quality |')
    ..writeln('|------|------------------|---------|---------|');
  for (final pack in lowestReaction.take(8)) {
    buffer.writeln(
      '| ${pack.id} | ${pack.uniqueReactions} | ${pack.modules} | '
      '${pack.reactionQuality.toStringAsFixed(3)} |',
    );
  }
  buffer.writeln();

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int packs,
  required int modules,
  required double avgScore,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'curriculum_snapshot_exported',
    'timestamp': DateTime.now().toIso8601String(),
    'packs': packs,
    'modules': modules,
    'avg_score': double.parse(avgScore.toStringAsFixed(4)),
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'curriculum_snapshot_exporter: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

void _ensureExportsDir() {
  Directory(_exportsDir).createSync(recursive: true);
}

double _average(List<double> values) {
  if (values.isEmpty) return 0.0;
  final sum = values.fold<double>(0.0, (total, value) => total + value);
  return double.parse((sum / values.length).toStringAsFixed(4));
}

String _packIdFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final startIndex = normalized.indexOf('content/');
  if (startIndex == -1) return normalized;
  final after = normalized.substring(startIndex + 'content/'.length);
  final slashIndex = after.indexOf('/');
  if (slashIndex == -1) return after;
  return after.substring(0, slashIndex);
}

class _PackSnapshot {
  _PackSnapshot(this.id);

  final String id;
  int totalModules = 0;
  int completedModules = 0;
  double claritySum = 0;
  final Map<String, int> reactionCounts = {};

  void registerModule(Map<String, dynamic> module) {
    totalModules += 1;
    final goal = module['goal']?.toString() ?? '';
    final reaction = module['reaction_text']?.toString() ?? '';
    if (goal.trim().isNotEmpty && reaction.trim().isNotEmpty) {
      completedModules += 1;
    }
    final categories =
        (module['categories'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    claritySum += _clarityScore(goal, reaction, categories);
    final reactionKey = reaction.trim().toLowerCase();
    if (reactionKey.isNotEmpty) {
      reactionCounts[reactionKey] = (reactionCounts[reactionKey] ?? 0) + 1;
    }
  }

  void finalize() {
    if (totalModules == 0) {
      claritySum = 0;
    }
  }

  _PackExport toExport() {
    final uniqueReactions = reactionCounts.keys.length;
    final avgClarity = totalModules == 0
        ? 0.0
        : claritySum / totalModules.toDouble();
    final completionPct = totalModules == 0
        ? 0.0
        : (completedModules / totalModules.toDouble()) * 100.0;
    final reactionQuality = totalModules == 0
        ? 0.0
        : uniqueReactions / totalModules.toDouble();
    return _PackExport(
      id: id,
      modules: totalModules,
      completionPct: double.parse(completionPct.toStringAsFixed(4)),
      avgClarity: double.parse(avgClarity.toStringAsFixed(4)),
      reactionQuality: double.parse(reactionQuality.toStringAsFixed(4)),
      uniqueReactions: uniqueReactions,
    );
  }
}

double _clarityScore(String goal, String reaction, List<String> categories) {
  final goalLen = goal.length;
  final reactionLen = reaction.length;
  final goalPart = goalLen == 0 ? 0.0 : min(0.6, goalLen / 160);
  final reactionPart = reactionLen == 0 ? 0.0 : min(0.3, reactionLen / 120);
  final categoryPart = min(0.1, categories.length * 0.02);
  return goalPart + reactionPart + categoryPart;
}

class _PackExport {
  const _PackExport({
    required this.id,
    required this.modules,
    required this.completionPct,
    required this.avgClarity,
    required this.reactionQuality,
    required this.uniqueReactions,
  });

  final String id;
  final int modules;
  final double completionPct;
  final double avgClarity;
  final double reactionQuality;
  final int uniqueReactions;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'modules': modules,
      'completion_pct': completionPct,
      'avg_clarity': avgClarity,
      'reaction_quality': reactionQuality,
      'unique_reactions': uniqueReactions,
    };
  }
}

class _Totals {
  const _Totals({
    required this.packs,
    required this.modules,
    required this.avgCompletion,
    required this.avgClarity,
    required this.avgReactionQuality,
  });

  final int packs;
  final int modules;
  final double avgCompletion;
  final double avgClarity;
  final double avgReactionQuality;
}

class _SnapshotExport {
  const _SnapshotExport({
    required this.generated,
    required this.packs,
    required this.totals,
  });

  final DateTime generated;
  final List<_PackExport> packs;
  final _Totals totals;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'generated': generated.toIso8601String(),
      'totals': {
        'packs': totals.packs,
        'modules': totals.modules,
        'avg_completion_pct': totals.avgCompletion,
        'avg_clarity': totals.avgClarity,
        'avg_reaction_quality': totals.avgReactionQuality,
      },
      'packs': packs.map((p) => p.toJson()).toList(),
    };
  }
}

class _RefinementSummary {
  const _RefinementSummary({this.avgClarity, this.avgCoverage});

  final double? avgClarity;
  final double? avgCoverage;
}

class _MetaSummary {
  const _MetaSummary({this.issues, this.coveragePct});

  final int? issues;
  final double? coveragePct;
}
