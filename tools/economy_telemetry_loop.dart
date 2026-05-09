import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final result = await runEconomyTelemetryLoop();

  final drift = result['drift_percent'] as double? ?? 0.0;
  final trend = result['trend'] as String? ?? 'stable';
  final pass = result['pass'] as bool? ?? true;

  final driftSign = drift >= 0 ? '+' : '';
  stdout.writeln(
    'Economy Telemetry Loop: ${pass ? "PASS" : "FAIL"} (drift $driftSign${drift.toStringAsFixed(2)}%, trend $trend)',
  );
  stdout.writeln(jsonEncode(result));
}

Future<Map<String, Object>> runEconomyTelemetryLoop() async {
  try {
    final betaMetrics = await _readBetaMetrics();
    final economyTuning = await _readEconomyTuning();

    final actualPace = betaMetrics['avg_pace_factor'] as double? ?? 1.0;
    final tunedXpFactor = economyTuning['xp_factor'] as double? ?? 1.0;
    final tunedRefill = economyTuning['refill'] as int? ?? 30;

    final expectedPace = tunedXpFactor;
    final delta = actualPace - expectedPace;
    final driftPercent = delta * 100.0;
    final absDelta = delta.abs();

    String trend;
    if (absDelta < 0.05) {
      trend = 'stable';
    } else if (delta > 0) {
      trend = 'accelerating';
    } else {
      trend = 'decelerating';
    }

    if (absDelta > 0.05) {
      await _logEconomyDriftEvent(
        delta: delta,
        driftPercent: driftPercent,
        trend: trend,
      );
    }

    final suggestions = _computeSuggestions(
      actualPace: actualPace,
      tunedXpFactor: tunedXpFactor,
      tunedRefill: tunedRefill,
      delta: delta,
      trend: trend,
    );

    await _writeEconomyFeedback(suggestions);

    return {
      'actual_pace': actualPace,
      'expected_pace': expectedPace,
      'delta': delta,
      'drift_percent': driftPercent,
      'trend': trend,
      'suggested_xp_factor': suggestions['xp_factor'] ?? tunedXpFactor,
      'suggested_refill': suggestions['refill'] ?? tunedRefill,
      'drift_logged': absDelta > 0.05,
      'pass': true,
    };
  } catch (e) {
    return {
      'actual_pace': 1.0,
      'expected_pace': 1.0,
      'delta': 0.0,
      'drift_percent': 0.0,
      'trend': 'unknown',
      'suggested_xp_factor': 1.0,
      'suggested_refill': 30,
      'drift_logged': false,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _readBetaMetrics() async {
  final file = File('beta_metrics.json');
  if (!await file.exists()) {
    return {'avg_pace_factor': 1.0, 'avg_momentum': 0.5, 'avg_fatigue': 0.0};
  }

  try {
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    return data;
  } catch (_) {
    return {'avg_pace_factor': 1.0, 'avg_momentum': 0.5, 'avg_fatigue': 0.0};
  }
}

Future<Map<String, dynamic>> _readEconomyTuning() async {
  final file = File('economy_tuning.json');
  if (!await file.exists()) {
    return {'xp_factor': 1.0, 'refill': 30};
  }

  try {
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    return data;
  } catch (_) {
    return {'xp_factor': 1.0, 'refill': 30};
  }
}

Future<void> _logEconomyDriftEvent({
  required double delta,
  required double driftPercent,
  required String trend,
}) async {
  final event = {
    'event': 'economy_tuning_drift',
    'timestamp': DateTime.now().toIso8601String(),
    'delta': delta,
    'drift_percent': driftPercent,
    'direction': delta > 0 ? 'positive' : 'negative',
    'magnitude': delta.abs(),
    'trend': trend,
  };

  final logFile = File('telemetry_events.jsonl');
  await logFile.writeAsString('${jsonEncode(event)}\n', mode: FileMode.append);
}

Map<String, Object> _computeSuggestions({
  required double actualPace,
  required double tunedXpFactor,
  required int tunedRefill,
  required double delta,
  required String trend,
}) {
  double suggestedXpFactor = tunedXpFactor;
  int suggestedRefill = tunedRefill;

  if (delta.abs() > 0.05) {
    if (trend == 'accelerating') {
      suggestedXpFactor = (tunedXpFactor * (1.0 - delta * 0.05)).clamp(
        0.8,
        1.5,
      );
      suggestedRefill = (tunedRefill * 1.1).round().clamp(20, 60);
    } else if (trend == 'decelerating') {
      suggestedXpFactor = (tunedXpFactor * (1.0 - delta * 0.05)).clamp(
        0.8,
        1.5,
      );
      suggestedRefill = (tunedRefill * 0.9).round().clamp(20, 60);
    }
  }

  return {
    'xp_factor': double.parse(suggestedXpFactor.toStringAsFixed(3)),
    'refill': suggestedRefill,
    'reason': trend,
    'delta': delta,
  };
}

Future<void> _writeEconomyFeedback(Map<String, Object> suggestions) async {
  final feedback = {
    'timestamp': DateTime.now().toIso8601String(),
    'suggestions': suggestions,
    'note': 'Non-destructive feedback. Review and apply manually if needed.',
  };

  final file = File('economy_feedback.json');
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(feedback),
  );
}
