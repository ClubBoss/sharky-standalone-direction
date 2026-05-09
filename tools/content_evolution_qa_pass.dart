import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _semanticSummaryPath =
    '$_reportsDir/semantic_drill_enhancer_summary.txt';
const String _schemaSummaryPath =
    '$_reportsDir/content_schema_validator_summary.txt';
const String _summaryTextPath = '$_reportsDir/content_evolution_qa_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/content_evolution_qa_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _schemaWeight = 0.35;
const double _semanticWeight = 0.35;
const double _drillWeight = 0.30;
const double _minPassingScore = 90.0;

Future<void> main(List<String> args) async {
  final pass = ContentEvolutionQaPass();
  final ok = await pass.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ContentEvolutionQaPass {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final schema = await _evaluateSchema();
    final semantic = await _evaluateSemantic();
    final drill = await _evaluateDrillDepth();

    final weightedScore = _computeWeightedScore(
      schemaScore: schema.score,
      semanticScore: semantic.score,
      drillScore: drill.score,
    );
    final pass = weightedScore >= _minPassingScore;

    final summaryText = _buildTextSummary(
      schema: schema,
      semantic: semantic,
      drill: drill,
      score: weightedScore,
      durationMs: stopwatch.elapsedMilliseconds,
      pass: pass,
    );
    final summaryJson = _buildJsonSummary(
      schema: schema,
      semantic: semantic,
      drill: drill,
      score: weightedScore,
      durationMs: stopwatch.elapsedMilliseconds,
      pass: pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        schema: schema,
        semantic: semantic,
        drill: drill,
        score: weightedScore,
        durationMs: stopwatch.elapsedMilliseconds,
        pass: pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Content Evolution Score ${weightedScore.toStringAsFixed(2)}% below '
        '${_minPassingScore.toStringAsFixed(0)}% threshold.',
      );
    }

    return pass;
  }

  double _computeWeightedScore({
    required double schemaScore,
    required double semanticScore,
    required double drillScore,
  }) {
    final totalWeight = _schemaWeight + _semanticWeight + _drillWeight;
    final weighted =
        (schemaScore * _schemaWeight) +
        (semanticScore * _semanticWeight) +
        (drillScore * _drillWeight);
    return totalWeight == 0 ? 0 : weighted / totalWeight;
  }

  Future<_SchemaResult> _evaluateSchema() async {
    final file = File(_schemaSummaryPath);
    if (!await file.exists()) {
      return const _SchemaResult(
        score: 0,
        modulesChecked: 0,
        conforming: false,
      );
    }
    final lines = await file.readAsLines();
    int modulesChecked = 0;
    bool conforming = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Modules checked:')) {
        modulesChecked =
            int.tryParse(trimmed.split(':').last.trim().split(' ').first) ?? 0;
      }
      if (trimmed.contains('All modules conform')) {
        conforming = true;
      }
      if (trimmed.contains('Violations') || trimmed.contains('FAILED')) {
        conforming = false;
      }
    }
    final score = conforming ? 100.0 : 70.0;
    return _SchemaResult(
      score: score,
      modulesChecked: modulesChecked,
      conforming: conforming,
    );
  }

  Future<_SemanticResult> _evaluateSemantic() async {
    final file = File(_semanticSummaryPath);
    if (!await file.exists()) {
      return const _SemanticResult(
        score: 0,
        enhancements: 0,
        averageUplift: 0,
        targetUplift: 0,
      );
    }
    final lines = await file.readAsLines();
    int enhancements = 0;
    double avgUplift = 0;
    double target = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Enhancements:')) {
        enhancements =
            int.tryParse(trimmed.split(':').last.trim().split(' ').first) ?? 0;
      }
      if (trimmed.startsWith('Average EV uplift:')) {
        final parts = trimmed.split(':').last.trim().split('(target');
        if (parts.isNotEmpty) {
          avgUplift =
              double.tryParse(parts.first.replaceAll('%', '').trim()) ?? 0;
        }
        final targetMatch = RegExp(r'target\s*([0-9.]+)').firstMatch(trimmed);
        if (targetMatch != null) {
          target = double.tryParse(targetMatch.group(1) ?? '') ?? 0;
        }
      }
    }
    final targetValue = target <= 0 ? 10.0 : target;
    final upliftRatio = (avgUplift / targetValue).clamp(0.0, 1.2);
    final coverageRatio = (enhancements / 250).clamp(0.0, 1.0);
    final normalizedScore = ((upliftRatio / 1.2) * 0.6) + (coverageRatio * 0.4);
    return _SemanticResult(
      score: (normalizedScore.clamp(0.0, 1.0)) * 100,
      enhancements: enhancements,
      averageUplift: avgUplift,
      targetUplift: targetValue,
    );
  }

  Future<_DrillResult> _evaluateDrillDepth() async {
    final packs = await _scanContentPacks();
    if (packs.isEmpty) {
      return const _DrillResult(
        score: 0,
        totalPacks: 0,
        totalDrills: 0,
        averageDifficulty: 0,
        packs: [],
      );
    }
    final totalDrills = packs.fold<int>(
      0,
      (sum, pack) => sum + pack.drillCount,
    );
    final totalDifficulty = packs.fold<double>(
      0,
      (sum, pack) => sum + (pack.avgDifficulty * pack.drillCount),
    );
    final avgDifficulty = totalDrills == 0
        ? 0.0
        : (totalDifficulty / totalDrills).clamp(0.0, 1.0).toDouble();
    final coverageRatio = (totalDrills / 400).clamp(0.0, 1.0).toDouble();
    final depthRatio = avgDifficulty;
    final normalizedScore = (depthRatio * 0.7) + (coverageRatio * 0.3);
    return _DrillResult(
      score: normalizedScore * 100,
      totalPacks: packs.length,
      totalDrills: totalDrills,
      averageDifficulty: avgDifficulty,
      packs: packs,
    );
  }

  Future<List<_ContentPack>> _scanContentPacks() async {
    final contentDir = Directory('content');
    if (!await contentDir.exists()) return const [];
    final packs = <_ContentPack>[];
    await for (final entity in contentDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! Directory) continue;
      if (!entity.path.endsWith('${Platform.pathSeparator}v1')) continue;
      final name = _inferPackName(entity.path);
      final drillsFile = File('${entity.path}/drills.jsonl');
      final summary = await _summarizeDrills(drillsFile);
      packs.add(
        _ContentPack(
          name: name,
          path: entity.path,
          drillCount: summary.count,
          avgDifficulty: summary.avgDifficulty,
        ),
      );
    }
    return packs;
  }

  String _inferPackName(String path) {
    final segments = path.split(Platform.pathSeparator);
    if (segments.length >= 2) {
      return segments[segments.length - 2];
    }
    return path;
  }

  Future<_DrillSummary> _summarizeDrills(File file) async {
    if (!await file.exists()) {
      return const _DrillSummary(count: 0, avgDifficulty: 0.5);
    }
    try {
      final lines = await file.readAsLines();
      double totalDifficulty = 0;
      int count = 0;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map<String, Object?>) {
            final difficulty =
                (decoded['difficulty'] as num?)?.toDouble() ?? double.nan;
            if (difficulty.isFinite) {
              totalDifficulty += difficulty.clamp(0, 1).toDouble();
              count++;
            }
          }
        } catch (_) {
          // ignore malformed rows
        }
      }
      if (count == 0) {
        return const _DrillSummary(count: 0, avgDifficulty: 0.5);
      }
      return _DrillSummary(
        count: count,
        avgDifficulty: (totalDifficulty / count).clamp(0.0, 1.0),
      );
    } catch (_) {
      return const _DrillSummary(count: 0, avgDifficulty: 0.5);
    }
  }

  String _buildTextSummary({
    required _SchemaResult schema,
    required _SemanticResult semantic,
    required _DrillResult drill,
    required double score,
    required int durationMs,
    required bool pass,
  }) {
    final buffer = StringBuffer()
      ..writeln('CONTENT EVOLUTION QA SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Evolution Score: ${score.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minPassingScore.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Metric Breakdown:')
      ..writeln(
        '- Schema validity: ${schema.score.toStringAsFixed(2)}% '
        '(${schema.modulesChecked} modules, '
        '${schema.conforming ? 'all conforming' : 'issues detected'})',
      )
      ..writeln(
        '- Semantic coverage: ${semantic.score.toStringAsFixed(2)}% '
        '(enhancements=${semantic.enhancements}, '
        'avg uplift=${semantic.averageUplift.toStringAsFixed(2)}%)',
      )
      ..writeln(
        '- Drill depth: ${drill.score.toStringAsFixed(2)}% '
        '(packs=${drill.totalPacks}, drills=${drill.totalDrills}, '
        'avg difficulty=${(drill.averageDifficulty * 100).toStringAsFixed(1)}%)',
      )
      ..writeln()
      ..writeln('Top content packs by drill count:');
    final rankedPacks = drill.packs.where((p) => p.drillCount > 0).toList()
      ..sort((a, b) => b.drillCount.compareTo(a.drillCount));
    if (rankedPacks.isEmpty) {
      buffer.writeln('  - No content packs detected under content/**/v1');
    } else {
      for (final pack in rankedPacks.take(5)) {
        buffer.writeln(
          '  - ${pack.name}: drills=${pack.drillCount}, '
          'avg difficulty=${(pack.avgDifficulty * 100).toStringAsFixed(1)}%',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required _SchemaResult schema,
    required _SemanticResult semantic,
    required _DrillResult drill,
    required double score,
    required int durationMs,
    required bool pass,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'duration_ms': durationMs,
      'evolution_score': score,
      'threshold': _minPassingScore,
      'verdict': pass ? 'PASS' : 'FAIL',
      'metrics': {
        'schema_validity': {
          'score': schema.score,
          'modules_checked': schema.modulesChecked,
          'conforming': schema.conforming,
        },
        'semantic_coverage': {
          'score': semantic.score,
          'enhancements': semantic.enhancements,
          'average_uplift': semantic.averageUplift,
          'target_uplift': semantic.targetUplift,
        },
        'drill_depth': {
          'score': drill.score,
          'total_packs': drill.totalPacks,
          'total_drills': drill.totalDrills,
          'average_difficulty': drill.averageDifficulty,
        },
      },
      'packs': drill.packs
          .map(
            (pack) => {
              'name': pack.name,
              'path': pack.path,
              'drills': pack.drillCount,
              'average_difficulty': pack.avgDifficulty,
            },
          )
          .toList(),
    };
  }

  Future<void> _appendTelemetry({
    required _SchemaResult schema,
    required _SemanticResult semantic,
    required _DrillResult drill,
    required double score,
    required int durationMs,
    required bool pass,
  }) async {
    final payload = <String, Object?>{
      'event': 'content_evolution_qa_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'score': score,
      'threshold': _minPassingScore,
      'verdict': pass ? 'PASS' : 'FAIL',
      'duration_ms': durationMs,
      'schema_score': schema.score,
      'semantic_score': semantic.score,
      'drill_score': drill.score,
      'packs_evaluated': drill.totalPacks,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _SchemaResult {
  const _SchemaResult({
    required this.score,
    required this.modulesChecked,
    required this.conforming,
  });

  final double score;
  final int modulesChecked;
  final bool conforming;
}

class _SemanticResult {
  const _SemanticResult({
    required this.score,
    required this.enhancements,
    required this.averageUplift,
    required this.targetUplift,
  });

  final double score;
  final int enhancements;
  final double averageUplift;
  final double targetUplift;
}

class _DrillResult {
  const _DrillResult({
    required this.score,
    required this.totalPacks,
    required this.totalDrills,
    required this.averageDifficulty,
    required this.packs,
  });

  final double score;
  final int totalPacks;
  final int totalDrills;
  final double averageDifficulty;
  final List<_ContentPack> packs;
}

class _ContentPack {
  const _ContentPack({
    required this.name,
    required this.path,
    required this.drillCount,
    required this.avgDifficulty,
  });

  final String name;
  final String path;
  final int drillCount;
  final double avgDifficulty;
}

class _DrillSummary {
  const _DrillSummary({required this.count, required this.avgDifficulty});

  final int count;
  final double avgDifficulty;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore if chmod fails
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}
