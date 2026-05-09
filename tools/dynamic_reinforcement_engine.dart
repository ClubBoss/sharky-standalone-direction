import 'dart:convert';
import 'dart:io';

const String _cohesionSummaryPath =
    'release/_reports/adaptive_cohesion_summary.txt';
const String _previousSummaryPath =
    'release/_reports/dynamic_reinforcement_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _outputPath = 'release/_reports/dynamic_reinforcement_summary.txt';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final cohesion = await _parseCohesionSummary();
  final telemetryHistory = await _parseCohesionTelemetry();
  final previousWeights = await _parsePreviousWeights();

  final preIndex =
      cohesion.cohesionIndex ??
      (telemetryHistory.isNotEmpty ? telemetryHistory.last : 0.5);
  final deterioration =
      telemetryHistory.length >= 2 &&
      telemetryHistory.last < telemetryHistory[telemetryHistory.length - 2];

  final imbalance = (cohesion.driftScore ?? 0) - (cohesion.alignmentScore ?? 0);
  final emphasizeBehavioral = imbalance < 0;
  final shiftBase = deterioration ? 0.15 : 0.08;
  final shift = (shiftBase + imbalance.abs() * 0.1).clamp(0.05, 0.2);

  final before =
      previousWeights ?? const _Weights(behavioral: 0.5, visual: 0.5);
  final adjusted = _adjustWeights(
    before: before,
    emphasizeBehavioral: emphasizeBehavioral,
    shift: shift,
  );

  final improvement =
      (adjusted.behavioral - before.behavioral).abs() * 0.1 +
      (deterioration ? 0.05 : 0.02);
  final postIndex = (preIndex + improvement).clamp(0.0, 1.0);
  final delta = postIndex - preIndex;

  await _withReportsWritable(() async {
    await _writeSummary(
      cohesion: cohesion,
      telemetryHistory: telemetryHistory,
      before: before,
      after: adjusted,
      preIndex: preIndex,
      postIndex: postIndex,
      delta: delta,
      deterioration: deterioration,
    );
    await _appendTelemetry(
      preIndex: preIndex,
      postIndex: postIndex,
      delta: delta,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'dynamic_reinforcement_engine: pre=${(preIndex * 100).toStringAsFixed(1)}% '
    'post=${(postIndex * 100).toStringAsFixed(1)}% delta=${(delta * 100).toStringAsFixed(1)}pts',
  );
}

Future<_CohesionData> _parseCohesionSummary() async {
  final file = File(_cohesionSummaryPath);
  if (!await file.exists()) {
    return const _CohesionData();
  }

  final lines = await file.readAsLines();
  final headerRegex = RegExp(
    r'Drift score:\s*([\d.]+)%\s+Alignment score:\s*([\d.]+)%\s+'
    r'Cohesion index:\s*([\d.]+)%\s*\(([^)]+)\)',
  );

  for (final line in lines) {
    final match = headerRegex.firstMatch(line);
    if (match != null) {
      return _CohesionData(
        driftScore: (double.tryParse(match.group(1) ?? '') ?? 0) / 100,
        alignmentScore: (double.tryParse(match.group(2) ?? '') ?? 0) / 100,
        cohesionIndex: (double.tryParse(match.group(3) ?? '') ?? 0) / 100,
        classification: match.group(4)?.trim(),
      );
    }
  }

  return const _CohesionData();
}

Future<List<double>> _parseCohesionTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final indices = <double>[];

  for (final raw in lines) {
    if (raw.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(raw);
    } catch (_) {
      continue;
    }
    if (payload is! Map || payload['event'] != 'adaptive_cohesion_completed') {
      continue;
    }
    final value = (payload['cohesion_index'] as num?)?.toDouble();
    if (value != null) {
      indices.add(value.clamp(0.0, 1.0));
    }
  }

  return indices;
}

Future<_Weights?> _parsePreviousWeights() async {
  final file = File(_previousSummaryPath);
  if (!await file.exists()) return null;
  final lines = await file.readAsLines();
  final regex = RegExp(
    r'Weights after\s*→\s*behavioral:\s*([\d.]+)\s+visual:\s*([\d.]+)',
  );
  for (final line in lines.reversed) {
    final match = regex.firstMatch(line);
    if (match != null) {
      final behavioral = double.tryParse(match.group(1) ?? '');
      final visual = double.tryParse(match.group(2) ?? '');
      if (behavioral != null && visual != null) {
        return _Weights(behavioral: behavioral, visual: visual);
      }
    }
  }
  return null;
}

_Weights _adjustWeights({
  required _Weights before,
  required bool emphasizeBehavioral,
  required double shift,
}) {
  double behavioral = before.behavioral;
  double visual = before.visual;

  if (emphasizeBehavioral) {
    behavioral = (behavioral + shift).clamp(0.3, 0.8);
    visual = (1 - behavioral).clamp(0.2, 0.7);
  } else {
    visual = (visual + shift).clamp(0.3, 0.8);
    behavioral = (1 - visual).clamp(0.2, 0.7);
  }

  final total = behavioral + visual;
  if (total != 0) {
    behavioral /= total;
    visual /= total;
  }

  return _Weights(behavioral: behavioral, visual: visual);
}

Future<void> _writeSummary({
  required _CohesionData cohesion,
  required List<double> telemetryHistory,
  required _Weights before,
  required _Weights after,
  required double preIndex,
  required double postIndex,
  required double delta,
  required bool deterioration,
}) async {
  final trend = deterioration
      ? 'Deteriorating'
      : (telemetryHistory.isEmpty ? 'Unknown' : 'Stable/Improving');

  final buffer = StringBuffer()
    ..writeln('DYNAMIC REINFORCEMENT SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Pre-index: ${(preIndex * 100).toStringAsFixed(1)}% '
      '(${cohesion.classification ?? 'Unknown'})',
    )
    ..writeln(
      'Projected post-index: ${(postIndex * 100).toStringAsFixed(1)}% '
      '(Δ ${(delta * 100).toStringAsFixed(1)} pts)',
    )
    ..writeln('Telemetry trend: $trend')
    ..writeln()
    ..writeln(
      'Weights before → behavioral: ${before.behavioral.toStringAsFixed(2)} '
      'visual: ${before.visual.toStringAsFixed(2)}',
    )
    ..writeln(
      'Weights after  → behavioral: ${after.behavioral.toStringAsFixed(2)} '
      'visual: ${after.visual.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln('Inputs')
    ..writeln('------')
    ..writeln(
      'Drift score: '
      '${((cohesion.driftScore ?? 0) * 100).toStringAsFixed(1)}%',
    )
    ..writeln(
      'Alignment score: '
      '${((cohesion.alignmentScore ?? 0) * 100).toStringAsFixed(1)}%',
    )
    ..writeln(
      'Telemetry samples: '
      '${telemetryHistory.map((v) => (v * 100).toStringAsFixed(1)).join(', ')}',
    )
    ..writeln();

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double preIndex,
  required double postIndex,
  required double delta,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'dynamic_reinforcement_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'pre_index': double.parse(preIndex.toStringAsFixed(3)),
    'post_index': double.parse(postIndex.toStringAsFixed(3)),
    'delta': double.parse(delta.toStringAsFixed(3)),
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
      'dynamic_reinforcement_engine: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _CohesionData {
  const _CohesionData({
    this.driftScore,
    this.alignmentScore,
    this.cohesionIndex,
    this.classification,
  });

  final double? driftScore;
  final double? alignmentScore;
  final double? cohesionIndex;
  final String? classification;
}

class _Weights {
  const _Weights({required this.behavioral, required this.visual});

  final double behavioral;
  final double visual;
}
