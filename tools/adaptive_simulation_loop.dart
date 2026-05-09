import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/services/adaptive_pacing_engine.dart';

Future<void> main(List<String> args) async {
  final sessions = _parseSessionCount(args);
  final random = Random(42);

  final tuning = await _readJson('economy_tuning.json');
  final dynamicMetrics = await _readJson('economy_dynamic_metrics.json');

  final xpFactor = _clampDouble(
    _asDouble(
      dynamicMetrics?['xpFactor'] ??
          tuning?['xpFactor'] ??
          tuning?['xp_factor'],
      fallback: 1.0,
    ),
    0.8,
    1.2,
  );
  final refillMinutes = _clampDouble(
    _asDouble(
      dynamicMetrics?['energyInterval'] ??
          tuning?['refillMinutes'] ??
          tuning?['refill'],
      fallback: 30.0,
    ),
    15.0,
    60.0,
  );

  double totalPace = 0;
  double totalXp = 0;
  double totalFps = 0;
  double totalEnergy = 0;
  final List<double> paceValues = [];

  for (var i = 0; i < sessions; i++) {
    final momentum = random.nextDouble();
    final fatigue = min(1.0, random.nextDouble() * (0.6 + momentum / 2));
    final fps = 45 + random.nextDouble() * 15;
    final baseXp = 100.0;

    final pace = AdaptivePacingEngine.computePace(
      momentum: momentum,
      fatigue: fatigue,
      fps: fps,
    );
    final actualXp = baseXp * pace * xpFactor * (fps / 60.0);
    final energyBurn = (1.0 / pace).clamp(0.6, 1.4);

    totalPace += pace;
    totalXp += actualXp;
    totalFps += fps;
    totalEnergy += energyBurn;
    paceValues.add(pace);
  }

  final avgPace = totalPace / sessions;
  final avgXp = totalXp / sessions;
  final avgFps = totalFps / sessions;
  final avgEnergy = totalEnergy / sessions;

  final drift = avgPace - xpFactor;
  final stability =
      (1 - drift.abs()).clamp(0.0, 1.0) * (avgFps / 60.0).clamp(0.75, 1.0);
  final energyRatio = (refillMinutes / 30.0) / max(0.1, avgEnergy);
  final balanced = (stability * energyRatio).clamp(0.0, 1.5);

  final pass = stability >= 0.85 && drift.abs() <= 0.1;
  final driftSign = drift >= 0 ? '+' : '';

  stdout.writeln(
    'Adaptive Sim: ${pass ? 'PASS' : 'FAIL'} '
    '(Δ pace $driftSign${(drift * 100).toStringAsFixed(1)} %, '
    'stability ${stability.toStringAsFixed(2)})',
  );

  final jsonPayload = {
    'sessions': sessions,
    'avg_pace': double.parse(avgPace.toStringAsFixed(4)),
    'avg_xp': double.parse(avgXp.toStringAsFixed(2)),
    'avg_fps': double.parse(avgFps.toStringAsFixed(2)),
    'avg_energy': double.parse(avgEnergy.toStringAsFixed(3)),
    'stability': double.parse(stability.toStringAsFixed(4)),
    'xp_factor': double.parse(xpFactor.toStringAsFixed(3)),
    'refill_minutes': double.parse(refillMinutes.toStringAsFixed(2)),
    'drift': double.parse(drift.toStringAsFixed(4)),
    'balanced_score': double.parse(balanced.toStringAsFixed(4)),
    'pass': pass,
  };

  stdout.writeln(jsonEncode(jsonPayload));
  await File('adaptive_simulation.json').writeAsString(jsonEncode(jsonPayload));
}

int _parseSessionCount(List<String> args) {
  const defaultCount = 75;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--sessions' && i + 1 < args.length) {
      final parsed = int.tryParse(args[i + 1]);
      if (parsed != null && parsed >= 50 && parsed <= 100) return parsed;
    }
  }
  return defaultCount;
}

Future<Map<String, dynamic>?> _readJson(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) return data;
  } catch (_) {}
  return null;
}

double _asDouble(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}

double _clampDouble(double value, double minValue, double maxValue) {
  if (value < minValue) return minValue;
  if (value > maxValue) return maxValue;
  return value;
}
