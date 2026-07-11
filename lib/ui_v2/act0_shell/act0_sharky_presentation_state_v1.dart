import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_session_payoff_v1.dart';

/// Asset-independent state contract. It owns no learner state and does not
/// select an image; asset admission remains a separate production decision.
enum Act0SharkyPresentationStateV1 {
  neutralGuidance,
  teachingAttention,
  supportiveRepair,
  recoveredAcknowledgement,
  earnedCompletion,
}

class Act0SharkyPresentationInputV1 {
  const Act0SharkyPresentationInputV1({
    required this.isWelcome,
    required this.isTeaching,
    required this.isSequenceCompletion,
    this.payoff,
    this.recommendation,
  });

  final bool isWelcome;
  final bool isTeaching;
  final bool isSequenceCompletion;
  final Act0ActionSessionPayoffV1? payoff;
  final Act0ActionRecommendationV1? recommendation;
}

Act0SharkyPresentationStateV1 deriveAct0SharkyPresentationStateV1(
  Act0SharkyPresentationInputV1 input,
) {
  final payoff = input.payoff;
  if (payoff?.type == Act0ActionPayoffTypeV1.unresolvedSkill ||
      input.recommendation?.blocksNormalProgression == true) {
    return Act0SharkyPresentationStateV1.supportiveRepair;
  }
  if (payoff?.type == Act0ActionPayoffTypeV1.recoveredSuccess) {
    return Act0SharkyPresentationStateV1.recoveredAcknowledgement;
  }
  if (input.isSequenceCompletion &&
      payoff?.type == Act0ActionPayoffTypeV1.cleanSuccess) {
    return Act0SharkyPresentationStateV1.earnedCompletion;
  }
  if (input.isTeaching) {
    return Act0SharkyPresentationStateV1.teachingAttention;
  }
  return Act0SharkyPresentationStateV1.neutralGuidance;
}
