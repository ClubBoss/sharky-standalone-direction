import 'dart:async';
import 'dart:io';
import 'dart:math';

/// Represents a coaching decision evaluation with rationale and EV analysis.
class CoachingFeedback {
  CoachingFeedback({
    required this.action,
    required this.isOptimal,
    required this.confidenceScore,
    required this.evDifference,
    required this.message,
    required this.rationale,
    this.suggestedAction,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String action; // User's action: fold, call, raise, check, bet
  final bool isOptimal; // Whether action matches GTO recommendation
  final double confidenceScore; // 0.0 to 1.0, how confident AI is
  final double
  evDifference; // EV difference in BB: positive = good, negative = bad
  final String message; // Short feedback: "Good fold", "Raise missed value"
  final String rationale; // Detailed explanation
  final String? suggestedAction; // What AI recommends if not optimal
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'is_optimal': isOptimal,
      'confidence_score': confidenceScore,
      'ev_difference': evDifference,
      'message': message,
      'rationale': rationale,
      if (suggestedAction != null) 'suggested_action': suggestedAction,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// AI Coach engine that evaluates user decisions against GTO ranges.
///
/// Provides real-time feedback with confidence scores, EV calculations,
/// and contextual rationale for optimal play.
class AiCoachEngine {
  AiCoachEngine({this.enabled = true});

  bool enabled;
  final _controller = StreamController<CoachingFeedback>.broadcast();

  Stream<CoachingFeedback> get feedbackStream => _controller.stream;

  /// Evaluate user action and generate coaching feedback.
  ///
  /// Parameters:
  /// - userAction: The action taken by the user
  /// - street: Current betting round (preFlop, flop, turn, river)
  /// - pot: Current pot size in BB
  /// - heroStack: Hero's remaining stack in BB
  /// - currentBet: Current bet to call in BB
  /// - numActivePlayers: Number of players still in hand
  /// - heroPosition: Position (0=button, 1=SB, 2=BB, etc.)
  CoachingFeedback evaluateAction({
    required String userAction,
    required String street,
    required int pot,
    required int heroStack,
    required int currentBet,
    required int numActivePlayers,
    int heroPosition = 0,
  }) {
    if (!enabled) {
      return CoachingFeedback(
        action: userAction,
        isOptimal: true,
        confidenceScore: 0.0,
        evDifference: 0.0,
        message: 'Coach disabled',
        rationale: 'AI coaching is currently disabled',
      );
    }

    // Calculate pot odds
    final potOdds = currentBet > 0 ? currentBet / (pot + currentBet) : 0.0;

    // Determine optimal action based on simplified GTO logic
    final gtoRecommendation = _computeGtoRecommendation(
      street: street,
      pot: pot,
      heroStack: heroStack,
      currentBet: currentBet,
      potOdds: potOdds,
      numActivePlayers: numActivePlayers,
      heroPosition: heroPosition,
    );

    // Compare user action to GTO recommendation
    final isOptimal =
        userAction.toLowerCase() == gtoRecommendation.action.toLowerCase();

    // Calculate EV difference (simplified)
    final evDiff = _calculateEvDifference(
      userAction: userAction,
      optimalAction: gtoRecommendation.action,
      pot: pot,
      currentBet: currentBet,
      heroStack: heroStack,
      potOdds: potOdds,
    );

    // Generate contextual message
    final message = _generateFeedbackMessage(
      userAction: userAction,
      isOptimal: isOptimal,
      evDiff: evDiff,
      gtoRecommendation: gtoRecommendation,
    );

    // Generate detailed rationale
    final rationale = _generateRationale(
      userAction: userAction,
      gtoRecommendation: gtoRecommendation,
      street: street,
      pot: pot,
      currentBet: currentBet,
      potOdds: potOdds,
      numActivePlayers: numActivePlayers,
    );

    final feedback = CoachingFeedback(
      action: userAction,
      isOptimal: isOptimal,
      confidenceScore: gtoRecommendation.confidence,
      evDifference: evDiff,
      message: message,
      rationale: rationale,
      suggestedAction: isOptimal ? null : gtoRecommendation.action,
    );

    // Emit feedback to stream
    _controller.add(feedback);

    // Log to stdout (ASCII-only)
    stdout.writeln(
      '[AiCoach] Action: $userAction | Optimal: $isOptimal | '
      'EV: ${evDiff.toStringAsFixed(2)} BB | Confidence: '
      '${(gtoRecommendation.confidence * 100).toStringAsFixed(0)}%',
    );

    return feedback;
  }

  /// Compute GTO recommendation based on game state.
  _GtoRecommendation _computeGtoRecommendation({
    required String street,
    required int pot,
    required int heroStack,
    required int currentBet,
    required double potOdds,
    required int numActivePlayers,
    required int heroPosition,
  }) {
    // Simplified GTO logic based on common poker principles

    // If no bet to face, prefer aggression
    if (currentBet == 0) {
      // Open position: bet more often
      if (heroPosition == 0) {
        // Button position
        return _GtoRecommendation(
          action: 'bet',
          confidence: 0.75,
          reason: 'Positional advantage warrants aggression',
        );
      } else if (heroPosition <= 2) {
        // Blinds
        return _GtoRecommendation(
          action: Random().nextDouble() > 0.6 ? 'bet' : 'check',
          confidence: 0.65,
          reason: 'Mixed strategy from early position',
        );
      } else {
        return _GtoRecommendation(
          action: 'check',
          confidence: 0.60,
          reason: 'Out of position, prefer pot control',
        );
      }
    }

    // Facing a bet: compute calling/folding decision
    final callAmount = currentBet;
    final potOddsPercent = potOdds * 100;

    // If pot odds are favorable and stack is deep, consider calling/raising
    if (potOddsPercent < 33 && heroStack > callAmount * 3) {
      // Good pot odds
      if (street == 'river') {
        return _GtoRecommendation(
          action: 'call',
          confidence: 0.80,
          reason: 'Favorable pot odds on river',
        );
      } else {
        // Earlier streets: mix between call and raise
        return _GtoRecommendation(
          action: Random().nextDouble() > 0.5 ? 'raise' : 'call',
          confidence: 0.70,
          reason: 'Good pot odds with implied odds',
        );
      }
    } else if (potOddsPercent > 50 || heroStack < callAmount * 2) {
      // Poor pot odds or short stack
      return _GtoRecommendation(
        action: 'fold',
        confidence: 0.85,
        reason: 'Unfavorable pot odds or stack depth',
      );
    } else {
      // Marginal situation
      if (numActivePlayers > 2) {
        return _GtoRecommendation(
          action: 'fold',
          confidence: 0.60,
          reason: 'Multiway pot increases difficulty',
        );
      } else {
        return _GtoRecommendation(
          action: 'call',
          confidence: 0.55,
          reason: 'Marginal spot, but heads-up',
        );
      }
    }
  }

  /// Calculate EV difference between user action and optimal action.
  double _calculateEvDifference({
    required String userAction,
    required String optimalAction,
    required int pot,
    required int currentBet,
    required int heroStack,
    required double potOdds,
  }) {
    if (userAction.toLowerCase() == optimalAction.toLowerCase()) {
      // Optimal action: small positive EV
      return 0.1 + Random().nextDouble() * 0.3;
    }

    // Suboptimal action: calculate penalty
    final userLower = userAction.toLowerCase();
    final optimalLower = optimalAction.toLowerCase();

    if (userLower == 'fold' && optimalLower == 'call') {
      // Folding when should call: lose potential pot equity
      return -(pot * 0.2 + Random().nextDouble() * 0.3);
    } else if (userLower == 'fold' && optimalLower == 'raise') {
      // Folding when should raise: miss value
      return -(pot * 0.4 + Random().nextDouble() * 0.5);
    } else if (userLower == 'call' && optimalLower == 'fold') {
      // Calling when should fold: lose call amount
      return -(currentBet * 0.8 + Random().nextDouble() * 0.4);
    } else if (userLower == 'call' && optimalLower == 'raise') {
      // Calling when should raise: miss value
      return -(pot * 0.2 + Random().nextDouble() * 0.3);
    } else if (userLower == 'raise' && optimalLower == 'fold') {
      // Raising when should fold: major mistake
      return -(currentBet * 1.5 + Random().nextDouble() * 1.0);
    } else if (userLower == 'raise' && optimalLower == 'call') {
      // Raising when should call: minor mistake
      return -(pot * 0.1 + Random().nextDouble() * 0.2);
    } else if (userLower == 'check' && optimalLower == 'bet') {
      // Checking when should bet: miss value
      return -(pot * 0.3 + Random().nextDouble() * 0.4);
    } else if (userLower == 'bet' && optimalLower == 'check') {
      // Betting when should check: minor mistake
      return -(pot * 0.1 + Random().nextDouble() * 0.2);
    }

    // Default: small negative EV for any mismatch
    return -(0.2 + Random().nextDouble() * 0.3);
  }

  /// Generate short feedback message for display.
  String _generateFeedbackMessage({
    required String userAction,
    required bool isOptimal,
    required double evDiff,
    required _GtoRecommendation gtoRecommendation,
  }) {
    if (isOptimal) {
      if (evDiff > 0.5) {
        return 'Excellent ${userAction.toLowerCase()}!';
      } else if (evDiff > 0.2) {
        return 'Good ${userAction.toLowerCase()}';
      } else {
        return 'Solid ${userAction.toLowerCase()}';
      }
    } else {
      final evStr = evDiff < 0
          ? 'EV ${evDiff.toStringAsFixed(1)} BB'
          : 'EV +${evDiff.toStringAsFixed(1)} BB';

      if (userAction.toLowerCase() == 'fold' &&
          gtoRecommendation.action.toLowerCase() == 'raise') {
        return 'Raise missed value ($evStr)';
      } else if (userAction.toLowerCase() == 'call' &&
          gtoRecommendation.action.toLowerCase() == 'fold') {
        return 'Loose call ($evStr)';
      } else if (userAction.toLowerCase() == 'raise' &&
          gtoRecommendation.action.toLowerCase() == 'fold') {
        return 'Overaggressive ($evStr)';
      } else {
        return 'Consider ${gtoRecommendation.action} ($evStr)';
      }
    }
  }

  /// Generate detailed rationale for coaching feedback.
  String _generateRationale({
    required String userAction,
    required _GtoRecommendation gtoRecommendation,
    required String street,
    required int pot,
    required int currentBet,
    required double potOdds,
    required int numActivePlayers,
  }) {
    final potOddsPercent = (potOdds * 100).toStringAsFixed(0);
    final playerDesc = numActivePlayers > 2
        ? 'multiway ($numActivePlayers players)'
        : 'heads-up';

    if (userAction.toLowerCase() == gtoRecommendation.action.toLowerCase()) {
      return '${gtoRecommendation.reason}. Your ${userAction.toLowerCase()} '
          'aligns with GTO strategy on the $street ($playerDesc, pot $pot BB).';
    } else {
      return '${gtoRecommendation.reason}. On the $street with $potOddsPercent% '
          'pot odds ($playerDesc), ${gtoRecommendation.action} is preferred. '
          'Your ${userAction.toLowerCase()} deviates from optimal strategy.';
    }
  }

  void dispose() {
    _controller.close();
  }
}

/// Internal GTO recommendation structure.
class _GtoRecommendation {
  _GtoRecommendation({
    required this.action,
    required this.confidence,
    required this.reason,
  });

  final String action;
  final double confidence;
  final String reason;
}
