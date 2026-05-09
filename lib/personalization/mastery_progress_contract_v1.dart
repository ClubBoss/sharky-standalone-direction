import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';

class MasteryProgressContractV1 {
  const MasteryProgressContractV1({
    required this.fitLine,
    required this.deltaSignal,
  });

  final String fitLine;
  final String deltaSignal;
}

class MasteryProgressContractFactoryV1 {
  MasteryProgressContractFactoryV1._();

  static MasteryProgressContractV1? derive({
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required PersonalizedRecommendationV1? recommendation,
    required WorldMasteryLevelV1? worldMasteryLevel,
    String campaignRankLabel = '',
  }) {
    final snapshot = latestSession;
    final nextStep = recommendation;
    final masteryLevel = worldMasteryLevel;
    if (snapshot == null || nextStep == null || masteryLevel == null) {
      return null;
    }
    return MasteryProgressContractV1(
      fitLine: _buildFitLine(
        action: nextStep.recommendedNextAction,
        worldMasteryLevel: masteryLevel,
        latestSession: snapshot,
      ),
      deltaSignal: _buildDeltaSignal(
        action: nextStep.recommendedNextAction,
        worldMasteryLevel: masteryLevel,
        latestSession: snapshot,
        campaignRankLabel: campaignRankLabel,
      ),
    );
  }

  static String _buildFitLine({
    required PersonalizedNextActionV1 action,
    required WorldMasteryLevelV1 worldMasteryLevel,
    required LatestSessionOutcomeSnapshotV1 latestSession,
  }) {
    switch (action) {
      case PersonalizedNextActionV1.reviewFocus:
        return 'Fit now: Review keeps this at your current level while ${_masteryPhrase(worldMasteryLevel)}.';
      case PersonalizedNextActionV1.repeatPack:
        return 'Fit now: One more rep at this level should settle the pattern before you move on.';
      case PersonalizedNextActionV1.continueCampaign:
      case PersonalizedNextActionV1.nextModule:
        if (!latestSession.hadMistake && latestSession.accuracy >= 0.8) {
          return 'Fit now: This next step adds pressure without jumping past your current level.';
        }
        return 'Fit now: This next step stays close to your current level while you stabilize the pattern.';
    }
  }

  static String _buildDeltaSignal({
    required PersonalizedNextActionV1 action,
    required WorldMasteryLevelV1 worldMasteryLevel,
    required LatestSessionOutcomeSnapshotV1 latestSession,
    required String campaignRankLabel,
  }) {
    final masteryLabel = _masteryLabel(worldMasteryLevel);
    final progressionVerb = switch (action) {
      PersonalizedNextActionV1.reviewFocus => 'Rebuild',
      PersonalizedNextActionV1.repeatPack => 'Reinforce',
      PersonalizedNextActionV1.continueCampaign ||
      PersonalizedNextActionV1.nextModule =>
        !latestSession.hadMistake && latestSession.accuracy >= 0.85
            ? 'Step up'
            : 'Hold',
    };
    final tierLabel = campaignRankLabel.trim();
    final base = 'Progress delta: $progressionVerb $masteryLabel mastery';
    if (tierLabel.isEmpty) {
      return base;
    }
    return '$base · $tierLabel tier';
  }

  static String _masteryPhrase(WorldMasteryLevelV1 level) {
    switch (level) {
      case WorldMasteryLevelV1.bronze:
        return 'the core pattern is still forming';
      case WorldMasteryLevelV1.silver:
        return 'you are holding the core pattern';
      case WorldMasteryLevelV1.gold:
        return 'you are controlling the current pattern';
    }
  }

  static String _masteryLabel(WorldMasteryLevelV1 level) {
    final raw = level.name;
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }
}
