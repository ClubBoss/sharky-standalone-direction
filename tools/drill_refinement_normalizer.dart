import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _drillsPath = 'content/_generated/drills/v1/drills.jsonl';
const String _fusionMapPath = 'release/_reports/cross_path_fusion_map.json';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/drill_refinement_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final drills = await _readDrills();
  if (drills.isEmpty) {
    stdout.writeln('drill_refinement_normalizer: no drills found.');
    return;
  }

  final fusionMeta = await _readFusionMeta();
  int normalizedCount = 0;
  for (final drill in drills) {
    final conceptMeta = fusionMeta[drill.concept?.toLowerCase() ?? ''];
    final categories = drill.categories.isNotEmpty
        ? drill.categories
        : conceptMeta?.categories ?? const <String>[];

    if (drill.goal.trim().isEmpty) {
      drill.goal = _generateGoal(
        concept: drill.concept,
        categories: categories,
        modules: drill.modules,
      );
      normalizedCount += 1;
    }
    if (drill.reactionText.trim().isEmpty) {
      drill.reactionText = _generateReaction(
        concept: drill.concept,
        categories: categories,
      );
      normalizedCount += 1;
    }
  }

  final metrics = _scoreDrills(drills);

  await _withReportsWritable(() async {
    await _writeDrills(drills);
    await _writeSummary(drills, metrics, normalizedCount);
    await _appendTelemetry(
      drillsNormalized: normalizedCount,
      avgClarity: metrics.avgClarity,
      avgCoverage: metrics.avgCoverage,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'drill_refinement_normalizer: ${drills.length} drills scanned, '
    '$normalizedCount fields updated.',
  );
}

Future<List<_Drill>> _readDrills() async {
  final file = File(_drillsPath);
  if (!await file.exists()) return const [];
  final drills = <_Drill>[];
  int lineNo = 0;
  for (final raw in await file.readAsLines()) {
    lineNo += 1;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        drills.add(_Drill.fromJson(decoded));
      }
    } catch (err) {
      stderr.writeln(
        'drill_refinement_normalizer: skipped malformed row $lineNo ($_drillsPath): $err',
      );
    }
  }
  return drills;
}

Future<Map<String, _ConceptMeta>> _readFusionMeta() async {
  final file = File(_fusionMapPath);
  if (!await file.exists()) return const {};
  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, dynamic>) {
      final links = decoded['links'];
      if (links is List) {
        final map = <String, _ConceptMeta>{};
        for (final link in links) {
          if (link is! Map<String, dynamic>) continue;
          final concept = (link['concept'] as String?)?.toLowerCase();
          if (concept == null || concept.isEmpty) continue;
          final modules = link['modules'];
          final categories = <String>{};
          if (modules is List) {
            for (final module in modules) {
              if (module is Map<String, dynamic>) {
                final category = module['category']?.toString();
                if (category != null && category.isNotEmpty) {
                  categories.add(category);
                }
              }
            }
          }
          map[concept] = _ConceptMeta(
            concept: concept,
            categories: categories.toList()..sort(),
          );
        }
        return map;
      }
    }
  } catch (err) {
    stderr.writeln('drill_refinement_normalizer: fusion map parse error: $err');
  }
  return const {};
}

Future<void> _writeDrills(List<_Drill> drills) async {
  final file = File(_drillsPath);
  final sink = file.openWrite();
  for (final drill in drills) {
    sink.writeln(jsonEncode(drill.toJson()));
  }
  await sink.flush();
  await sink.close();
}

String _generateGoal({
  required String? concept,
  required List<String> categories,
  required List<String> modules,
}) {
  final conceptLabel = (concept?.isNotEmpty ?? false)
      ? concept!.trim()
      : 'core fusion';
  final cats = categories.isEmpty
      ? 'multi-lane'
      : categories.take(3).join(', ');
  final moduleSnippet = modules.isEmpty
      ? 'key anchor reps'
      : modules.take(3).join(', ').replaceAll('_', ' ');
  return 'Drive $conceptLabel mastery across $cats lanes by sequencing $moduleSnippet.'
      ' Capture reflections after each rep.';
}

String _generateReaction({
  required String? concept,
  required List<String> categories,
}) {
  final conceptLabel = (concept?.isNotEmpty ?? false)
      ? concept!.trim()
      : 'fusion';
  final laneText = categories.isEmpty ? 'hybrid lanes' : categories.join('/');
  return 'Loved the pressure on $conceptLabel—keep syncing reads across $laneText.';
}

_DrillMetrics _scoreDrills(List<_Drill> drills) {
  if (drills.isEmpty) {
    return const _DrillMetrics(
      avgClarity: 0,
      avgCoverage: 0,
      lowClarity: [],
      lowCoverage: [],
    );
  }
  final scored = <_DrillScore>[];
  for (final drill in drills) {
    final clarity = _clarityScore(drill);
    final coverage = _coverageScore(drill);
    drill.clarity = clarity;
    drill.coverage = coverage;
    scored.add(_DrillScore(drill: drill, clarity: clarity, coverage: coverage));
  }
  final avgClarity =
      scored.fold<double>(0, (sum, value) => sum + value.clarity) /
      drills.length;
  final avgCoverage =
      scored.fold<double>(0, (sum, value) => sum + value.coverage) /
      drills.length;
  final lowClarity = [...scored]
    ..sort((a, b) => a.clarity.compareTo(b.clarity));
  final lowCoverage = [...scored]
    ..sort((a, b) => a.coverage.compareTo(b.coverage));

  return _DrillMetrics(
    avgClarity: double.parse(avgClarity.toStringAsFixed(4)),
    avgCoverage: double.parse(avgCoverage.toStringAsFixed(4)),
    lowClarity: lowClarity.take(5).toList(),
    lowCoverage: lowCoverage.take(5).toList(),
  );
}

double _clarityScore(_Drill drill) {
  final goalLen = drill.goal.length;
  final reactionLen = drill.reactionText.length;
  final goalPart = goalLen == 0 ? 0.0 : min(0.6, goalLen / 160);
  final reactionPart = reactionLen == 0 ? 0.0 : min(0.3, reactionLen / 120);
  final categoryPart = min(0.1, drill.categories.length * 0.02);
  return double.parse(
    (goalPart + reactionPart + categoryPart).toStringAsFixed(4),
  );
}

double _coverageScore(_Drill drill) {
  final modulePart = drill.modules.isEmpty
      ? 0.0
      : min(0.8, drill.modules.length / 80);
  final categoryPart = min(0.2, drill.categories.length * 0.05);
  return double.parse(
    (modulePart + categoryPart).clamp(0.0, 1.0).toStringAsFixed(4),
  );
}

Future<void> _writeSummary(
  List<_Drill> drills,
  _DrillMetrics metrics,
  int normalizedCount,
) async {
  final buffer = StringBuffer()
    ..writeln('DRILL REFINEMENT SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Drills scanned: ${drills.length}')
    ..writeln('Fields normalized: $normalizedCount')
    ..writeln('Average clarity score: ${metrics.avgClarity}')
    ..writeln('Average coverage score: ${metrics.avgCoverage}')
    ..writeln();

  if (metrics.lowClarity.isNotEmpty) {
    buffer
      ..writeln('Lowest clarity drills')
      ..writeln('| Drill | Clarity | Coverage | Concept |')
      ..writeln('|-------|---------|----------|---------|');
    for (final score in metrics.lowClarity) {
      buffer.writeln(
        '| ${score.drill.id} | ${score.clarity.toStringAsFixed(3)} | '
        '${score.coverage.toStringAsFixed(3)} | ${score.drill.concept ?? '-'} |',
      );
    }
    buffer.writeln();
  }

  if (metrics.lowCoverage.isNotEmpty) {
    buffer
      ..writeln('Lowest coverage drills')
      ..writeln('| Drill | Coverage | Modules | Categories |')
      ..writeln('|-------|----------|---------|------------|');
    for (final score in metrics.lowCoverage) {
      buffer.writeln(
        '| ${score.drill.id} | ${score.coverage.toStringAsFixed(3)} | '
        '${score.drill.modules.length} | ${score.drill.categories.join(', ')} |',
      );
    }
    buffer.writeln();
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int drillsNormalized,
  required double avgClarity,
  required double avgCoverage,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'drill_refinement_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'drills_normalized': drillsNormalized,
    'avg_clarity': avgClarity,
    'avg_coverage': avgCoverage,
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
      'drill_refinement_normalizer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _Drill {
  _Drill({
    required this.id,
    required this.concept,
    required this.categories,
    required this.modules,
    required this.goal,
    required this.reactionText,
  });

  final String id;
  final String? concept;
  final List<String> categories;
  final List<String> modules;
  String goal;
  String reactionText;
  double clarity = 0;
  double coverage = 0;

  factory _Drill.fromJson(Map<String, dynamic> json) {
    return _Drill(
      id: json['id']?.toString() ?? 'unknown',
      concept: json['concept']?.toString(),
      categories:
          (json['categories'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      modules:
          (json['modules'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      goal: json['goal']?.toString() ?? '',
      reactionText: json['reaction_text']?.toString() ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'concept': concept,
      'categories': categories,
      'modules': modules,
      'goal': goal,
      'reaction_text': reactionText,
    };
  }
}

class _ConceptMeta {
  const _ConceptMeta({required this.concept, required this.categories});

  final String concept;
  final List<String> categories;
}

class _DrillScore {
  const _DrillScore({
    required this.drill,
    required this.clarity,
    required this.coverage,
  });

  final _Drill drill;
  final double clarity;
  final double coverage;
}

class _DrillMetrics {
  const _DrillMetrics({
    required this.avgClarity,
    required this.avgCoverage,
    required this.lowClarity,
    required this.lowCoverage,
  });

  final double avgClarity;
  final double avgCoverage;
  final List<_DrillScore> lowClarity;
  final List<_DrillScore> lowCoverage;
}
