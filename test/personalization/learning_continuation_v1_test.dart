import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/learning_continuation_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/weak_pattern_review_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

void main() {
  test('shared learning continuation builds one reusable handoff context', () {
    const recommendation = PersonalizedRecommendationV1(
      recommendedFocusId: 'board_texture',
      reasonCode: 'paired_board_misses',
      shortHintText:
          'You missed this texture twice. Re-anchor on the paired board cue before you choose.',
      recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
      recommendedNextSessionTarget: 'w2.s01',
    );

    final continuation =
        LearningContinuationFactoryV1.fromPersonalizedRecommendation(
          recommendation: recommendation,
          resolveModuleTitle: recommendedModuleTitleForId,
        );

    expect(continuation, isNotNull);
    final handoffContext = LearningContinuationFactoryV1.buildHandoffContext(
      entryId: recommendation.recommendedNextSessionTarget,
      continuation: continuation!,
    );

    expect(handoffContext.statusLine, continuation.headline);
    expect(handoffContext.continuationHeadline, continuation.headline);
    expect(handoffContext.continuationReasonLine, continuation.reasonLine);
    expect(
      handoffContext.continuationTargetEntryId,
      continuation.targetEntryId,
    );
    expect(handoffContext.continuationFocusId, continuation.focusId);
    expect(handoffContext.continuationReasonCode, continuation.reasonCode);
  });

  test('early-arc session continuation uses route headline instead of local focus', () {
    const recommendation = PersonalizedRecommendationV1(
      recommendedFocusId: 'showdown_truth',
      reasonCode: 'showdown_truth_bridge',
      shortHintText:
          'You are ready to carry the same simple table anchors into the first World 2 session route.',
      recommendedNextAction: PersonalizedNextActionV1.nextModule,
      recommendedNextSessionTarget: 'w2.s01',
    );

    final continuation =
        LearningContinuationFactoryV1.fromPersonalizedRecommendation(
          recommendation: recommendation,
          resolveModuleTitle: recommendedModuleTitleForId,
        );

    expect(continuation, isNotNull);
    expect(
      continuation!.headline,
      'What changes now: Read visible table truth',
    );
  });

  test('shared learning continuation preserves weak-pattern review context', () {
    const reviewContract = WeakPatternReviewContractV1(
      weaknessLabel: 'Board Texture',
      reviewGoal: 'Name the board texture first, then choose the line.',
      targetEntryId: 'w2.s01',
      focusId: 'board_texture',
    );
    const continuation = LearningContinuationV1(
      targetEntryId: 'w2.s01',
      targetLabel: 'Board Texture',
      headline: 'Review: Board Texture',
      reasonLine:
          'Review target: Board Texture. Goal: Name the board texture first, then choose the line.',
      ctaLabel: 'REVIEW',
      focusId: 'board_texture',
      reasonCode: 'progression_review_fit',
      weakPatternReview: reviewContract,
    );

    final handoffContext = LearningContinuationFactoryV1.buildHandoffContext(
      entryId: continuation.targetEntryId,
      continuation: continuation,
    );

    expect(
      handoffContext.continuationWeaknessLabel,
      reviewContract.weaknessLabel,
    );
    expect(handoffContext.continuationReviewGoal, reviewContract.reviewGoal);
    expect(handoffContext.continuationHeadline, continuation.headline);
    expect(handoffContext.continuationReasonLine, continuation.reasonLine);
  });
}
