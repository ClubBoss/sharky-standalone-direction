import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');

  final analyzer = await _ensureAnalyzerSummary();
  final tuning = await _readEconomyTuning();

  final drift = analyzer['drift'] as double? ?? 0.0;
  final xpFactor = (tuning['xpFactor'] as num?)?.toDouble() ?? 1.0;
  final refill = (tuning['refillMinutes'] as num?)?.toDouble() ?? 30.0;

  final xpResult = _recalibrateValue(
    current: xpFactor,
    drift: drift,
    clampMin: 0.8,
    clampMax: 1.2,
  );
  final refillResult = _recalibrateValue(
    current: refill,
    drift: drift,
    clampMin: 15.0,
    clampMax: 60.0,
  );

  final xpAdj = xpResult.adjustment;
  final refillAdj = refillResult.adjustment;
  final pass = xpAdj.abs() <= 0.2 && refillAdj.abs() <= 0.5;

  final signXp = xpAdj >= 0 ? '+' : '';
  final signRefill = refillAdj >= 0 ? '+' : '';
  stdout.writeln(
    'Economy Recalibration: ${pass ? 'PASS' : 'FAIL'} '
    '(Δ xp $signXp${(xpAdj * 100).toStringAsFixed(1)} %, '
    'refill $signRefill${(refillAdj * 100).toStringAsFixed(1)} %)',
  );

  final jsonPayload = {
    'xp_adj': double.parse(xpAdj.toStringAsFixed(4)),
    'refill_adj': double.parse(refillAdj.toStringAsFixed(4)),
    'pass': pass,
    'applied': apply,
  };
  stdout.writeln(jsonEncode(jsonPayload));

  if (apply) {
    await _writeEconomyTuning(
      xpFactor: xpResult.value,
      refillMinutes: refillResult.value.round(),
      source: tuning['raw'] as Map<String, dynamic>?,
    );
    await _appendLog(
      drift: drift,
      xpBefore: xpFactor,
      xpAfter: xpResult.value,
      refillBefore: refill.toDouble(),
      refillAfter: refillResult.value,
      adjustments: jsonPayload,
    );
  }
}

class _RecalibrationResult {
  final double value;
  final double adjustment;

  _RecalibrationResult(this.value, this.adjustment);
}

_RecalibrationResult _recalibrateValue({
  required double current,
  required double drift,
  required double clampMin,
  required double clampMax,
}) {
  double updated = current;
  if (drift > 0.05) {
    updated = current * (1 - 0.05 * drift);
  } else if (drift < -0.05) {
    updated = current * (1 + 0.05 * drift.abs());
  }
  if (updated < clampMin) updated = clampMin;
  if (updated > clampMax) updated = clampMax;
  final adjustment = current == 0 ? 0.0 : (updated - current) / current;
  return _RecalibrationResult(updated, adjustment);
}

Future<Map<String, dynamic>> _ensureAnalyzerSummary() async {
  final file = File('economy_telemetry_analyzer.json');
  if (!await file.exists()) {
    await Process.run('dart', ['run', 'tools/economy_telemetry_analyzer.dart']);
  }
  if (!await file.exists()) return {};
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) return data;
  } catch (_) {}
  return {};
}

Future<Map<String, Object>> _readEconomyTuning() async {
  final file = File('economy_tuning.json');
  if (!await file.exists()) {
    return {'xpFactor': 1.0, 'refillMinutes': 30, 'raw': <String, dynamic>{}};
  }
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) {
      final xpRaw = data.containsKey('xpFactor')
          ? data['xpFactor']
          : data['xp_factor'];
      final refillRaw = data.containsKey('refillMinutes')
          ? data['refillMinutes']
          : data['refill'];
      final xpVal = xpRaw is num ? xpRaw.toDouble() : 1.0;
      final refillVal = refillRaw is num ? refillRaw.toDouble() : 30.0;
      final num xpClamped = xpVal.clamp(0.2, 3.0);
      final num refillClamped = refillVal.clamp(10, 120);
      return {
        'xpFactor': xpClamped.toDouble(),
        'refillMinutes': refillClamped.toDouble(),
        'raw': data,
      };
    }
  } catch (_) {}
  return {'xpFactor': 1.0, 'refillMinutes': 30, 'raw': <String, dynamic>{}};
}

Future<void> _writeEconomyTuning({
  required double xpFactor,
  required int refillMinutes,
  Map<String, dynamic>? source,
}) async {
  final data = Map<String, dynamic>.from(source ?? {});
  data['xpFactor'] = double.parse(xpFactor.toStringAsFixed(3));
  data['refillMinutes'] = refillMinutes;
  final file = File('economy_tuning.json');
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
}

Future<void> _appendLog({
  required double drift,
  required double xpBefore,
  required double xpAfter,
  required double refillBefore,
  required double refillAfter,
  required Map<String, dynamic> adjustments,
}) async {
  final entry = {
    'timestamp': DateTime.now().toIso8601String(),
    'drift': drift,
    'xp_before': xpBefore,
    'xp_after': xpAfter,
    'refill_before': refillBefore,
    'refill_after': refillAfter,
    'adjustments': adjustments,
  };
  final file = File('economy_recalibration_log.jsonl');
  await file.writeAsString('${jsonEncode(entry)}\n', mode: FileMode.append);
}
