import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final tuner = AdaptiveRewardTuner();
  await tuner.run();
}

class AdaptiveRewardTuner {
  AdaptiveRewardTuner({
    this.optimizerSummaryPath =
        'release/_reports/marketing_optimizer_summary.txt',
    this.profilePath = 'release/_reports/personalization_profile.json',
    this.summaryPath = 'release/_reports/reward_tuner_summary.txt',
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
  });

  final String optimizerSummaryPath;
  final String profilePath;
  final String summaryPath;
  final String telemetryPath;

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final insights = await _loadOptimizerInsights();
    final profile = await _Profile.load(profilePath);

    final adjustment = _AdjustmentPlan.fromPrediction(
      predictedRetention: insights.predictedRetention,
      currentXp: profile.xpMultiplier,
      currentChip: profile.chipMultiplier,
    );

    profile.apply(
      newXpMultiplier: adjustment.newXpMultiplier,
      newChipMultiplier: adjustment.newChipMultiplier,
    );

    await _withReportsWritable(() async {
      await profile.save(profilePath);
      await _writeSummary(
        insights: insights,
        profile: profile,
        adjustment: adjustment,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        insights: insights,
        adjustment: adjustment,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    stdout.writeln(
      'adaptive_reward_tuner: '
      'predicted_retention=${_round(insights.predictedRetention)}% '
      'xp=${_round(adjustment.newXpMultiplier)} '
      'chip=${_round(adjustment.newChipMultiplier)}',
    );
  }

  Future<_OptimizerInsights> _loadOptimizerInsights() async {
    final file = File(optimizerSummaryPath);
    if (!await file.exists()) {
      throw StateError(
        'adaptive_reward_tuner: marketing optimizer output missing at '
        '$optimizerSummaryPath',
      );
    }

    final lines = await file.readAsLines();
    double? predicted;
    String recommendation = 'Maintain reward multipliers';
    final predictedRegex = RegExp(
      r'Predicted retention gain:\s*([+-]?\d+(?:\.\d+)?)%',
    );

    for (final rawLine in lines) {
      final line = rawLine.trim();
      final match = predictedRegex.firstMatch(line);
      if (match != null) {
        predicted = double.parse(match.group(1)!);
        continue;
      }
      if (line.startsWith('Recommended action:')) {
        recommendation = line.split(':').last.trim();
      }
    }

    if (predicted == null) {
      throw StateError(
        'adaptive_reward_tuner: optimizer summary missing prediction line.',
      );
    }

    return _OptimizerInsights(
      predictedRetention: predicted,
      recommendation: recommendation,
    );
  }

  Future<void> _writeSummary({
    required _OptimizerInsights insights,
    required _Profile profile,
    required _AdjustmentPlan adjustment,
    required int durationMs,
  }) async {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE REWARD TUNER')
      ..writeln('=====================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln(
        'Predicted retention gain: ${_formatPercent(insights.predictedRetention)}',
      )
      ..writeln('Optimizer guidance: ${insights.recommendation}')
      ..writeln()
      ..writeln('Multipliers')
      ..writeln('Type  | Previous | New    | Delta')
      ..writeln('------+----------+--------+-------')
      ..writeln(
        'XP    | ${_pad(profile.previousXpMultiplier)} | '
        '${_pad(adjustment.newXpMultiplier)} | '
        '${_formatPercent(adjustment.xpDelta * 100)}',
      )
      ..writeln(
        'Chips | ${_pad(profile.previousChipMultiplier)} | '
        '${_pad(adjustment.newChipMultiplier)} | '
        '${_formatPercent(adjustment.chipDelta * 100)}',
      )
      ..writeln()
      ..writeln('Notes: ${adjustment.notes}')
      ..writeln();

    await File(summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry({
    required _OptimizerInsights insights,
    required _AdjustmentPlan adjustment,
    required int durationMs,
  }) async {
    final payload = <String, Object?>{
      'event': 'reward_tuning_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'predicted_retention_delta': insights.predictedRetention,
      'xp_multiplier': adjustment.newXpMultiplier,
      'chip_multiplier': adjustment.newChipMultiplier,
      'xp_delta_pct': adjustment.xpDelta * 100,
      'chip_delta_pct': adjustment.chipDelta * 100,
      'notes': adjustment.notes,
      'duration_ms': durationMs,
    };

    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _OptimizerInsights {
  const _OptimizerInsights({
    required this.predictedRetention,
    required this.recommendation,
  });

  final double predictedRetention;
  final String recommendation;
}

class _Profile {
  _Profile._(
    this.rawData,
    this.previousXpMultiplier,
    this.previousChipMultiplier,
  );

  static Future<_Profile> load(String path) async {
    final file = File(path);
    var raw = <String, Object?>{
      'generated_at': DateTime.now().toIso8601String(),
      'fingerprint': const <String, Object?>{},
      'adjustments': <String, Object?>{},
    };

    if (await file.exists()) {
      try {
        final decoded = json.decode(await file.readAsString());
        if (decoded is Map<String, Object?>) {
          raw = decoded;
        }
      } catch (_) {
        // ignore malformed file, fallback to defaults
      }
    }

    final adjustments =
        (raw['adjustments'] as Map<String, Object?>?) ?? <String, Object?>{};
    final xp = _toDouble(adjustments['xp_multiplier'])?.clamp(0.5, 2.0) ?? 1.0;
    final chip =
        _toDouble(adjustments['chip_multiplier'])?.clamp(0.5, 2.0) ?? 1.0;
    raw['adjustments'] = adjustments;

    return _Profile._(raw, xp, chip);
  }

  final Map<String, Object?> rawData;
  final double previousXpMultiplier;
  final double previousChipMultiplier;

  double newXpMultiplier = 1.0;
  double newChipMultiplier = 1.0;

  double get xpMultiplier => previousXpMultiplier;
  double get chipMultiplier => previousChipMultiplier;

  void apply({
    required double newXpMultiplier,
    required double newChipMultiplier,
  }) {
    this.newXpMultiplier = newXpMultiplier;
    this.newChipMultiplier = newChipMultiplier;

    final adjustments =
        (rawData['adjustments'] as Map<String, Object?>?) ??
        <String, Object?>{};
    adjustments['xp_multiplier'] = newXpMultiplier;
    adjustments['chip_multiplier'] = newChipMultiplier;
    adjustments['last_reward_tuning'] = DateTime.now().toIso8601String();
    rawData['adjustments'] = adjustments;
  }

  Future<void> save(String path) async {
    rawData['generated_at'] ??= DateTime.now().toIso8601String();
    final encoder = const JsonEncoder.withIndent('  ');
    await File(path).writeAsString('${encoder.convert(rawData)}\n');
  }
}

class _AdjustmentPlan {
  const _AdjustmentPlan({
    required this.newXpMultiplier,
    required this.newChipMultiplier,
    required this.xpDelta,
    required this.chipDelta,
    required this.notes,
  });

  factory _AdjustmentPlan.fromPrediction({
    required double predictedRetention,
    required double currentXp,
    required double currentChip,
  }) {
    final absRetention = predictedRetention.abs();
    double deltaPct;
    if (absRetention >= 3) {
      deltaPct = 0.15;
    } else if (absRetention >= 1.5) {
      deltaPct = 0.12;
    } else if (absRetention >= 0.3) {
      deltaPct = 0.10;
    } else {
      deltaPct = 0.0;
    }
    if (predictedRetention < 0) {
      deltaPct = -deltaPct;
    }

    final newXp = _clampMultiplier(currentXp * (1 + deltaPct));
    final newChip = _clampMultiplier(currentChip * (1 + deltaPct * 0.9));

    final notes = deltaPct == 0
        ? 'Retention gain too small; holding multipliers.'
        : predictedRetention >= 0
        ? 'Boosting rewards to capture projected retention lift.'
        : 'Dialing back rewards to stabilize retention.';

    return _AdjustmentPlan(
      newXpMultiplier: newXp,
      newChipMultiplier: newChip,
      xpDelta: deltaPct,
      chipDelta: deltaPct * 0.9,
      notes: notes,
    );
  }

  final double newXpMultiplier;
  final double newChipMultiplier;
  final double xpDelta;
  final double chipDelta;
  final String notes;
}

double _clampMultiplier(double value) => value.clamp(0.5, 2.0);

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _pad(double value) => _round(value).toString().padLeft(6);

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
