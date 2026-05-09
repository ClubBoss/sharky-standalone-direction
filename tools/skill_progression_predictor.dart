import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath = 'release/_reports/skill_progression_summary.txt';
const String _telemetryOut = 'release/_reports/telemetry.jsonl';
const double _targetAccuracy = 0.85;
const double _ewmaAlpha = 0.5;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final topicSamples = await _collectSamples();
  if (topicSamples.isEmpty) {
    await _withReportsWritable(() async {
      await File(_summaryPath).writeAsString(
        'SKILL PROGRESSION SUMMARY\n'
        '========================\n'
        'Generated: ${DateTime.now().toIso8601String()}\n'
        'Duration: ${stopwatch.elapsedMilliseconds}ms\n'
        '\n'
        'No telemetry samples with accuracy/topic were found.\n',
      );
    });
    stdout.writeln(
      'skill_progression_predictor: skipped (no telemetry samples).',
    );
    return;
  }

  final forecasts = <_TopicForecast>[];
  topicSamples.forEach((topic, samples) {
    final ewma = _ewma(samples.map((e) => e.accuracy).toList());
    final slope = _trendSlope(samples.map((e) => e.accuracy).toList());
    final speedEwma = _ewma(samples.map((e) => e.speedMs.toDouble()).toList());
    final double stepsNeeded = slope <= 0
        ? double.infinity
        : max<double>(0, (_targetAccuracy - ewma) / slope);
    final forecast = _TopicForecast(
      topic: topic,
      currentAccuracy: ewma,
      speedMs: speedEwma,
      slope: slope,
      sessionsToMaster: stepsNeeded.isInfinite ? null : stepsNeeded,
    );
    forecasts.add(forecast);
  });

  forecasts.sort(
    (a, b) => (a.sessionsToMaster ?? double.infinity).compareTo(
      b.sessionsToMaster ?? double.infinity,
    ),
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      forecasts: forecasts,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _emitTelemetry(
      forecasts: forecasts,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln('skill_progression_predictor: topics=${forecasts.length}');
}

Future<Map<String, List<_Sample>>> _collectSamples() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const {};
  final map = <String, List<_Sample>>{};
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(line);
    } catch (_) {
      continue;
    }
    if (payload is! Map<String, dynamic>) continue;
    final topic = payload['topic']?.toString();
    final accuracy = _toDouble(payload['accuracy']);
    final speedMs = _toDouble(payload['speed_ms']) ?? 4000.0;
    final timestamp = payload['timestamp']?.toString();
    if (topic == null || accuracy == null || timestamp == null) continue;
    map
        .putIfAbsent(topic, () => <_Sample>[])
        .add(
          _Sample(
            accuracy: accuracy,
            speedMs: speedMs,
            timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
          ),
        );
  }

  for (final entry in map.entries) {
    entry.value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  return map;
}

double _ewma(List<double> values) {
  if (values.isEmpty) return 0;
  var result = values.first;
  for (var i = 1; i < values.length; i++) {
    result = _ewmaAlpha * values[i] + (1 - _ewmaAlpha) * result;
  }
  return result;
}

double _trendSlope(List<double> values) {
  if (values.length < 2) return 0;
  final mean = values.reduce((a, b) => a + b) / values.length;
  double numerator = 0;
  double denominator = 0;
  for (var i = 0; i < values.length; i++) {
    final x = i - ((values.length - 1) / 2);
    numerator += x * (values[i] - mean);
    denominator += x * x;
  }
  if (denominator == 0) return 0;
  return numerator / denominator / max(1, values.length / 2);
}

Future<void> _writeSummary({
  required List<_TopicForecast> forecasts,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('SKILL PROGRESSION SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Target accuracy: ${(_targetAccuracy * 100).toStringAsFixed(1)}%')
    ..writeln()
    ..writeln('Top forecasts:');

  if (forecasts.isEmpty) {
    buffer.writeln('- No topics with telemetry samples.');
  } else {
    for (final forecast in forecasts.take(10)) {
      buffer
        ..writeln(
          '- ${forecast.topic}: '
          'acc=${(forecast.currentAccuracy * 100).toStringAsFixed(1)}% '
          'slope=${forecast.slope.toStringAsFixed(3)} '
          'eta=${forecast.sessionsToMaster == null ? '∞' : forecast.sessionsToMaster!.toStringAsFixed(1)} sessions',
        )
        ..writeln('  speed=${forecast.speedMs.toStringAsFixed(0)}ms');
    }
  }

  await File(_summaryPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry({
  required List<_TopicForecast> forecasts,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'skill_progression_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'topics': forecasts
        .map(
          (forecast) => {
            'topic': forecast.topic,
            'current_accuracy': forecast.currentAccuracy,
            'slope': forecast.slope,
            'eta_sessions': forecast.sessionsToMaster,
          },
        )
        .toList(),
    'duration_ms': durationMs,
  };

  await File(_telemetryOut).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _Sample {
  const _Sample({
    required this.accuracy,
    required this.speedMs,
    required this.timestamp,
  });

  final double accuracy;
  final double speedMs;
  final DateTime timestamp;
}

class _TopicForecast {
  const _TopicForecast({
    required this.topic,
    required this.currentAccuracy,
    required this.speedMs,
    required this.slope,
    required this.sessionsToMaster,
  });

  final String topic;
  final double currentAccuracy;
  final double speedMs;
  final double slope;
  final double? sessionsToMaster;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
