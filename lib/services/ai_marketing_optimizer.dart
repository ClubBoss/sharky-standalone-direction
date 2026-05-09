import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final optimizer = AiMarketingOptimizer();
  await optimizer.run();
}

class AiMarketingOptimizer {
  AiMarketingOptimizer({
    this.abSummaryPath = 'release/_reports/ab_experiment_summary.txt',
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.summaryPath = 'release/_reports/marketing_optimizer_summary.txt',
    this.telemetryOutputPath = 'release/_reports/telemetry.jsonl',
  });

  final String abSummaryPath;
  final String telemetryPath;
  final String summaryPath;
  final String telemetryOutputPath;

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final abSnapshot = await _loadAbSnapshot();
    final telemetrySamples = await _loadTelemetrySamples();
    if (telemetrySamples.isEmpty) {
      throw StateError(
        'ai_marketing_optimizer: no A/B telemetry samples found.',
      );
    }

    final model = _RegressionModel.from(telemetrySamples);
    final ewma = _ewma(
      telemetrySamples.map((sample) => sample.retentionDelta),
      alpha: 0.4,
    );
    final predictedRetention =
        model.predict(abSnapshot.engagementDelta) * 0.7 + ewma * 0.3;
    final verdict = _verdict(predictedRetention, abSnapshot.retentionDelta);

    await _withReportsWritable(() async {
      await _writeSummary(
        snapshot: abSnapshot,
        samples: telemetrySamples,
        model: model,
        ewma: ewma,
        predictedRetention: predictedRetention,
        verdict: verdict,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        snapshot: abSnapshot,
        model: model,
        ewma: ewma,
        predictedRetention: predictedRetention,
        verdict: verdict,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    stdout.writeln(
      'ai_marketing_optimizer: samples=${telemetrySamples.length} '
      'predicted_retention=${_round(predictedRetention)}%',
    );
  }

  Future<_AbSnapshot> _loadAbSnapshot() async {
    final file = File(abSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing A/B summary at $abSummaryPath');
    }
    final lines = await file.readAsLines();
    double? retentionDelta;
    double? engagementDelta;
    double? completionDelta;
    for (final line in lines) {
      final trimmed = line.trim();
      final retentionMatch = _deltaRegex['retention']!.firstMatch(trimmed);
      if (retentionMatch != null) {
        retentionDelta = double.parse(retentionMatch.group(1)!);
        continue;
      }
      final engagementMatch = _deltaRegex['engagement']!.firstMatch(trimmed);
      if (engagementMatch != null) {
        engagementDelta = double.parse(engagementMatch.group(1)!);
        continue;
      }
      final completionMatch = _deltaRegex['completion']!.firstMatch(trimmed);
      if (completionMatch != null) {
        completionDelta = double.parse(completionMatch.group(1)!);
      }
    }
    if (retentionDelta == null || engagementDelta == null) {
      throw StateError(
        'ai_marketing_optimizer: unable to parse deltas from $abSummaryPath',
      );
    }
    return _AbSnapshot(
      retentionDelta: retentionDelta,
      engagementDelta: engagementDelta,
      completionDelta: completionDelta ?? 0,
    );
  }

  Future<List<_TelemetrySample>> _loadTelemetrySamples() async {
    final file = File(telemetryPath);
    if (!await file.exists()) {
      throw StateError('Telemetry stream missing at $telemetryPath');
    }
    final samples = <_TelemetrySample>[];
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
      if (payload['event']?.toString() != 'ab_experiment_completed') continue;
      final engagement = _toDouble(payload['delta_engagement']);
      final retention = _toDouble(payload['delta_retention']);
      if (engagement == null || retention == null) continue;
      samples.add(
        _TelemetrySample(
          timestamp: payload['timestamp']?.toString() ?? '',
          engagementDelta: engagement,
          retentionDelta: retention,
        ),
      );
    }
    return samples;
  }

  Future<void> _writeSummary({
    required _AbSnapshot snapshot,
    required List<_TelemetrySample> samples,
    required _RegressionModel model,
    required double ewma,
    required double predictedRetention,
    required String verdict,
    required int durationMs,
  }) async {
    final buffer = StringBuffer()
      ..writeln('AI MARKETING OPTIMIZER')
      ..writeln('======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Samples processed: ${samples.length}')
      ..writeln()
      ..writeln('Latest experiment deltas (B - A):')
      ..writeln('- ΔRetention : ${_formatPercent(snapshot.retentionDelta)}')
      ..writeln('- ΔEngagement: ${_formatPercent(snapshot.engagementDelta)}')
      ..writeln('- ΔCompletion: ${_formatPercent(snapshot.completionDelta)}')
      ..writeln()
      ..writeln(
        'Model weights (Retention Δ = intercept + weight * Engagement Δ):',
      )
      ..writeln('- intercept: ${_round(model.intercept)}')
      ..writeln('- weight   : ${_round(model.weight)}')
      ..writeln('- ewma(retention): ${_round(ewma)}')
      ..writeln()
      ..writeln(
        'Predicted retention gain: ${_formatPercent(predictedRetention)}',
      )
      ..writeln('Recommended action: $verdict')
      ..writeln();

    await File(summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry({
    required _AbSnapshot snapshot,
    required _RegressionModel model,
    required double ewma,
    required double predictedRetention,
    required String verdict,
    required int durationMs,
  }) async {
    final payload = <String, Object?>{
      'event': 'marketing_optimizer_updated',
      'timestamp': DateTime.now().toIso8601String(),
      'latest_retention_delta': snapshot.retentionDelta,
      'latest_engagement_delta': snapshot.engagementDelta,
      'model': {
        'intercept': model.intercept,
        'weight': model.weight,
        'ewma_retention': ewma,
      },
      'predicted_retention_delta': predictedRetention,
      'recommended_action': verdict,
      'duration_ms': durationMs,
    };

    await File(telemetryOutputPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _AbSnapshot {
  const _AbSnapshot({
    required this.retentionDelta,
    required this.engagementDelta,
    required this.completionDelta,
  });

  final double retentionDelta;
  final double engagementDelta;
  final double completionDelta;
}

class _TelemetrySample {
  const _TelemetrySample({
    required this.timestamp,
    required this.engagementDelta,
    required this.retentionDelta,
  });

  final String timestamp;
  final double engagementDelta;
  final double retentionDelta;
}

class _RegressionModel {
  const _RegressionModel({required this.intercept, required this.weight});

  factory _RegressionModel.from(List<_TelemetrySample> samples) {
    if (samples.length < 2) {
      final sample = samples.isEmpty ? null : samples.first;
      final weight = sample == null || sample.engagementDelta == 0
          ? 0.0
          : sample.retentionDelta / sample.engagementDelta;
      return _RegressionModel(intercept: 0, weight: weight);
    }

    final xs = samples.map((s) => s.engagementDelta).toList();
    final ys = samples.map((s) => s.retentionDelta).toList();
    final meanX = xs.reduce((a, b) => a + b) / xs.length;
    final meanY = ys.reduce((a, b) => a + b) / ys.length;

    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < xs.length; i++) {
      final dx = xs[i] - meanX;
      final dy = ys[i] - meanY;
      numerator += dx * dy;
      denominator += dx * dx;
    }
    final weight = denominator == 0 ? 0.0 : numerator / denominator;
    final intercept = meanY - (weight * meanX);

    return _RegressionModel(intercept: intercept, weight: weight);
  }

  final double intercept;
  final double weight;

  double predict(double engagementDelta) =>
      intercept + (weight * engagementDelta);
}

double _ewma(Iterable<double> values, {required double alpha}) {
  var initialized = false;
  var current = 0.0;
  for (final value in values) {
    if (!initialized) {
      current = value;
      initialized = true;
    } else {
      current = alpha * value + (1 - alpha) * current;
    }
  }
  return current;
}

String _verdict(double predictedRetention, double latestRetention) {
  if (predictedRetention >= latestRetention + 0.5) {
    return 'Scale variant B incentives';
  }
  if (predictedRetention <= -0.5) {
    return 'Pause aggressive engagement pushes';
  }
  return 'Maintain current allocation';
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

final Map<String, RegExp> _deltaRegex = <String, RegExp>{
  'retention': RegExp(r'ΔRetention\s*:\s*([+-]?\d+(?:\.\d+)?)%'),
  'engagement': RegExp(r'ΔEngagement:\s*([+-]?\d+(?:\.\d+)?)%'),
  'completion': RegExp(r'ΔCompletion:\s*([+-]?\d+(?:\.\d+)?)%'),
};

String _formatPercent(double value) {
  final rounded = _round(value);
  final sign = rounded >= 0 ? '+' : '';
  return '$sign$rounded%';
}

double _round(double value) => value.isNaN || value.isInfinite
    ? 0
    : double.parse(value.toStringAsFixed(2));

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
