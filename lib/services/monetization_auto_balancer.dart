// lib/services/monetization_auto_balancer.dart
// Stage G9B: Monetization Auto-Balancer Service
// Pure Dart service safe for CLI usage (no Flutter deps)

import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

class MonetizationAutoBalancer {
  MonetizationAutoBalancer._();
  static final MonetizationAutoBalancer instance = MonetizationAutoBalancer._();

  /// Recalibrate economy multipliers based on unified telemetry and
  /// monetization projection. Target multiplier is 1.0; if best suggestion
  /// deviates by more than ±15%, we adjust xp_factor accordingly.
  /// Returns a small summary map for logging/debugging.
  Future<Map<String, Object>> recalibrate() async {
    // Read unified telemetry (not directly used yet; reserved for future weighting)
    _readJson(const [
      'tools/_reports/unified_telemetry_summary.json',
      'release/public_beta_v2/unified_telemetry_summary.json',
    ]);
    final projection = _readJson(const [
      'tools/_reports/monetization_projection.json',
      'release/public_beta_v2/monetization_projection.json',
    ]);

    final bestMultiplier = _extractBestMultiplier(projection) ?? 1.0;
    final xpFlowAtBest = _extractFlow(
      projection,
      bestMultiplier,
      key: 'xp_flow',
    );
    final chipFlowAtBest = _extractFlow(
      projection,
      bestMultiplier,
      key: 'chip_flow',
    );

    final tuningFile = File('economy_tuning.json');
    final currentTuning = _readJsonSingle('economy_tuning.json');
    final currentXp =
        _asDouble(currentTuning['xp_factor']) ??
        _asDouble(currentTuning['xpFactor']) ??
        1.0;

    // Compute deviation from target 1.0
    final deviation = bestMultiplier - 1.0;
    const threshold = 0.15; // ±15%
    double newXp = currentXp;
    bool applied = false;
    if (deviation.abs() > threshold) {
      // Apply proportional scaling against current factor; clamp to safe range.
      final scale = (1.0 + deviation);
      newXp = _clampDouble(
        double.parse((currentXp * scale).toStringAsFixed(3)),
        0.5,
        1.6,
      );
      applied = true;
      _writeEconomyTuning(tuningFile, currentTuning, newXp);
    }

    // Emit telemetry event with before/after and context
    final payload = <String, Object>{
      'best_multiplier': double.parse(bestMultiplier.toStringAsFixed(3)),
      'deviation_percent': double.parse((deviation * 100).toStringAsFixed(1)),
      'applied': applied,
      'xp_before': double.parse(currentXp.toStringAsFixed(3)),
      'xp_after': double.parse(newXp.toStringAsFixed(3)),
    };
    if (xpFlowAtBest != null) {
      payload['xp_flow_best'] = double.parse(xpFlowAtBest.toStringAsFixed(1));
    }
    if (chipFlowAtBest != null) {
      payload['chip_flow_best'] = double.parse(
        chipFlowAtBest.toStringAsFixed(1),
      );
    }

    // Non-blocking telemetry
    // ignore: unawaited_futures
    FirebaseLiteTelemetryService.instance.logEvent(
      'monetization_autobalanced',
      params: payload,
    );

    return {
      'applied': applied,
      'xp_before': currentXp,
      'xp_after': newXp,
      'best_multiplier': bestMultiplier,
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

  double? _extractBestMultiplier(Map<String, dynamic> projection) {
    // Try new flat field first
    final flat = _asDouble(projection['avg_multiplier']);
    if (flat != null) return flat;
    // Try summary.best_multiplier (string or num)
    final summary = projection['summary'];
    if (summary is Map<String, dynamic>) {
      final v = summary['best_multiplier'];
      if (v is num) return v.toDouble();
      if (v is String) {
        final p = double.tryParse(v);
        if (p != null) return p;
      }
    }
    return null;
  }

  double? _extractFlow(
    Map<String, dynamic> projection,
    double bestMult, {
    required String key,
  }) {
    // If flat field exists, return it
    final flat = projection[key];
    if (flat is num) return flat.toDouble();
    if (flat is String) return double.tryParse(flat);

    // Else find row in rows with multiplier ≈ bestMult
    final rows = projection['rows'];
    if (rows is List) {
      for (final row in rows) {
        if (row is Map<String, dynamic>) {
          final m = _asDouble(row['multiplier']) ?? 0.0;
          if ((m - bestMult).abs() <= 0.051) {
            final v = row[key];
            if (v is num) return v.toDouble();
          }
        }
      }
    }
    return null;
  }

  void _writeEconomyTuning(
    File file,
    Map<String, dynamic> current,
    double xpFactor,
  ) {
    final updated = {
      ...current,
      'xp_factor': double.parse(xpFactor.toStringAsFixed(3)),
      // Keep parallel field some tools reference
      'xpFactor': double.parse(xpFactor.toStringAsFixed(3)),
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
