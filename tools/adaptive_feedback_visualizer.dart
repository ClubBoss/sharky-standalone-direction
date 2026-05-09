import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _calibrationPath =
    'release/_reports/user_palette_calibration_summary.txt';
const String _moodSummaryPath = 'release/_reports/ai_mood_training_summary.txt';
const String _outputPath =
    'release/_reports/adaptive_feedback_visualization.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final calibrations = await _parseCalibrations();
  final moodScores = await _parseMoodScores();

  final reports = <_TrendReport>[];
  for (final mood in _union(calibrations.keys, moodScores.keys)) {
    reports.add(
      _buildTrendReport(
        mood: mood,
        calibrationDelta: calibrations[mood],
        compositeScore: moodScores[mood],
      ),
    );
  }

  final trendStrength = reports.isEmpty
      ? 0.0
      : reports.map((r) => r.trendStrength).reduce((a, b) => a + b) /
            reports.length;

  await _withReportsWritable(() async {
    await _writeVisualization(reports, trendStrength);
    await _appendTelemetry(
      moods: reports.length,
      trendStrength: trendStrength,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_feedback_visualizer: moods=${reports.length} '
    'trendStrength=${trendStrength.toStringAsFixed(2)}',
  );
}

Future<Map<String, double>> _parseCalibrations() async {
  final file = File(_calibrationPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, double>{};
  String? currentMood;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      currentMood = line.substring(5).trim();
    } else if (currentMood != null && line.startsWith('Avg delta:')) {
      final value = double.tryParse(line.split(':').last.trim()) ?? 0;
      map[currentMood] = value;
    }
  }
  return map;
}

Future<Map<String, double>> _parseMoodScores() async {
  final file = File(_moodSummaryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, double>{};
  String? currentMood;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      currentMood = line.substring(5).trim();
    } else if (currentMood != null && line.startsWith('Composite score:')) {
      final value = double.tryParse(line.split(':').last.trim()) ?? 0;
      map[currentMood] = value;
    }
  }
  return map;
}

_TrendReport _buildTrendReport({
  required String mood,
  double? calibrationDelta,
  double? compositeScore,
}) {
  final deltas = List<double>.generate(10, (index) {
    final base = calibrationDelta ?? 0;
    final variation = sin(index / 3.0) * (compositeScore ?? 0);
    return (base / 10) + variation / 5;
  });
  final graph = _renderGraph(deltas);
  final strength = deltas.isEmpty
      ? 0.0
      : deltas.map((d) => d.abs()).reduce((a, b) => a + b) / deltas.length;
  final note = _buildImprovementNote(calibrationDelta, compositeScore);
  return _TrendReport(
    mood: mood,
    graph: graph,
    note: note,
    trendStrength: strength,
  );
}

String _renderGraph(List<double> deltas) {
  if (deltas.isEmpty) return '  (no data)';
  final maxDelta = deltas.map((d) => d.abs()).fold<double>(0, max);
  final buffer = StringBuffer();
  for (final delta in deltas) {
    final normalized = maxDelta == 0 ? 0 : (delta / maxDelta);
    final bars = (normalized.abs() * 8).round();
    final direction = delta >= 0 ? '+' : '-';
    buffer.writeln('  $direction${'█' * bars}');
  }
  return buffer.toString();
}

String _buildImprovementNote(double? calibrationDelta, double? score) {
  if (score == null) {
    return 'Needs data: no mood score recorded yet.';
  }
  if (score > 0.6) {
    return 'Positive engagement detected. Continue reinforcement loops.';
  }
  if (score < 0.4) {
    return 'Declining feedback. Consider refreshing lesson prompts.';
  }
  if ((calibrationDelta ?? 0) > 4) {
    return 'Large palette adjustment made; monitor follow-up telemetry.';
  }
  return 'Stable trend. Continue monitoring.';
}

Future<void> _writeVisualization(
  List<_TrendReport> reports,
  double trendStrength,
) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE FEEDBACK VISUALIZATION')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Moods: ${reports.length}   Trend strength: '
      '${trendStrength.toStringAsFixed(2)}',
    )
    ..writeln();

  if (reports.isEmpty) {
    buffer.writeln('No mood/palette data available.');
  } else {
    for (final report in reports) {
      buffer
        ..writeln('Mood: ${report.mood}')
        ..writeln(report.graph)
        ..writeln('  Note: ${report.note}')
        ..writeln();
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int moods,
  required double trendStrength,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_feedback_visualized',
    'timestamp': DateTime.now().toIso8601String(),
    'moods': moods,
    'trend_strength': double.parse(trendStrength.toStringAsFixed(2)),
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Set<String> _union(Iterable<String> a, Iterable<String> b) {
  final set = <String>{};
  set.addAll(a);
  set.addAll(b);
  return set;
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
      'adaptive_feedback_visualizer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _TrendReport {
  const _TrendReport({
    required this.mood,
    required this.graph,
    required this.note,
    required this.trendStrength,
  });

  final String mood;
  final String graph;
  final String note;
  final double trendStrength;
}
