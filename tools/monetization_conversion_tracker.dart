import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final tracker = MonetizationConversionTracker();
  await tracker.run();
}

class MonetizationConversionTracker {
  MonetizationConversionTracker({
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.optimizerSummaryPath =
        'release/_reports/marketing_optimizer_summary.txt',
    this.rewardSummaryPath = 'release/_reports/reward_tuner_summary.txt',
    this.summaryPath = 'release/_reports/monetization_conversion_summary.txt',
  });

  final String telemetryPath;
  final String optimizerSummaryPath;
  final String rewardSummaryPath;
  final String summaryPath;

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final telemetryStats = await _TelemetryStats.fromFile(telemetryPath);
    final marketing = await _MarketingSummary.load(optimizerSummaryPath);
    final reward = await _RewardSummary.load(rewardSummaryPath);

    final conversionRate = telemetryStats.sessions == 0
        ? 0.0
        : (telemetryStats.premiumTriggers / telemetryStats.sessions) * 100;
    final xpFlux = telemetryStats.avgXpMultiplier * reward.xpMultiplier;
    final revenueProxy = (conversionRate / 100) * xpFlux * 120;

    final recommendation = _recommendation(
      conversionRate: conversionRate,
      marketing: marketing,
      reward: reward,
    );

    await _withReportsWritable(() async {
      await _writeSummary(
        telemetryStats: telemetryStats,
        marketing: marketing,
        reward: reward,
        conversionRate: conversionRate,
        xpFlux: xpFlux,
        revenueProxy: revenueProxy,
        recommendation: recommendation,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        telemetryStats: telemetryStats,
        marketing: marketing,
        reward: reward,
        conversionRate: conversionRate,
        xpFlux: xpFlux,
        revenueProxy: revenueProxy,
        recommendation: recommendation,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    stdout.writeln(
      'monetization_conversion_tracker: sessions=${telemetryStats.sessions} '
      'conversion=${conversionRate.toStringAsFixed(2)}% '
      'revenue_proxy=${revenueProxy.toStringAsFixed(2)}',
    );
  }

  Future<void> _writeSummary({
    required _TelemetryStats telemetryStats,
    required _MarketingSummary marketing,
    required _RewardSummary reward,
    required double conversionRate,
    required double xpFlux,
    required double revenueProxy,
    required String recommendation,
    required int durationMs,
  }) async {
    final buffer = StringBuffer()
      ..writeln('MONETIZATION CONVERSION SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln()
      ..writeln('Telemetry window:')
      ..writeln('- Sessions observed     : ${telemetryStats.sessions}')
      ..writeln('- Premium triggers      : ${telemetryStats.premiumTriggers}')
      ..writeln(
        '- Free→Premium rate     : ${conversionRate.toStringAsFixed(2)}%',
      )
      ..writeln(
        '- Avg XP multiplier     : ${telemetryStats.avgXpMultiplier.toStringAsFixed(2)}',
      )
      ..writeln(
        '- Avg chip multiplier   : ${telemetryStats.avgChipMultiplier.toStringAsFixed(2)}',
      )
      ..writeln('- Revenue proxy (index) : ${revenueProxy.toStringAsFixed(2)}')
      ..writeln()
      ..writeln('Optimizer context:')
      ..writeln(
        '- Predicted retention Δ : ${marketing.predictedRetention.toStringAsFixed(2)}%',
      )
      ..writeln('- Action                : ${marketing.recommendation}')
      ..writeln(
        '- Reward XP multiplier  : ${reward.xpMultiplier.toStringAsFixed(2)}',
      )
      ..writeln(
        '- Reward chip multiplier: ${reward.chipMultiplier.toStringAsFixed(2)}',
      )
      ..writeln()
      ..writeln('Recommendation:')
      ..writeln(recommendation)
      ..writeln();

    await File(summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry({
    required _TelemetryStats telemetryStats,
    required _MarketingSummary marketing,
    required _RewardSummary reward,
    required double conversionRate,
    required double xpFlux,
    required double revenueProxy,
    required String recommendation,
    required int durationMs,
  }) async {
    final payload = <String, Object?>{
      'event': 'monetization_conversion_updated',
      'timestamp': DateTime.now().toIso8601String(),
      'sessions': telemetryStats.sessions,
      'premium_triggers': telemetryStats.premiumTriggers,
      'conversion_rate': conversionRate,
      'xp_flux': xpFlux,
      'marketing': {
        'predicted_retention': marketing.predictedRetention,
        'action': marketing.recommendation,
      },
      'reward': {
        'xp_multiplier': reward.xpMultiplier,
        'chip_multiplier': reward.chipMultiplier,
      },
      'revenue_proxy': revenueProxy,
      'recommendation': recommendation,
      'duration_ms': durationMs,
    };

    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _TelemetryStats {
  const _TelemetryStats({
    required this.sessions,
    required this.premiumTriggers,
    required this.avgXpMultiplier,
    required this.avgChipMultiplier,
  });

  static Future<_TelemetryStats> fromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _TelemetryStats(
        sessions: 0,
        premiumTriggers: 0,
        avgXpMultiplier: 1.0,
        avgChipMultiplier: 1.0,
      );
    }

    final lines = await file.readAsLines();
    var sessions = 0;
    var premium = 0;
    var xpTotal = 0.0;
    var xpCount = 0;
    var chipTotal = 0.0;
    var chipCount = 0;

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      dynamic payload;
      try {
        payload = json.decode(line);
      } catch (_) {
        continue;
      }
      if (payload is! Map<String, dynamic>) continue;
      final event = payload['event']?.toString() ?? '';
      if (event == 'session_start') sessions++;
      if (_isPremiumEvent(event)) premium++;
      final xpValue = _toDouble(payload['xp_multiplier']);
      if (xpValue != null && xpValue > 0) {
        xpTotal += xpValue;
        xpCount++;
      }
      final chipValue = _toDouble(payload['chip_multiplier']);
      if (chipValue != null && chipValue > 0) {
        chipTotal += chipValue;
        chipCount++;
      }
    }

    return _TelemetryStats(
      sessions: sessions,
      premiumTriggers: premium,
      avgXpMultiplier: xpCount == 0 ? 1.0 : xpTotal / xpCount,
      avgChipMultiplier: chipCount == 0 ? 1.0 : chipTotal / chipCount,
    );
  }

  final int sessions;
  final int premiumTriggers;
  final double avgXpMultiplier;
  final double avgChipMultiplier;
}

class _MarketingSummary {
  const _MarketingSummary({
    required this.predictedRetention,
    required this.recommendation,
  });

  static Future<_MarketingSummary> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _MarketingSummary(
        predictedRetention: 0,
        recommendation: 'No optimizer data available',
      );
    }
    final lines = await file.readAsLines();
    double? predicted;
    String recommendation = 'Maintain allocation';
    final regex = RegExp(r'Predicted retention gain:\s*([+-]?\d+(?:\.\d+)?)%');
    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        predicted = double.parse(match.group(1)!);
      }
      if (line.startsWith('Recommended action:')) {
        recommendation = line.split(':').last.trim();
      }
    }

    return _MarketingSummary(
      predictedRetention: predicted ?? 0,
      recommendation: recommendation,
    );
  }

  final double predictedRetention;
  final String recommendation;
}

class _RewardSummary {
  const _RewardSummary({
    required this.xpMultiplier,
    required this.chipMultiplier,
  });

  static Future<_RewardSummary> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _RewardSummary(xpMultiplier: 1.0, chipMultiplier: 1.0);
    }
    final lines = await file.readAsLines();
    double? xp;
    double? chip;
    final xpRegex = RegExp(r'XP\s+\|\s+[^\|]+\|\s+([0-9.]+)');
    final chipRegex = RegExp(r'Chips\s+\|\s+[^\|]+\|\s+([0-9.]+)');
    for (final line in lines) {
      final xpMatch = xpRegex.firstMatch(line);
      if (xpMatch != null) {
        xp = double.tryParse(xpMatch.group(1)!.trim());
      }
      final chipMatch = chipRegex.firstMatch(line);
      if (chipMatch != null) {
        chip = double.tryParse(chipMatch.group(1)!.trim());
      }
    }
    return _RewardSummary(xpMultiplier: xp ?? 1.0, chipMultiplier: chip ?? 1.0);
  }

  final double xpMultiplier;
  final double chipMultiplier;
}

String _recommendation({
  required double conversionRate,
  required _MarketingSummary marketing,
  required _RewardSummary reward,
}) {
  if (conversionRate < 1 && marketing.predictedRetention < 0) {
    return 'Boost premium prompts with safer CTA copy; conversion under 1%.';
  }
  if (conversionRate < 2 && reward.xpMultiplier <= 1) {
    return 'Experiment with +5% XP multiplier for premium cues.';
  }
  if (conversionRate >= 5) {
    return 'Maintain current funnel; conversion signals healthy.';
  }
  return 'Incrementally test banner variants tied to AppColors.accent.';
}

bool _isPremiumEvent(String eventName) {
  final lower = eventName.toLowerCase();
  return lower.contains('purchase') ||
      lower.contains('premium') ||
      lower.contains('reward_purchased') ||
      lower.contains('chips_spent');
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
