// lib/services/chip_flow_balancer.dart
// Stage G9C: Chip Flow Balancer (pure Dart, CLI-safe)

import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

class ChipFlowBalancer {
  ChipFlowBalancer._();
  static final ChipFlowBalancer instance = ChipFlowBalancer._();

  /// Recalibrate chip_factor based on monetization projection chip_flow.
  /// Target is 1.0; if |chip_flow - 1.0| > 0.15, apply proportional scaling
  /// and clamp to [0.6, 1.5]. Returns compact summary for logs.
  Future<Map<String, Object>> recalibrate() async {
    final projection = _readJson(const [
      'tools/_reports/monetization_projection.json',
      'release/public_beta_v2/monetization_projection.json',
    ]);

    final chipFlow = _asDouble(projection['chip_flow']);
    if (chipFlow == null) {
      // No normalized chip flow provided → skip.
      return {'applied': false, 'reason': 'no_chip_flow'};
    }

    final tuningPath = 'economy_tuning.json';
    final currentTuning = _readJsonSingle(tuningPath);
    final currentChip =
        _asDouble(currentTuning['chip_factor']) ??
        _asDouble(currentTuning['chipFactor']) ??
        1.0;

    final deviation = chipFlow - 1.0; // >0 → flowing high, reduce factor
    const threshold = 0.15; // ±15%
    double newChip = currentChip;
    bool applied = false;

    if (deviation.abs() > threshold) {
      final scale = (1.0 + deviation);
      newChip = _clampDouble(
        double.parse((currentChip * scale).toStringAsFixed(3)),
        0.6,
        1.5,
      );
      applied = true;
      _writeEconomyTuning(File(tuningPath), currentTuning, newChip);
    }

    final payload = <String, Object>{
      'chip_flow': double.parse(chipFlow.toStringAsFixed(3)),
      'deviation_percent': double.parse((deviation * 100).toStringAsFixed(1)),
      'applied': applied,
      'chip_before': double.parse(currentChip.toStringAsFixed(3)),
      'chip_after': double.parse(newChip.toStringAsFixed(3)),
    };

    // ignore: unawaited_futures
    FirebaseLiteTelemetryService.instance.logEvent(
      'chip_flow_rebalanced',
      params: payload,
    );

    return {
      'applied': applied,
      'chip_before': currentChip,
      'chip_after': newChip,
      'deviation_percent': double.parse((deviation * 100).toStringAsFixed(1)),
    };
  }

  Map<String, dynamic> _readJson(List<String> paths) {
    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return const {};
  }

  Map<String, dynamic> _readJsonSingle(String path) {
    final file = File(path);
    if (!file.existsSync()) return const {};
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return const {};
  }

  void _writeEconomyTuning(
    File file,
    Map<String, dynamic> current,
    double chipFactor,
  ) {
    final updated = {
      ...current,
      'chip_factor': double.parse(chipFactor.toStringAsFixed(3)),
    };
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(updated));
  }

  double? _asDouble(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  double _clampDouble(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }
}
