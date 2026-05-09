import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ui_perf_telemetry_service.dart';

class AdaptivePacingEngine {
  AdaptivePacingEngine._();
  static final AdaptivePacingEngine instance = AdaptivePacingEngine._();

  /// Compute pacing factor directly from momentum, fatigue, and fps input.
  static double computePace({
    required double momentum,
    required double fatigue,
    double fps = 60,
  }) {
    double pace = 1.0 + momentum * 0.2 - fatigue * 0.4;
    pace = pace.clamp(0.8, 1.2);
    if (fps > 0 && fps < 60) {
      final perfPenalty = (fps / 60).clamp(0.5, 1.0);
      pace *= perfPenalty;
    }
    return pace.clamp(0.5, 1.2);
  }

  Future<double> getPaceFactor() async {
    try {
      final file = File('adaptive_learning_summary.json');
      if (!await file.exists()) return _withPerfPenalty(1.0);
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return _withPerfPenalty(1.0);
      final momentum = (data['learningMomentum'] as num?)?.toDouble() ?? 0.0;
      final fatigue = (data['fatiguePenalty'] as num?)?.toDouble() ?? 0.0;
      final pace = 1.0 + momentum * 0.2 - fatigue * 0.4;
      return _withPerfPenalty(pace.clamp(0.8, 1.2));
    } catch (_) {
      return _withPerfPenalty(1.0);
    }
  }

  Future<double> getAdjustedXpReward(int base) async {
    final pace = await getPaceFactor();
    return base * pace;
  }

  Future<double> getAdjustedEnergyCost(int base) async {
    final pace = await getPaceFactor();
    final safe = pace.clamp(0.6, 1.2);
    return base / safe;
  }

  double _withPerfPenalty(double pace) {
    UiPerfTelemetryService.instance.start();
    final fps = UiPerfTelemetryService.instance.metrics.value.fpsAvg;
    if (fps > 0 && fps < 50) {
      final penalty = (fps / 60).clamp(0.5, 1.0);
      pace *= penalty;
    }
    return pace.clamp(0.5, 1.2);
  }
}
