import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/personalization/learner_journey_cta_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_top_mistake_utility_v1.dart';
import 'package:poker_analyzer/personalization/weak_pattern_review_routing_v1.dart';

class WeakPatternReviewContractV1 {
  const WeakPatternReviewContractV1({
    required this.weaknessLabel,
    required this.reviewGoal,
    required this.targetEntryId,
    required this.focusId,
  });

  final String weaknessLabel;
  final String reviewGoal;
  final String targetEntryId;
  final String focusId;

  String get headline => 'Review: $weaknessLabel';
  String get reasonLine => learnerJourneyReviewTargetReasonLineV1(
    weaknessLabel: weaknessLabel,
    reviewGoal: reviewGoal,
  );
  String get ctaLabel => learnerJourneyPrimaryReviewCtaLabelV1();
}

class WeakPatternReviewContractFactoryV1 {
  WeakPatternReviewContractFactoryV1._();

  static WeakPatternReviewContractV1? derive({
    required PersonalizedRecommendationV1? recommendation,
    required Iterable<RecentTelemetrySignalV1> recentSignals,
    required String Function(String moduleId) resolveModuleTitle,
  }) {
    final resolvedRecommendation = recommendation;
    if (resolvedRecommendation == null ||
        resolvedRecommendation.recommendedNextAction !=
            PersonalizedNextActionV1.reviewFocus) {
      return null;
    }
    final targetEntryId = resolvedRecommendation.recommendedNextSessionTarget
        .trim();
    if (targetEntryId.isEmpty) return null;
    final focusId = resolvedRecommendation.recommendedFocusId.trim();
    final topMistake = RecentTopMistakeUtilityV1.deriveTopMistake(
      recentSignals,
    );
    final dominantErrorType = topMistake?.dominantErrorType;
    final resolvedTargetEntryId =
        WeakPatternReviewRoutingV1.resolveTargetEntryId(
          baseTargetEntryId: targetEntryId,
          focusId: focusId,
          dominantErrorType: dominantErrorType,
        );
    final weaknessLabel = _resolveWeaknessLabel(
      focusId: focusId,
      targetEntryId: resolvedTargetEntryId,
      topMistake: topMistake,
      resolveModuleTitle: resolveModuleTitle,
    );
    return WeakPatternReviewContractV1(
      weaknessLabel: weaknessLabel,
      reviewGoal: _reviewGoalFor(
        focusId: focusId,
        reasonCode: resolvedRecommendation.reasonCode,
        dominantErrorType: dominantErrorType,
      ),
      targetEntryId: resolvedTargetEntryId,
      focusId: focusId,
    );
  }

  static String _resolveWeaknessLabel({
    required String focusId,
    required String targetEntryId,
    required RecentTopMistakeSummaryV1? topMistake,
    required String Function(String moduleId) resolveModuleTitle,
  }) {
    final topBucket = topMistake?.bucketLabel.trim() ?? '';
    if (topBucket.isNotEmpty) {
      return topBucket;
    }
    final resolvedTitle = resolveModuleTitle(targetEntryId).trim();
    if (resolvedTitle.isNotEmpty) {
      return resolvedTitle;
    }
    final normalizedFocus = focusId.trim();
    if (normalizedFocus.isEmpty) {
      return 'Recent weakness';
    }
    return normalizedFocus
        .split('_')
        .where((token) => token.trim().isNotEmpty)
        .map(
          (token) =>
              '${token[0].toUpperCase()}${token.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static String _reviewGoalFor({
    required String focusId,
    required String reasonCode,
    required String? dominantErrorType,
  }) {
    final normalizedError = (dominantErrorType ?? '').trim().toLowerCase();
    if (normalizedError == 'incorrect_seat' ||
        normalizedError == 'seat_role_confusion') {
      return 'Rebuild blind order and who acts first before you answer.';
    }
    if (normalizedError == 'action_selection') {
      return 'Re-anchor on who owns the betting lead before you act.';
    }
    if (normalizedError == 'board_slot_confusion') {
      return 'Name the board texture first, then choose the line.';
    }
    final normalizedFocus = focusId.trim().toLowerCase();
    switch (normalizedFocus) {
      case 'action_order':
        return 'Rebuild who acts first before you lock in the seat.';
      case 'initiative':
        return 'Re-anchor on who owns the action before you choose.';
      case 'starting_hands':
      case 'range':
        return 'Re-check which hands can continue from this spot.';
      case 'pot_odds':
        return 'Price the call before you continue.';
      case 'board_texture':
        return 'Read the board texture before you lock in the action.';
      case 'equity_realization':
        return 'Ask how well this hand can realize equity if called.';
      case 'flop':
        return 'Name the flop story before you choose your line.';
      case 'turn':
        return 'Re-check how the turn changed the hand story.';
      case 'river':
        return 'Re-check which hands still want value or bluff on the river.';
      case 'bankroll':
        return 'Protect the roll by matching the stake to the plan.';
      default:
        if (reasonCode.trim().toLowerCase().contains('review')) {
          return 'Review the weak pattern once before adding a harder step.';
        }
        return 'Rebuild this weak pattern before you continue.';
    }
  }
}
