import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';
import 'package:poker_analyzer/personalization/learner_journey_cta_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/weak_pattern_review_contract_v1.dart';

class LearningContinuationV1 {
  const LearningContinuationV1({
    required this.targetEntryId,
    required this.targetLabel,
    required this.headline,
    required this.reasonLine,
    required this.ctaLabel,
    required this.focusId,
    required this.reasonCode,
    this.weakPatternReview,
  });

  final String targetEntryId;
  final String targetLabel;
  final String headline;
  final String reasonLine;
  final String ctaLabel;
  final String focusId;
  final String reasonCode;
  final WeakPatternReviewContractV1? weakPatternReview;
}

class LearningContinuationFactoryV1 {
  LearningContinuationFactoryV1._();

  static LearningContinuationV1? fromPersonalizedRecommendation({
    required PersonalizedRecommendationV1? recommendation,
    required String Function(String moduleId) resolveModuleTitle,
    Iterable<RecentTelemetrySignalV1> recentSignals =
        const <RecentTelemetrySignalV1>[],
  }) {
    final resolvedRecommendation = recommendation;
    if (resolvedRecommendation == null) return null;
    final targetEntryId = resolvedRecommendation.recommendedNextSessionTarget
        .trim();
    if (targetEntryId.isEmpty) return null;
    final focusId = resolvedRecommendation.recommendedFocusId.trim();
    final reasonCode = resolvedRecommendation.reasonCode.trim();
    final reasonLine = resolvedRecommendation.shortHintText.trim();
    if (reasonLine.isEmpty) return null;
    final moduleTitle = resolveModuleTitle(targetEntryId).trim();
    final targetLabel = moduleTitle.isNotEmpty ? moduleTitle : focusId;
    final weakPatternReview = WeakPatternReviewContractFactoryV1.derive(
      recommendation: resolvedRecommendation,
      recentSignals: recentSignals,
      resolveModuleTitle: resolveModuleTitle,
    );
    if (weakPatternReview != null) {
      return LearningContinuationV1(
        targetEntryId: weakPatternReview.targetEntryId,
        targetLabel: weakPatternReview.weaknessLabel,
        headline: weakPatternReview.headline,
        reasonLine: weakPatternReview.reasonLine,
        ctaLabel: weakPatternReview.ctaLabel,
        focusId: weakPatternReview.focusId,
        reasonCode: resolvedRecommendation.reasonCode.trim(),
        weakPatternReview: weakPatternReview,
      );
    }
    final targetWorld = resolveSessionWorldForSessionIdV1(targetEntryId);
    final headline = isEarlyArcSessionWorldV1(targetWorld)
        ? progressionRouteStageShiftHeadlineForTargetV1(
                ProgressionRouteTargetV1(
                  family: ProgressionRouteFamilyV1.sessionWorld,
                  world: targetWorld,
                ),
              ) ??
              'Next up: World $targetWorld sessions'
        : 'Recent focus: $targetLabel';
    return LearningContinuationV1(
      targetEntryId: targetEntryId,
      targetLabel: targetLabel,
      headline: headline,
      reasonLine: reasonLine,
      ctaLabel: learnerJourneyPersonalizedActionCtaLabelV1(
        resolvedRecommendation.recommendedNextAction,
      ),
      focusId: focusId,
      reasonCode: reasonCode,
      weakPatternReview: weakPatternReview,
    );
  }

  static ProgressionHandoffContextV1 buildHandoffContext({
    required String entryId,
    required LearningContinuationV1 continuation,
  }) {
    final baseContext = buildProgressionHandoffContextForPackV1(entryId);
    return ProgressionHandoffContextV1(
      statusLine: baseContext?.statusLine ?? continuation.headline,
      continuationHeadline: continuation.headline,
      continuationReasonLine: continuation.reasonLine,
      continuationTargetEntryId: continuation.targetEntryId,
      continuationFocusId: continuation.focusId,
      continuationReasonCode: continuation.reasonCode,
      continuationWeaknessLabel: continuation.weakPatternReview?.weaknessLabel,
      continuationReviewGoal: continuation.weakPatternReview?.reviewGoal,
    );
  }
}
