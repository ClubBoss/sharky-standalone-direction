import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'adaptive_reward_economy.dart';
import 'overlay_manager.dart';
import 'player_progression_service.dart';
import 'firebase_lite_telemetry_service.dart';

/// Provides a narrow, stable entry-point for UX rewards and feedback.
///
/// This is a pure service with no direct UI interactions. All public methods
/// are safe to call in production; they update simple in-memory counters and
/// emit non-blocking telemetry via [FirebaseLiteTelemetryService].
///
/// Runtime behavior is intentionally a no-op (no haptics, no sounds) for now;
/// wiring into UI or engines will happen in later steps.
final class UxFeedbackManager {
  UxFeedbackManager._();

  /// Singleton instance for app-wide access.
  static final UxFeedbackManager instance = UxFeedbackManager._();

  // ignore: unused_field
  int _xpTotal = 0;
  // ignore: unused_field
  int _chipsTotal = 0;
  int _grantsCount = 0;

  // UI-level events (e.g., level-up) are surfaced by PlayerProgressionService
  // to avoid circular dependencies. This manager remains telemetry-focused.

  // Broadcast stream for session summary events (end-of-session recap).
  final StreamController<SessionSummaryEvent> _sessionSummaryController =
      StreamController<SessionSummaryEvent>.broadcast();

  /// A broadcast stream emitting end-of-session summaries for UI cards.
  Stream<SessionSummaryEvent> get onSessionSummary =>
      _sessionSummaryController.stream;

  /// Manually show a session summary card by emitting an event to listeners.
  /// This is a pure signal; UI layers decide how to render it.
  void showSummary({
    required int xpDelta,
    required int chipsDelta,
    required int newLevel,
    required int streakDelta,
    required String leagueTier,
  }) {
    _sessionSummaryController.add(
      SessionSummaryEvent(
        xpDelta: xpDelta,
        chipsDelta: chipsDelta,
        newLevel: newLevel,
        streakDelta: streakDelta,
        leagueTier: leagueTier,
      ),
    );
    unawaited(
      OverlayManager.instance.show(OverlayType.summary, <String, Object?>{
        'xp_delta': xpDelta,
        'chips_delta': chipsDelta,
        'new_level': newLevel,
        'streak_delta': streakDelta,
        'league_tier': leagueTier,
      }),
    );
  }

  /// Grants a reward and logs telemetry.
  ///
  /// Side effects:
  /// - Clamps negative inputs to zero.
  /// - Updates in-memory counters: `_xpTotal`, `_chipsTotal`, `_grantsCount`.
  /// - Emits telemetry event `ux_reward_granted` (non-blocking).
  ///
  /// Telemetry keys:
  /// - `xp` (int, >= 0)
  /// - `chips` (int, >= 0)
  /// - `latency_ms` (int, -1 when unknown)
  /// - `grants_total` (int, cumulative grants in this session)
  void grantReward({int xp = 0, int chips = 0, int? latencyMs}) {
    final safeXp = xp < 0 ? 0 : xp;
    final safeChips = chips < 0 ? 0 : chips;
    final safeLatency = latencyMs == null
        ? -1
        : (latencyMs < 0 ? 0 : latencyMs);

    final adaptiveDecision = AdaptiveRewardEconomy.instance.scaleReward(
      xp: safeXp,
      chips: safeChips,
    );
    final adjustedXp = adaptiveDecision.adjustedXp;
    final adjustedChips = adaptiveDecision.adjustedChips;

    // Update counters with adjusted rewards.
    _xpTotal += adjustedXp;
    _chipsTotal += adjustedChips;
    _grantsCount += 1;

    // Non-blocking telemetry.
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'ux_reward_granted',
        params: <String, Object?>{
          'xp': adjustedXp,
          'chips': adjustedChips,
          'base_xp': safeXp,
          'base_chips': safeChips,
          'reward_multiplier': adaptiveDecision.multiplier,
          // If latency is unknown, emit -1 as requested; otherwise the clamped value.
          'latency_ms': latencyMs == null ? -1 : safeLatency,
          'grants_total': _grantsCount,
          'reward_reason': adaptiveDecision.reason,
        },
      ),
    );

    if (kDebugMode) {
      // ASCII-only debug print for local visibility.
      debugPrint(
        'UxFeedbackManager.grantReward base_xp=$safeXp base_chips=$safeChips '
        'xp=$adjustedXp chips=$adjustedChips '
        'multiplier=${adaptiveDecision.multiplier.toStringAsFixed(2)} '
        'latency_ms=${latencyMs == null ? -1 : safeLatency} grants_total=$_grantsCount',
      );
    }

    unawaited(
      OverlayManager.instance.show(OverlayType.reward, <String, Object?>{
        'xp': adjustedXp,
        'chips': adjustedChips,
      }),
    );

    PlayerProgressionService.instance.applyReward(
      xp: adjustedXp,
      chips: adjustedChips,
    );
  }

  /// Plays (or simulates) sensory feedback and logs telemetry.
  ///
  /// This method does not perform any real haptics or sounds yet. It only logs
  /// an ASCII-safe event `ux_feedback_played` with the requested toggles.
  ///
  /// Telemetry keys:
  /// - `haptic` (bool)
  /// - `sound` (bool)
  /// - `celebratory` (bool)
  void playFeedback({
    bool haptic = true,
    bool sound = true,
    bool celebratory = false,
  }) {
    // Non-blocking telemetry only; no actual I/O or platform feedback.
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'ux_feedback_played',
        params: <String, Object?>{
          'haptic': haptic,
          'sound': sound,
          'celebratory': celebratory,
        },
      ),
    );

    if (kDebugMode) {
      debugPrint(
        'UxFeedbackManager.playFeedback haptic=$haptic sound=$sound celebratory=$celebratory',
      );
    }
  }

  /// Resets in-memory session counters for rewards.
  ///
  /// This clears only local counters and does not emit telemetry.
  void resetSessionCounters() {
    _xpTotal = 0;
    _chipsTotal = 0;
    _grantsCount = 0;

    if (kDebugMode) {
      debugPrint('UxFeedbackManager.resetSessionCounters');
    }
  }

  /// Computes adaptive reward scaling using unified telemetry metrics.
  ///
  /// The calculation combines advisor confidence and UX latency readings:
  /// - High confidence (>=70) with low latency (<=250ms or unknown) boosts rewards.
  /// - Medium confidence (>=40) keeps rewards neutral when latency is moderate.
  /// - Low confidence (<40) or high latency (>600ms) reduces rewards.
  ///
  /// Returns the adjusted XP/chips along with the applied scaling factor. The
  /// manager adjusts in-memory counters to reflect the scaling delta and emits
  /// an ASCII-safe telemetry event `ux_reward_adjusted`.
  Future<AdaptiveRewardResult> computeAdaptiveReward({
    required int xp,
    required int chips,
  }) async {
    const double minScale = 0.5;
    const double maxScale = 1.5;

    final baseResult = AdaptiveRewardResult(
      adjustedXp: xp,
      adjustedChips: chips,
      scalingFactor: 1.0,
    );

    final telemetry = await _loadUnifiedTelemetry();
    if (telemetry.isEmpty) {
      return baseResult;
    }

    try {
      final derived =
          telemetry['derived_metrics'] as Map<String, dynamic>? ?? const {};
      final avgConfidence =
          (derived['avg_confidence'] as num?)?.toDouble() ?? 0.0;
      final avgLatencyMs =
          (derived['avg_latency_ms'] as num?)?.toDouble() ?? 0.0;

      final isHighConfidence = avgConfidence >= 70.0;
      final isMediumConfidence = avgConfidence >= 40.0;
      final hasLowLatency = avgLatencyMs == 0 || avgLatencyMs <= 250.0;
      final hasHighLatency = avgLatencyMs > 600.0;

      double scale;
      if (isHighConfidence && hasLowLatency) {
        scale = 1.2;
      } else if (isMediumConfidence && !hasHighLatency) {
        scale = 1.0;
      } else {
        scale = 0.8;
      }

      final scalingFactor = scale.clamp(minScale, maxScale).toDouble();
      final adjustedXp = (xp * scalingFactor).round();
      final adjustedChips = (chips * scalingFactor).round();

      final xpDelta = adjustedXp - xp;
      final chipsDelta = adjustedChips - chips;
      if (xpDelta != 0) {
        _xpTotal += xpDelta;
      }
      if (chipsDelta != 0) {
        _chipsTotal += chipsDelta;
      }

      unawaited(
        FirebaseLiteTelemetryService.instance.logEvent(
          'ux_reward_adjusted',
          params: <String, Object?>{
            'base_xp': xp,
            'base_chips': chips,
            'adjusted_xp': adjustedXp,
            'adjusted_chips': adjustedChips,
            'scaling_factor': scalingFactor,
            'avg_confidence': double.parse(avgConfidence.toStringAsFixed(2)),
            'avg_latency_ms': double.parse(avgLatencyMs.toStringAsFixed(2)),
          },
        ),
      );

      if (kDebugMode) {
        debugPrint(
          'UxFeedbackManager.computeAdaptiveReward xp=$xp chips=$chips '
          'scale=${scalingFactor.toStringAsFixed(2)} '
          'avg_confidence=${avgConfidence.toStringAsFixed(2)} '
          'avg_latency_ms=${avgLatencyMs.toStringAsFixed(2)}',
        );
      }

      return AdaptiveRewardResult(
        adjustedXp: adjustedXp,
        adjustedChips: adjustedChips,
        scalingFactor: scalingFactor,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('UxFeedbackManager.computeAdaptiveReward error: $error');
      }
      return baseResult;
    }
  }

  Future<Map<String, dynamic>> _loadUnifiedTelemetry() async {
    final paths = <String>['tools/_reports/unified_telemetry_summary.json'];
    if (kReleaseMode) {
      paths.add('release/public_beta_v2/unified_telemetry_summary.json');
    }
    for (final path in paths) {
      try {
        final file = File(path);
        if (!await file.exists()) {
          continue;
        }
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint('UxFeedbackManager._loadUnifiedTelemetry failed: $error');
        }
      }
    }
    return const {};
  }
}

/// Value object describing the result of adaptive reward scaling.
final class AdaptiveRewardResult {
  const AdaptiveRewardResult({
    required this.adjustedXp,
    required this.adjustedChips,
    required this.scalingFactor,
  });

  final int adjustedXp;
  final int adjustedChips;
  final double scalingFactor;
}

/// Value object for presenting a session-end summary.
final class SessionSummaryEvent {
  const SessionSummaryEvent({
    required this.xpDelta,
    required this.chipsDelta,
    required this.newLevel,
    required this.streakDelta,
    required this.leagueTier,
  });

  final int xpDelta;
  final int chipsDelta;
  final int newLevel;
  final int streakDelta;
  final String leagueTier;
}
