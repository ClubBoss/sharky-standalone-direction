import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/economy_tuning_service.dart';

Future<void> main(List<String> args) async {
  final history = await _readJson('adaptive_history.json');
  final tuning = await _readJson('economy_tuning.json');
  final recalLog = await _readLog('economy_recalibration_log.jsonl', 50);

  final currentXp = _asDouble(
    tuning?['xpFactor'] ?? tuning?['xp_factor'],
    fallback: 1.0,
  );
  final currentRefill = _asDouble(
    tuning?['refillMinutes'] ?? tuning?['refill'],
    fallback: 30.0,
  );

  final meanDrift = _mean(records: history?['records'], key: 'drift');
  final meanStability = _mean(
    records: history?['records'],
    key: 'stability',
    fallback: 0.9,
  );
  final gradeStart = history?['grade_start']?.toString() ?? 'N/A';
  final gradeEnd = history?['grade_end']?.toString() ?? 'N/A';

  final xpAdjust = -meanDrift * 0.5;
  final newXp = (currentXp + xpAdjust).clamp(0.8, 1.2);

  final refillAdjust = meanStability * 0.1;
  final newRefill = (currentRefill + refillAdjust).clamp(15.0, 60.0);

  final stabilityScore = meanStability;
  final pass = stabilityScore >= 0.85 && meanDrift.abs() <= 0.1;

  final ascii =
      'Economy Auto-Optimizer: ${pass ? 'PASS' : 'FAIL'} '
      '(XP ${currentXp.toStringAsFixed(2)} → ${newXp.toStringAsFixed(2)}, '
      'Refill ${currentRefill.toStringAsFixed(1)} → ${newRefill.toStringAsFixed(1)}, '
      'stability ${stabilityScore.toStringAsFixed(2)})';
  stdout.writeln(ascii);

  final jsonPayload = {
    'xp_before': double.parse(currentXp.toStringAsFixed(3)),
    'xp_after': double.parse(newXp.toStringAsFixed(3)),
    'refill_before': double.parse(currentRefill.toStringAsFixed(3)),
    'refill_after': double.parse(newRefill.toStringAsFixed(3)),
    'mean_drift': double.parse(meanDrift.toStringAsFixed(4)),
    'mean_stability': double.parse(meanStability.toStringAsFixed(4)),
    'grade_start': gradeStart,
    'grade_end': gradeEnd,
    'recalibration_events': recalLog.length,
    'pass': pass,
  };
  stdout.writeln(jsonEncode(jsonPayload));

  await EconomyTuningService.instance.updateTuning(
    xpFactor: newXp,
    refillInterval: Duration(minutes: newRefill.round()),
  );

  await _appendLog(
    xpBefore: currentXp,
    xpAfter: newXp,
    refillBefore: currentRefill,
    refillAfter: newRefill,
    drift: meanDrift,
    stability: meanStability,
    grades: {'start': gradeStart, 'end': gradeEnd},
  );

  await File(
    'economy_auto_optimizer.json',
  ).writeAsString(jsonEncode(jsonPayload));
}

double _mean({Object? records, required String key, double fallback = 0.0}) {
  if (records is Iterable) {
    final values = records
        .whereType<Map>()
        .map((r) => r[key])
        .where((v) => v is num)
        .cast<num>()
        .map((n) => n.toDouble())
        .toList();
    if (values.isNotEmpty) {
      final total = values.reduce((a, b) => a + b);
      return total / values.length;
    }
  }
  return fallback;
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

Future<List<Map<String, dynamic>>> _readLog(String path, int limit) async {
  final file = File(path);
  if (!await file.exists()) return const [];
  try {
    final lines = await file.readAsLines();
    final records = <Map<String, dynamic>>[];
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line);
        if (data is Map<String, dynamic>) records.add(data);
        if (records.length >= limit) break;
      } catch (_) {
        continue;
      }
    }
    return records;
  } catch (_) {
    return const [];
  }
}

Future<void> _appendLog({
  required double xpBefore,
  required double xpAfter,
  required double refillBefore,
  required double refillAfter,
  required double drift,
  required double stability,
  required Map<String, String> grades,
}) async {
  final entry = {
    'timestamp': DateTime.now().toIso8601String(),
    'xp_before': xpBefore,
    'xp_after': xpAfter,
    'refill_before': refillBefore,
    'refill_after': refillAfter,
    'mean_drift': drift,
    'mean_stability': stability,
    'grades': grades,
  };
  final file = File('economy_auto_optimizer_log.jsonl');
  await file.writeAsString('${jsonEncode(entry)}\n', mode: FileMode.append);
}

double _asDouble(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}
