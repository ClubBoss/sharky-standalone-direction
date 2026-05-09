import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ui_perf_telemetry_service.dart';

const _historyWindow = 10;

class EconomyTuningService {
  EconomyTuningService._();
  static final EconomyTuningService instance = EconomyTuningService._();

  static double _lastFpsAvg = 0;
  static double _lastXpFactor = 1.0;
  static int _lastEnergyMinutes = 30;
  static double _lastSmoothedXp = 1.0;
  static int _lastSmoothedEnergy = 30;

  Future<Map<String, dynamic>> _load() async {
    try {
      final file = File('economy_tuning.json');
      if (!await file.exists()) return const {};
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return const {};
  }

  Future<bool> isApplyEnabled() async {
    final data = await _load();
    return data['apply'] == true;
  }

  Future<Duration> getRefillInterval(Duration fallback) async {
    final data = await _load();
    final minutes = (data['refillMinutes'] as num?)?.toInt();
    if (minutes == null || minutes <= 0) return fallback;
    return Duration(minutes: minutes);
  }

  Future<double> getXpFactor() async {
    final data = await _load();
    final factor = (data['xpFactor'] as num?)?.toDouble();
    if (factor == null) return 1.0;
    return factor.clamp(0.5, 2.0);
  }

  Future<double> getDynamicXpFactor() async {
    UiPerfTelemetryService.instance.start();
    final base = await getXpFactor();
    final fpsAvg = UiPerfTelemetryService.instance.metrics.value.fpsAvg;
    double multiplier = 1.0;
    if (fpsAvg > 0 && fpsAvg < 60) {
      multiplier = (fpsAvg / 60).clamp(0.5, 1.0);
    }
    final adjusted = (base * multiplier).clamp(0.25, 2.0);
    final averages = await _loadRecentAverages();
    final smoothed = averages.xpFactor ?? adjusted;
    final blended = _blend(
      primary: adjusted,
      secondary: smoothed,
      bias: 0.6,
      minValue: 0.25,
      maxValue: 2.0,
    );
    _lastFpsAvg = fpsAvg;
    _lastXpFactor = adjusted;
    _lastSmoothedXp = blended;
    await _writeDynamicMetrics();
    return blended;
  }

  Future<Duration> getDynamicRefillInterval(Duration fallback) async {
    UiPerfTelemetryService.instance.start();
    final base = await getRefillInterval(fallback);
    final fpsAvg = UiPerfTelemetryService.instance.metrics.value.fpsAvg;
    double multiplier = 1.0;
    if (fpsAvg > 0 && fpsAvg < 60) {
      multiplier = (fpsAvg / 60).clamp(0.5, 1.0);
    }
    final millis = (base.inMilliseconds * multiplier).round();
    final interval = Duration(milliseconds: millis);
    final averages = await _loadRecentAverages();
    final smoothedMinutes =
        averages.energyMinutes ?? interval.inMinutes.toDouble();
    final blendedMinutes = _blend(
      primary: interval.inMinutes.toDouble(),
      secondary: smoothedMinutes,
      bias: 0.6,
      minValue: 10,
      maxValue: 120,
    );
    final blendedDuration = Duration(
      minutes: blendedMinutes.round().clamp(10, 120),
    );
    _lastFpsAvg = fpsAvg;
    _lastEnergyMinutes = blendedDuration.inMinutes;
    _lastSmoothedEnergy = blendedDuration.inMinutes;
    await _writeDynamicMetrics();
    return blendedDuration;
  }

  Future<void> _writeDynamicMetrics() async {
    final payload = jsonEncode({
      'fpsAvg': double.parse(_lastFpsAvg.toStringAsFixed(1)),
      'xpFactor': double.parse(_lastXpFactor.toStringAsFixed(3)),
      'xpSmoothed': double.parse(_lastSmoothedXp.toStringAsFixed(3)),
      'energyInterval': _lastEnergyMinutes,
      'energySmoothed': _lastSmoothedEnergy,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await File('economy_dynamic_metrics.json').writeAsString(payload);
  }

  Future<void> updateTuning({
    required double xpFactor,
    required Duration refillInterval,
  }) async {
    final data = await _load();
    data['xpFactor'] = double.parse(
      xpFactor.clamp(0.2, 3.0).toStringAsFixed(3),
    );
    data['refillMinutes'] = refillInterval.inMinutes.clamp(10, 120);
    final file = File('economy_tuning.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<_EconomyAverages> _loadRecentAverages() async {
    final file = File('economy_recalibration_log.jsonl');
    final xpValues = <double>[];
    final energyValues = <double>[];
    if (await file.exists()) {
      try {
        final lines = await file.readAsLines();
        final recentLines = lines
            .where((line) => line.trim().isNotEmpty)
            .toList()
            .reversed
            .take(_historyWindow)
            .toList();
        for (final line in recentLines) {
          try {
            final data = jsonDecode(line) as Map<String, dynamic>;
            final xpAfter = (data['xp_after'] as num?)?.toDouble();
            final refillAfter = (data['refill_after'] as num?)?.toDouble();
            if (xpAfter != null) xpValues.add(xpAfter);
            if (refillAfter != null) energyValues.add(refillAfter);
          } catch (_) {}
        }
      } catch (_) {}
    }
    double? xpAvg;
    double? energyAvg;
    if (xpValues.isNotEmpty) {
      xpAvg = xpValues.reduce((a, b) => a + b) / xpValues.length;
    }
    if (energyValues.isNotEmpty) {
      energyAvg = energyValues.reduce((a, b) => a + b) / energyValues.length;
    }
    // Fallback to dynamic metrics if no history
    if (xpAvg == null || energyAvg == null) {
      final metrics = await _readDynamicMetrics();
      xpAvg ??= metrics?.xp;
      energyAvg ??= metrics?.energy;
    }
    return _EconomyAverages(xpFactor: xpAvg, energyMinutes: energyAvg);
  }

  double _blend({
    required double primary,
    required double secondary,
    required double bias,
    double? minValue,
    double? maxValue,
  }) {
    var value = primary * bias + secondary * (1 - bias);
    if (minValue != null && value < minValue) value = minValue;
    if (maxValue != null && value > maxValue) value = maxValue;
    return value;
  }

  Future<_MetricSnapshot?> _readDynamicMetrics() async {
    final file = File('economy_dynamic_metrics.json');
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        final xp = (data['xpSmoothed'] ?? data['xpFactor']) as num?;
        final energy =
            (data['energySmoothed'] ?? data['energyInterval']) as num?;
        return _MetricSnapshot(xp?.toDouble(), energy?.toDouble());
      }
    } catch (_) {}
    return null;
  }
}

class _EconomyAverages {
  final double? xpFactor;
  final double? energyMinutes;
  const _EconomyAverages({this.xpFactor, this.energyMinutes});
}

class _MetricSnapshot {
  final double? xp;
  final double? energy;
  const _MetricSnapshot(this.xp, this.energy);
}
