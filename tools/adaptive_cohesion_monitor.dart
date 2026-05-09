import 'dart:convert';
import 'dart:io';

const String _personalizationPath =
    'release/_reports/personalization_drift_summary.txt';
const String _visualAlignmentPath =
    'release/_reports/ai_visual_alignment_summary.txt';
const String _outputPath = 'release/_reports/adaptive_cohesion_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final driftData = await _parseDriftSummary();
  final visualData = await _parseVisualSummary();

  final driftScore = (1 - (driftData.avgDriftPercent ?? 100) / 100).clamp(
    0.0,
    1.0,
  );
  final alignmentScore = ((visualData.alignmentPercent ?? 0) / 100).clamp(
    0.0,
    1.0,
  );
  final cohesionIndex = ((driftScore + alignmentScore) / 2).clamp(0.0, 1.0);
  final verdict = _classify(cohesionIndex);

  await _withReportsWritable(() async {
    await _writeSummary(
      driftData: driftData,
      visualData: visualData,
      driftScore: driftScore,
      alignmentScore: alignmentScore,
      cohesionIndex: cohesionIndex,
      verdict: verdict,
    );
    await _appendTelemetry(
      driftScore: driftScore,
      alignmentScore: alignmentScore,
      cohesionIndex: cohesionIndex,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_cohesion_monitor: drift=${(driftScore * 100).toStringAsFixed(1)}% '
    'alignment=${(alignmentScore * 100).toStringAsFixed(1)}% '
    'cohesion=${(cohesionIndex * 100).toStringAsFixed(1)}% ($verdict)',
  );
}

Future<_DriftData> _parseDriftSummary() async {
  final file = File(_personalizationPath);
  if (!await file.exists()) {
    return const _DriftData();
  }

  final lines = await file.readAsLines();
  double? avgDriftPercent;
  double? stabilityIndex;
  String? classification;

  final avgRegex = RegExp(r'Average drift:\s*([\d.]+)%');
  final stabilityRegex = RegExp(r'Stability index:\s*([\d.]+)\s*\(([^)]+)\)');

  for (final line in lines) {
    final avgMatch = avgRegex.firstMatch(line);
    if (avgMatch != null) {
      avgDriftPercent = double.tryParse(avgMatch.group(1) ?? '');
    }
    final stabilityMatch = stabilityRegex.firstMatch(line);
    if (stabilityMatch != null) {
      stabilityIndex = double.tryParse(stabilityMatch.group(1) ?? '');
      classification = stabilityMatch.group(2)?.trim();
    }
  }

  return _DriftData(
    avgDriftPercent: avgDriftPercent,
    stabilityIndex: stabilityIndex,
    classification: classification,
  );
}

Future<_VisualData> _parseVisualSummary() async {
  final file = File(_visualAlignmentPath);
  if (!await file.exists()) {
    return const _VisualData();
  }

  final lines = await file.readAsLines();
  double? alignmentPercent;
  double? biasRatio;

  final alignmentRegex = RegExp(
    r'Alignment:\s*([\d.]+)%\s+Bias ratio:\s*([\d.]+)',
  );

  for (final line in lines) {
    final match = alignmentRegex.firstMatch(line);
    if (match != null) {
      alignmentPercent = double.tryParse(match.group(1) ?? '');
      biasRatio = double.tryParse(match.group(2) ?? '');
      break;
    }
  }

  return _VisualData(alignmentPercent: alignmentPercent, biasRatio: biasRatio);
}

String _classify(double cohesionIndex) {
  if (cohesionIndex >= 0.8) return 'COHERENT';
  if (cohesionIndex >= 0.6) return 'PARTIAL';
  return 'DIVERGENT';
}

Future<void> _writeSummary({
  required _DriftData driftData,
  required _VisualData visualData,
  required double driftScore,
  required double alignmentScore,
  required double cohesionIndex,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE COHESION SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Drift score: ${(driftScore * 100).toStringAsFixed(1)}%   '
      'Alignment score: ${(alignmentScore * 100).toStringAsFixed(1)}%   '
      'Cohesion index: ${(cohesionIndex * 100).toStringAsFixed(1)}% ($verdict)',
    )
    ..writeln()
    ..writeln('Behavioral Drift Input')
    ..writeln('----------------------')
    ..writeln(
      'Average drift: '
      '${(driftData.avgDriftPercent ?? double.nan).toStringAsFixedSafe(1)}%',
    )
    ..writeln(
      'Stability index: '
      '${(driftData.stabilityIndex ?? double.nan).toStringAsFixedSafe(2)} '
      '(${driftData.classification ?? 'Unknown'})',
    )
    ..writeln()
    ..writeln('Visual Alignment Input')
    ..writeln('----------------------')
    ..writeln(
      'Alignment: '
      '${(visualData.alignmentPercent ?? double.nan).toStringAsFixedSafe(1)}%',
    )
    ..writeln(
      'Bias ratio: '
      '${(visualData.biasRatio ?? double.nan).toStringAsFixedSafe(2)}',
    )
    ..writeln();

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double driftScore,
  required double alignmentScore,
  required double cohesionIndex,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_cohesion_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'drift_score': double.parse(driftScore.toStringAsFixed(3)),
    'alignment_score': double.parse(alignmentScore.toStringAsFixed(3)),
    'cohesion_index': double.parse(cohesionIndex.toStringAsFixed(3)),
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'adaptive_cohesion_monitor: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _DriftData {
  const _DriftData({
    this.avgDriftPercent,
    this.stabilityIndex,
    this.classification,
  });

  final double? avgDriftPercent;
  final double? stabilityIndex;
  final String? classification;
}

class _VisualData {
  const _VisualData({this.alignmentPercent, this.biasRatio});

  final double? alignmentPercent;
  final double? biasRatio;
}

extension on double {
  String toStringAsFixedSafe(int fractionDigits) {
    if (isNaN) return 'n/a';
    return toStringAsFixed(fractionDigits);
  }
}
