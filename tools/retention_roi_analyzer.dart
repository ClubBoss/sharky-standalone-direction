import 'dart:convert';
import 'dart:io';

const String _retentionSummaryPath =
    'release/_reports/retention_funnel_summary.txt';
const String _revenueForecastPath =
    'release/_reports/revenue_forecast_summary.txt';
const String _rewardSummaryPath = 'release/_reports/reward_tuner_summary.txt';
const String _outputPath = 'release/_reports/retention_roi_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _baselinePath = 'release/_reports/_retention_roi_baseline.json';
const int _fallbackForecastHorizon = 5;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final retention = await _RetentionSnapshot.load(_retentionSummaryPath);
  final revenue = await _RevenueForecastSnapshot.load(_revenueForecastPath);
  final rewardCost = await _RewardCostSnapshot.load(_rewardSummaryPath);
  final baseline = await _BaselineSnapshot.load(_baselinePath);

  final double deltaRetention = retention.totalRetention - baseline.retention;
  final double deltaRevenue = revenue.averageForecast - baseline.revenue;
  final double roi = rewardCost.cost == 0
      ? 0.0
      : (deltaRetention * deltaRevenue) / rewardCost.cost;

  final verdict = roi >= 0 ? 'PASS' : 'WARN';
  final recommendation = roi >= 0
      ? 'Retention and revenue uplift outweigh incentive costs.'
      : 'ROI negative; reduce incentive cost or improve retention conversions.';

  await _withReportsWritable(() async {
    await _writeSummary(
      retention: retention,
      revenue: revenue,
      rewardCost: rewardCost,
      roi: roi,
      deltaRetention: deltaRetention,
      deltaRevenue: deltaRevenue,
      verdict: verdict,
      recommendation: recommendation,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _emitTelemetry(
      roi: roi,
      deltaRetention: deltaRetention,
      deltaRevenue: deltaRevenue,
      cost: rewardCost.cost,
      durationMs: stopwatch.elapsedMilliseconds,
      verdict: verdict,
    );
    await baseline.save(
      path: _baselinePath,
      retention: retention.totalRetention,
      revenue: revenue.averageForecast,
    );
  });

  stdout.writeln(
    'retention_roi_analyzer: ROI=${roi.toStringAsFixed(2)} verdict=$verdict',
  );
}

Future<void> _writeSummary({
  required _RetentionSnapshot retention,
  required _RevenueForecastSnapshot revenue,
  required _RewardCostSnapshot rewardCost,
  required double roi,
  required double deltaRetention,
  required double deltaRevenue,
  required String verdict,
  required String recommendation,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('RETENTION ROI SUMMARY')
    ..writeln('=====================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Retention funnel:')
    ..writeln(
      '- first→signup     : ${retention.firstToSignup.toStringAsFixed(1)}%',
    )
    ..writeln(
      '- signup→start     : ${retention.signupToStart.toStringAsFixed(1)}%',
    )
    ..writeln(
      '- start→finish     : ${retention.startToFinish.toStringAsFixed(1)}%',
    )
    ..writeln(
      '- total retention  : ${retention.totalRetention.toStringAsFixed(1)}%',
    )
    ..writeln()
    ..writeln('Revenue forecast:')
    ..writeln(
      '- Current proxy     : ${revenue.currentRevenue.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Forecast avg      : ${revenue.averageForecast.toStringAsFixed(2)}',
    )
    ..writeln('- Horizon           : ${revenue.horizon} periods')
    ..writeln()
    ..writeln('Incentive cost (approx): ${rewardCost.cost.toStringAsFixed(2)}')
    ..writeln(
      'XP delta %: ${rewardCost.xpDelta.toStringAsFixed(2)} | '
      'Chip delta %: ${rewardCost.chipDelta.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln('ROI calculation:')
    ..writeln('- ΔRetention : ${deltaRetention.toStringAsFixed(2)}')
    ..writeln('- ΔRevenue   : ${deltaRevenue.toStringAsFixed(2)}')
    ..writeln('- ROI        : ${roi.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('Recommendation:')
    ..writeln(recommendation)
    ..writeln();

  await File(_outputPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry({
  required double roi,
  required double deltaRetention,
  required double deltaRevenue,
  required double cost,
  required int durationMs,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'retention_roi_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'roi': roi,
    'delta_retention': deltaRetention,
    'delta_revenue': deltaRevenue,
    'cost': cost,
    'verdict': verdict,
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _RetentionSnapshot {
  const _RetentionSnapshot({
    required this.firstToSignup,
    required this.signupToStart,
    required this.startToFinish,
    required this.totalRetention,
  });

  static Future<_RetentionSnapshot> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Retention summary missing at $path');
    }
    final lines = await file.readAsLines();
    double? firstToSignup;
    double? signupToStart;
    double? startToFinish;
    double? totalRetention;

    final mapping = <RegExp, void Function(double)>{
      RegExp(r'first_launch.*:\s*([0-9.]+)%'): (value) => firstToSignup = value,
      RegExp(r'signup .*:\s*([0-9.]+)%'): (value) => signupToStart = value,
      RegExp(r'tutorial_start.*:\s*([0-9.]+)%'): (value) =>
          startToFinish = value,
      RegExp(r'Total retention:\s*([0-9.]+)%'): (value) =>
          totalRetention = value,
    };

    for (final line in lines) {
      for (final entry in mapping.entries) {
        final match = entry.key.firstMatch(line);
        if (match != null) {
          entry.value(double.parse(match.group(1)!));
        }
      }
    }

    if ([
      firstToSignup,
      signupToStart,
      startToFinish,
      totalRetention,
    ].any((value) => value == null)) {
      throw StateError('Unable to parse retention metrics from $path');
    }

    return _RetentionSnapshot(
      firstToSignup: firstToSignup!,
      signupToStart: signupToStart!,
      startToFinish: startToFinish!,
      totalRetention: totalRetention!,
    );
  }

  final double firstToSignup;
  final double signupToStart;
  final double startToFinish;
  final double totalRetention;
}

class _RevenueForecastSnapshot {
  const _RevenueForecastSnapshot({
    required this.currentRevenue,
    required this.averageForecast,
    required this.horizon,
  });

  static Future<_RevenueForecastSnapshot> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Revenue forecast summary missing at $path');
    }
    final lines = await file.readAsLines();
    double current = 0;
    double average = 0;
    int horizon = 0;

    final currentRegex = RegExp(r'Revenue proxy\s*:\s*([0-9.]+)');
    final avgRegex = RegExp(r'Forecast avg\s*:\s*([0-9.]+)');
    final horizonRegex = RegExp(r'Forecast horizon:\s*([0-9]+)');

    for (final line in lines) {
      final currentMatch = currentRegex.firstMatch(line);
      if (currentMatch != null) {
        current = double.parse(currentMatch.group(1)!);
      }
      final avgMatch = avgRegex.firstMatch(line);
      if (avgMatch != null) {
        average = double.parse(avgMatch.group(1)!);
      }
      final horizonMatch = horizonRegex.firstMatch(line);
      if (horizonMatch != null) {
        horizon = int.parse(horizonMatch.group(1)!);
      }
    }

    if (horizon == 0) {
      horizon = _fallbackForecastHorizon;
    }
    if (average == 0) {
      average = current;
    }

    return _RevenueForecastSnapshot(
      currentRevenue: current,
      averageForecast: average,
      horizon: horizon,
    );
  }

  final double currentRevenue;
  final double averageForecast;
  final int horizon;
}

class _RewardCostSnapshot {
  const _RewardCostSnapshot({
    required this.cost,
    required this.xpDelta,
    required this.chipDelta,
  });

  static Future<_RewardCostSnapshot> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _RewardCostSnapshot(cost: 1, xpDelta: 0, chipDelta: 0);
    }
    final lines = await file.readAsLines();
    final deltaRegex = RegExp(r'\|\s+([-+]?[0-9.]+)%');
    double xpDelta = 0;
    double chipDelta = 0;

    for (final line in lines) {
      if (line.startsWith('XP')) {
        final match = deltaRegex.allMatches(line).lastOrNull;
        if (match != null) {
          xpDelta = double.tryParse(match.group(1)!) ?? 0;
        }
      } else if (line.startsWith('Chips')) {
        final match = deltaRegex.allMatches(line).lastOrNull;
        if (match != null) {
          chipDelta = double.tryParse(match.group(1)!) ?? 0;
        }
      }
    }

    final cost = 1 + (xpDelta.abs() + chipDelta.abs()) / 2;
    return _RewardCostSnapshot(
      cost: cost,
      xpDelta: xpDelta,
      chipDelta: chipDelta,
    );
  }

  final double cost;
  final double xpDelta;
  final double chipDelta;
}

class _BaselineSnapshot {
  const _BaselineSnapshot({required this.retention, required this.revenue});

  static Future<_BaselineSnapshot> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _BaselineSnapshot(retention: 0, revenue: 0);
    }
    try {
      final data = json.decode(await file.readAsString());
      if (data is Map<String, dynamic>) {
        return _BaselineSnapshot(
          retention: (data['retention'] as num?)?.toDouble() ?? 0,
          revenue: (data['revenue'] as num?)?.toDouble() ?? 0,
        );
      }
    } catch (_) {
      // ignore malformed baseline
    }
    return const _BaselineSnapshot(retention: 0, revenue: 0);
  }

  final double retention;
  final double revenue;

  Future<void> save({
    required String path,
    required double retention,
    required double revenue,
  }) async {
    final file = File(path);
    await file.writeAsString(
      jsonEncode(<String, Object>{'retention': retention, 'revenue': revenue}),
    );
  }
}

extension<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
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
