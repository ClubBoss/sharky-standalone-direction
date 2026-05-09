import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

class AdaptiveDifficultyService {
  AdaptiveDifficultyService._();

  static final AdaptiveDifficultyService instance =
      AdaptiveDifficultyService._();

  static const String _telemetryPath =
      'tools/_reports/unified_telemetry_summary.json';
  static const String _releaseTelemetryPath =
      'release/public_beta_v2/unified_telemetry_summary.json';
  static const String _cachePath =
      'tools/_reports/.adaptive_difficulty_cache.json';
  static const int _historyLimit = 5;

  double getCurrentDifficultyMultiplier() {
    final telemetry = _readUnifiedTelemetry();
    if (telemetry.isEmpty) {
      final cache = _readCache();
      if (cache.isEmpty) {
        return 1.0;
      }
      final average = _average(cache);
      return _mapToMultiplier(average);
    }

    final index = _computeSkillIndex(telemetry);
    final history = _readCache();
    final previousAverage = history.isEmpty ? index : _average(history);

    final updatedHistory = <double>[...history, index];
    if (updatedHistory.length > _historyLimit) {
      updatedHistory.removeRange(0, updatedHistory.length - _historyLimit);
    }

    final newAverage = _average(updatedHistory);
    final delta = newAverage - previousAverage;
    _writeCache(updatedHistory, newAverage);

    final multiplier = _mapToMultiplier(newAverage);

    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'ai_difficulty_recalibrated',
        params: <String, Object>{
          'skill_index': double.parse(index.toStringAsFixed(4)),
          'avg_skill_index': double.parse(newAverage.toStringAsFixed(4)),
          'delta': double.parse(delta.toStringAsFixed(4)),
          'multiplier': double.parse(multiplier.toStringAsFixed(2)),
          'history_depth': updatedHistory.length,
        },
      ),
    );

    return multiplier;
  }

  Map<String, dynamic> _readUnifiedTelemetry() {
    const sources = [_telemetryPath, _releaseTelemetryPath];

    for (final path in sources) {
      final file = File(path);
      if (!file.existsSync()) continue;
      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (error) {
        stderr.writeln(
          '[WARN] AdaptiveDifficultyService telemetry read error: $error',
        );
      }
    }
    return const {};
  }

  double _computeSkillIndex(Map<String, dynamic> telemetry) {
    final derived =
        telemetry['derived_metrics'] as Map<String, dynamic>? ?? const {};

    final confidence =
        (derived['avg_confidence'] as num?)?.toDouble().clamp(0.0, 100.0) ??
        0.0;
    final retention =
        (derived['retention_score'] as num?)?.toDouble().clamp(0.0, 100.0) ??
        0.0;
    final latencyMs = (derived['avg_latency_ms'] as num?)?.toDouble() ?? 0.0;

    final confidenceNormalized = confidence / 100.0;
    final retentionNormalized = retention / 100.0;

    var latencyFactor = 1.0;
    if (latencyMs > 0) {
      latencyFactor = (latencyMs / 350.0).clamp(0.5, 2.0);
    }

    final raw = (confidenceNormalized * retentionNormalized) / latencyFactor;
    return double.parse(raw.toStringAsFixed(6));
  }

  List<double> _readCache() {
    final file = File(_cachePath);
    if (!file.existsSync()) {
      return const [];
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final history = decoded['history'];
        if (history is List) {
          return history
              .whereType<num>()
              .map((value) => value.toDouble())
              .toList();
        }
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] AdaptiveDifficultyService cache read error: $error',
      );
    }
    return const [];
  }

  void _writeCache(List<double> history, double average) {
    final file = File(_cachePath);
    try {
      file.parent.createSync(recursive: true);
      final payload = <String, Object>{
        'history': history
            .map((value) => double.parse(value.toStringAsFixed(6)))
            .toList(),
        'average': double.parse(average.toStringAsFixed(6)),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      file.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } catch (error) {
      stderr.writeln(
        '[WARN] AdaptiveDifficultyService cache write error: $error',
      );
    }
  }

  double _average(List<double> values) {
    if (values.isEmpty) return 0.0;
    final total = values.fold<double>(0.0, (sum, value) => sum + value);
    return total / values.length;
  }

  double _mapToMultiplier(double score) {
    final normalized = score.clamp(0.0, 1.0);
    final multiplier = 0.7 + (normalized * (1.3 - 0.7));
    return double.parse(multiplier.clamp(0.7, 1.3).toStringAsFixed(2));
  }
}
