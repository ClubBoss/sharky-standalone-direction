import 'dart:convert';
import 'dart:io';

import 'analytics_service.dart';
import '../models/v2/training_pack_spot.dart';

/// Applies deterministic adaptive factors at runtime based on tools outputs.
///
/// Inputs (if present in repo root):
/// - adaptive_behavior_summary.json -> { adjustment: <double 0.75..1.25> }
/// - adaptive_learning_summary.json -> { momentum: <0..1>, fatigue: <0..1> }
///
/// Behavior:
/// - Scales per-spot meta fields if they exist:
///   - difficulty_score (clamped to 1..5)
///   - xp_reward (>= 1, integer)
/// - Adds meta flags: {
///     'adaptiveApplied': true,
///     'adaptive_adjustment': <double>,
///   }
/// - Emits a lightweight telemetry event 'runtime_adaptive_applied'.
class AdaptiveRuntimeService {
  AdaptiveRuntimeService._();

  static Future<double> _readAdjustmentFactor() async {
    try {
      final f = File('adaptive_behavior_summary.json');
      if (!await f.exists()) return 1.0;
      final data = jsonDecode(await f.readAsString());
      if (data is Map && data['adjustment'] is num) {
        final v = (data['adjustment'] as num).toDouble();
        // Safety clamp to expected bounds.
        return v.clamp(0.75, 1.25);
      }
    } catch (_) {}
    return 1.0;
  }

  static Future<Map<String, double>> _readLearningState() async {
    try {
      final f = File('adaptive_learning_summary.json');
      if (!await f.exists()) return const {'momentum': 0.0, 'fatigue': 0.0};
      final data = jsonDecode(await f.readAsString());
      if (data is Map) {
        final m = (data['momentum'] as num?)?.toDouble() ?? 0.0;
        final fpct = (data['fatigue'] as num?)?.toDouble() ?? 0.0; // in %
        // Normalize fatigue to 0..1 internally.
        return {'momentum': m, 'fatigue': (fpct / 100.0).clamp(0.0, 1.0)};
      }
    } catch (_) {}
    return const {'momentum': 0.0, 'fatigue': 0.0};
  }

  /// Applies adaptive scaling to spots in-place and returns average deltas.
  ///
  /// Returns: {
  ///   'deltaDifficultyPercent': <double>,
  ///   'deltaXpPercent': <double>,
  ///   'factor': <double>,
  ///   'momentum': <double>,
  ///   'fatigue': <double>, // 0..1
  /// }
  static Future<Map<String, double>> applyToSpots(
    List<TrainingPackSpot> spots,
  ) async {
    if (spots.isEmpty) {
      return {
        'deltaDifficultyPercent': 0.0,
        'deltaXpPercent': 0.0,
        'factor': 1.0,
        'momentum': 0.0,
        'fatigue': 0.0,
      };
    }

    final factor = await _readAdjustmentFactor();
    final learn = await _readLearningState();
    double sumDiffPct = 0.0;
    double sumXpPct = 0.0;
    int nDiff = 0;
    int nXp = 0;

    for (final s in spots) {
      // Always mark that adaptive step ran (for debugging/inspection).
      s.meta['adaptiveApplied'] = true;
      s.meta['adaptive_adjustment'] = factor;

      final oldDiff = s.meta['difficulty_score'];
      if (oldDiff is num) {
        final base = oldDiff.toDouble();
        final scaled = (base * factor).clamp(1.0, 5.0);
        s.meta['difficulty_score'] = scaled is int ? scaled : scaled;
        if (base > 0) {
          sumDiffPct += ((scaled - base) / base) * 100.0;
          nDiff++;
        }
      }

      final oldXp = s.meta['xp_reward'];
      if (oldXp is num) {
        final base = oldXp.toDouble();
        final scaled = (base * factor);
        final rounded = scaled.round();
        s.meta['xp_reward'] = rounded < 1 ? 1 : rounded;
        if (base > 0) {
          sumXpPct += ((rounded - base) / base) * 100.0;
          nXp++;
        }
      }
    }

    final avgDiff = nDiff > 0 ? (sumDiffPct / nDiff) : 0.0;
    final avgXp = nXp > 0 ? (sumXpPct / nXp) : 0.0;

    // Emit a lightweight telemetry event for observability.
    AnalyticsService.instance.logEvent('runtime_adaptive_applied', {
      'factor': factor,
      'spots': spots.length,
      'deltaDifficultyPercent': double.parse(avgDiff.toStringAsFixed(2)),
      'deltaXpPercent': double.parse(avgXp.toStringAsFixed(2)),
      'momentum': learn['momentum'] ?? 0.0,
      'fatigue': learn['fatigue'] ?? 0.0,
    });

    return {
      'deltaDifficultyPercent': avgDiff,
      'deltaXpPercent': avgXp,
      'factor': factor,
      'momentum': learn['momentum'] ?? 0.0,
      'fatigue': learn['fatigue'] ?? 0.0,
    };
  }
}
