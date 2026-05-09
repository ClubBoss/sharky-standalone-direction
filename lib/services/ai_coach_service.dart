import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_engine.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

/// Spot descriptor for AI coach evaluation.
class AiCoachSpot {
  AiCoachSpot({
    required this.userAction,
    required this.street,
    required this.pot,
    required this.heroStack,
    required this.currentBet,
    required this.numActivePlayers,
    this.heroPosition = 0,
  });

  final String userAction; // fold/call/raise/check/bet
  final String street; // preFlop, flop, turn, river
  final int pot;
  final int heroStack;
  final int currentBet;
  final int numActivePlayers;
  final int heroPosition; // 0=BTN, 1=SB, 2=BB, etc.
}

/// AI Coach feedback for a single decision.
class AiCoachFeedback {
  AiCoachFeedback({
    required this.action,
    required this.isOptimal,
    required this.confidenceScore,
    required this.evDifference,
    required this.message,
    required this.rationale,
    this.suggestedAction,
  });

  final String action;
  final bool isOptimal;
  final double confidenceScore; // 0.0 - 1.0
  final double evDifference; // in BB
  final String message;
  final String rationale;
  final String? suggestedAction;
}

/// Loads simplified GTO rules from assets and evaluates actions.
///
/// Asset path: assets/json/gto_rules.json
class AiCoachService {
  AiCoachService();

  Map<String, dynamic>? _rules;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/json/gto_rules.json');
      _rules = json.decode(jsonStr) as Map<String, dynamic>;
      _loaded = true;
    } catch (_) {
      // Fall back to empty rules; engine heuristics can still be used.
      _rules = <String, dynamic>{};
      _loaded = true;
    }
  }

  /// Evaluate the given spot and return feedback using simple rules.
  /// If rules are missing, falls back to heuristics via AiCoachEngine for continuity.
  Future<AiCoachFeedback> evaluateAction(AiCoachSpot spot) async {
    await load();
    final rules = _rules ?? const <String, dynamic>{};

    // Simple lookup: by street, action
    final streetKey = spot.street.toLowerCase();
    final actionKey = spot.userAction.toLowerCase();
    final streetRules = (rules[streetKey] as Map?) ?? const {};
    final actionRule = (streetRules[actionKey] as Map?) ?? const {};

    // Defaults when no rule found
    final String optimal = (actionRule['optimal'] as String?) ?? actionKey;
    final double confidence = ((actionRule['confidence'] as num?) ?? 0.6)
        .toDouble();
    final double baseEv = ((actionRule['base_ev'] as num?) ?? 0.1).toDouble();
    final String reason =
        (actionRule['reason'] as String?) ?? 'Heuristic recommendation';

    // Simple EV adjustment based on pot/currentBet
    double evDiff = baseEv;
    if (optimal != actionKey) {
      // Penalize mismatch
      evDiff = -(spot.currentBet * 0.1 + spot.pot * 0.05);
    }

    final isOptimal = actionKey == optimal.toLowerCase();

    // Build message similar to engine style
    final message = isOptimal
        ? (evDiff > 0.5
              ? 'Excellent $actionKey!'
              : (evDiff > 0.2 ? 'Good $actionKey' : 'Solid $actionKey'))
        : 'Consider $optimal (EV ${evDiff >= 0 ? "+${evDiff.toStringAsFixed(1)}" : evDiff.toStringAsFixed(1)} BB)';

    // Log telemetry (ASCII-only)
    try {
      final eventName = isOptimal ? 'ai_coach_correct' : 'ai_coach_missed';
      // ignore: discarded_futures
      FirebaseLiteTelemetryService.instance.logEvent(
        eventName,
        params: {
          'street': streetKey,
          'action': actionKey,
          'confidence': (confidence * 100).toInt(),
          'ev_bb': evDiff.toStringAsFixed(2),
          'players': spot.numActivePlayers,
        },
      );
      // Hint event for visibility
      // ignore: discarded_futures
      FirebaseLiteTelemetryService.instance.logEvent(
        'ai_coach_hint',
        params: {'message': message},
      );
    } catch (_) {
      // No-op in tests.
    }

    return AiCoachFeedback(
      action: spot.userAction,
      isOptimal: isOptimal,
      confidenceScore: confidence,
      evDifference: evDiff,
      message: message,
      rationale: reason,
      suggestedAction: isOptimal ? null : optimal,
    );
  }

  /// Convenience adapter to convert AiCoachFeedback to existing CoachingFeedback
  /// so existing overlay/engine can display it.
  CoachingFeedback toCoaching(AiCoachFeedback f) => CoachingFeedback(
    action: f.action,
    isOptimal: f.isOptimal,
    confidenceScore: f.confidenceScore,
    evDifference: f.evDifference,
    message: f.message,
    rationale: f.rationale,
    suggestedAction: f.suggestedAction,
  );
}
