import 'dart:math';

class AdaptiveXpRewardEngine {
  AdaptiveXpRewardEngine({required this.baseMultiplier});

  final double baseMultiplier;

  double computeMultiplier({
    required double retentionScore,
    required double reactionScore,
    required double economyScore,
  }) {
    final retentionComponent = 0.5 * retentionScore;
    final reactionComponent = 0.3 * reactionScore;
    final economyComponent = 0.2 * economyScore;
    final totalFactor =
        retentionComponent + reactionComponent + economyComponent;
    return max(1.0, baseMultiplier * totalFactor);
  }
}
