import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/services/adaptive_pacing_engine.dart';
import 'package:poker_analyzer/services/economy_tuning_service.dart';

Future<void> main(List<String> args) async {
  final sessions = _parseSessions(args);
  final economy = EconomyTuningService.instance;
  final rnd = Random(42);
  final xpFactors = <double>[];
  final energyMinutes = <double>[];
  int recalibrations = 0;

  double lastXp = 1.0;
  double lastEnergy = 30.0;

  for (var i = 0; i < sessions; i++) {
    final momentum = (rnd.nextDouble() * 2 - 1).clamp(-1.0, 1.0);
    final fatigue = rnd.nextDouble().clamp(0.0, 1.0);

    final xpFactor = await economy.getDynamicXpFactor();
    final refill = await economy.getDynamicRefillInterval(
      Duration(minutes: 30),
    );
    final pace = AdaptivePacingEngine.computePace(
      momentum: momentum,
      fatigue: fatigue,
      fps: 55 + rnd.nextDouble() * 10,
    );

    xpFactors.add(xpFactor * pace);
    energyMinutes.add(refill.inMinutes.toDouble());

    if ((xpFactor - lastXp).abs() > 0.05 ||
        (refill.inMinutes - lastEnergy).abs() > 2) {
      recalibrations++;
    }
    lastXp = xpFactor;
    lastEnergy = refill.inMinutes.toDouble();
  }

  final xpStats = _computeStats(xpFactors, baseline: 1.0);
  final energyStats = _computeStats(energyMinutes, baseline: 30.0);

  final report = {
    'sessions': sessions,
    'xp_mean': xpStats.mean,
    'xp_drift_pct': xpStats.drift,
    'xp_volatility_pct': xpStats.volatility,
    'energy_mean': energyStats.mean,
    'energy_drift_pct': energyStats.drift,
    'energy_volatility_pct': energyStats.volatility,
    'recalibrations': recalibrations,
    'pass': xpStats.drift.abs() < 5 && energyStats.drift.abs() < 5,
  };

  _printAscii(report);
  await File(
    'economy_stress_report.json',
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(report));
}

class _Stats {
  final double mean;
  final double drift;
  final double volatility;

  const _Stats({
    required this.mean,
    required this.drift,
    required this.volatility,
  });
}

void _printAscii(Map<String, Object?> report) {
  final driftXp = (report['xp_drift_pct'] as num).toDouble();
  final volXp = (report['xp_volatility_pct'] as num).toDouble();
  final driftEnergy = (report['energy_drift_pct'] as num).toDouble();
  final volEnergy = (report['energy_volatility_pct'] as num).toDouble();
  final recal = report['recalibrations'];
  final sessions = report['sessions'];
  final status = (report['pass'] == true) ? 'PASS' : 'FAIL';

  stdout.writeln('Economy Stress Sim v2');
  stdout.writeln('Sessions: $sessions');
  stdout.writeln(
    'XP drift: ${driftXp.toStringAsFixed(2)}% • volatility ${volXp.toStringAsFixed(2)}%',
  );
  stdout.writeln(
    'Energy drift: ${driftEnergy.toStringAsFixed(2)}% • volatility ${volEnergy.toStringAsFixed(2)}%',
  );
  stdout.writeln('Recalibrations: $recal');
  stdout.writeln('Status: $status');
}

_Stats _computeStats(List<double> samples, {required double baseline}) {
  if (samples.isEmpty) {
    return const _Stats(mean: 0.0, drift: 0.0, volatility: 0.0);
  }
  final mean = samples.reduce((a, b) => a + b) / samples.length;
  final drift = baseline == 0 ? 0.0 : ((mean - baseline) / baseline) * 100;
  double variance = 0;
  for (final sample in samples) {
    variance += pow(sample - mean, 2).toDouble();
  }
  variance /= samples.length;
  final stdDev = sqrt(variance);
  final volatility = baseline == 0 ? 0.0 : (stdDev / baseline) * 100;
  return _Stats(mean: mean, drift: drift, volatility: volatility);
}

int _parseSessions(List<String> args) {
  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--sessions' && i + 1 < args.length) {
      final parsed = int.tryParse(args[i + 1]);
      if (parsed != null && parsed > 0) return parsed;
    }
  }
  return 5000;
}
