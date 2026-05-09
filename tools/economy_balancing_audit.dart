import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final tuning = await _readJson('economy_tuning.json');
  final dynamicMetrics = await _readJson('economy_dynamic_metrics.json');
  final logEntries = await _readLogEntries('economy_recalibration_log.jsonl');

  final xpSamples = <double>[];
  final energySamples = <double>[];
  for (final entry in logEntries) {
    final xp = (entry['xp_after'] as num?)?.toDouble();
    if (xp != null && xp > 0) xpSamples.add(xp);
    final refill = (entry['refill_after'] as num?)?.toDouble();
    if (refill != null && refill > 0) energySamples.add(refill);
  }

  final latestXp =
      _extractDouble(dynamicMetrics, 'xpSmoothed') ??
      _extractDouble(dynamicMetrics, 'xpFactor') ??
      _extractDouble(tuning, 'xpFactor') ??
      1.0;
  final latestEnergy =
      _extractDouble(dynamicMetrics, 'energySmoothed') ??
      _extractDouble(dynamicMetrics, 'energyInterval') ??
      _extractDouble(tuning, 'refillMinutes') ??
      30.0;

  final avgXp = xpSamples.isNotEmpty
      ? xpSamples.reduce((a, b) => a + b) / xpSamples.length
      : latestXp;
  final avgEnergy = energySamples.isNotEmpty
      ? energySamples.reduce((a, b) => a + b) / energySamples.length
      : latestEnergy;

  final xpDrift = avgXp == 0 ? 0.0 : (latestXp - avgXp) / avgXp;
  final energyDrift = avgEnergy == 0
      ? 0.0
      : (latestEnergy - avgEnergy) / avgEnergy;

  final xpClampMin = xpSamples.isEmpty
      ? 0.8
      : xpSamples.reduce(min).clamp(0.5, 2.0);
  final xpClampMax = xpSamples.isEmpty
      ? 1.2
      : xpSamples.reduce(max).clamp(0.5, 2.5);
  final energyClampMin = energySamples.isEmpty
      ? 20
      : energySamples.reduce(min).clamp(10, 120);
  final energyClampMax = energySamples.isEmpty
      ? 40
      : energySamples.reduce(max).clamp(10, 180);

  final pass = xpDrift.abs() < 0.05 && energyDrift.abs() < 0.05;

  final driftSignXp = xpDrift >= 0 ? '+' : '';
  final driftSignEnergy = energyDrift >= 0 ? '+' : '';

  stdout.writeln('Economy Balancing Audit');
  stdout.writeln(
    'XP drift: $driftSignXp${(xpDrift * 100).toStringAsFixed(2)}% '
    '(avg ${avgXp.toStringAsFixed(3)} → latest ${latestXp.toStringAsFixed(3)})',
  );
  stdout.writeln(
    'Energy drift: $driftSignEnergy${(energyDrift * 100).toStringAsFixed(2)}% '
    '(avg ${avgEnergy.toStringAsFixed(1)} → latest ${latestEnergy.toStringAsFixed(1)})',
  );
  stdout.writeln(
    'Suggested clamps: xp [${xpClampMin.toStringAsFixed(2)}, ${xpClampMax.toStringAsFixed(2)}], '
    'energy [${energyClampMin.toStringAsFixed(0)}, ${energyClampMax.toStringAsFixed(0)}]',
  );
  stdout.writeln('Status: ${pass ? 'PASS' : 'FAIL'}');

  stdout.writeln(
    jsonEncode({
      'xp_drift_pct': double.parse((xpDrift * 100).toStringAsFixed(3)),
      'energy_drift_pct': double.parse((energyDrift * 100).toStringAsFixed(3)),
      'xp_avg': double.parse(avgXp.toStringAsFixed(3)),
      'xp_latest': double.parse(latestXp.toStringAsFixed(3)),
      'energy_avg': double.parse(avgEnergy.toStringAsFixed(2)),
      'energy_latest': double.parse(latestEnergy.toStringAsFixed(2)),
      'xp_clamp_min': double.parse(xpClampMin.toStringAsFixed(3)),
      'xp_clamp_max': double.parse(xpClampMax.toStringAsFixed(3)),
      'energy_clamp_min': double.parse(energyClampMin.toStringAsFixed(1)),
      'energy_clamp_max': double.parse(energyClampMax.toStringAsFixed(1)),
      'pass': pass,
    }),
  );
}

double? _extractDouble(Map<String, dynamic>? source, String key) {
  if (source == null) return null;
  final value = source[key] ?? source[_altKey(key)];
  return value is num ? value.toDouble() : null;
}

String _altKey(String key) {
  switch (key) {
    case 'xpFactor':
      return 'xp_factor';
    case 'refillMinutes':
      return 'refill';
    default:
      return key;
  }
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

Future<List<Map<String, dynamic>>> _readLogEntries(String path) async {
  final file = File(path);
  if (!await file.exists()) return const [];
  try {
    final lines = await file.readAsLines();
    final recent = lines
        .where((line) => line.trim().isNotEmpty)
        .toList()
        .reversed
        .take(25)
        .toList()
        .reversed;
    final entries = <Map<String, dynamic>>[];
    for (final line in recent) {
      try {
        final data = jsonDecode(line);
        if (data is Map<String, dynamic>) entries.add(data);
      } catch (_) {}
    }
    return entries;
  } catch (_) {
    return const [];
  }
}
