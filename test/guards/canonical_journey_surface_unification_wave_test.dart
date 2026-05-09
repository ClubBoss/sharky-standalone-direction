import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/learner_journey_cta_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/weak_pattern_review_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_completion_surface_contract_v1.dart';

void main() {
  test('canonical learner journey surfaces reuse one CTA rhythm', () {
    expect(
      learnerJourneyPersonalizedActionCtaLabelV1(
        PersonalizedNextActionV1.reviewFocus,
      ),
      'REVIEW',
    );
    expect(
      learnerJourneyPersonalizedActionCtaLabelV1(
        PersonalizedNextActionV1.nextModule,
      ),
      'NEXT LESSON',
    );
    expect(
      learnerJourneyPersonalizedActionCtaLabelV1(
        PersonalizedNextActionV1.continueCampaign,
      ),
      'NEXT LESSON',
    );

    const reviewContract = WeakPatternReviewContractV1(
      weaknessLabel: 'Board Texture',
      reviewGoal: 'Name the board texture first, then choose the line.',
      targetEntryId: 'w2.s01',
      focusId: 'board_texture',
    );
    expect(reviewContract.ctaLabel, 'REVIEW');

    final runnerContract = buildRunnerCompletionSurfaceContractV1(
      statusHeader: 'Session complete',
      bodyText: 'Next lesson ready: World 2 · Session 2 of 10.',
      hasPrimaryNext: true,
      primaryNextLabel: learnerJourneyPrimaryNextLessonCtaLabelV1(),
    );
    expect(runnerContract.primaryCtaLabel, 'NEXT LESSON');
    expect(runnerContract.secondaryCtaLabel, 'BACK TO MAP');
  });
}
