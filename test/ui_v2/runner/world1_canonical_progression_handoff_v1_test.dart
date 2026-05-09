import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_route_completion_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_progression_handoff_v1.dart';

void main() {
  test(
    'world1 canonical progression target resolves review and result lanes',
    () {
      expect(
        resolveWorld1CanonicalProgressionTargetV1(
          continueAdvancesFlow: true,
          isInReviewPass: true,
          hasReviewQueue: true,
          isAtLastStep: false,
          isCheckpointSession: false,
          isCampaignSpineSession: true,
          isTablePracticeSession: false,
          isDailyRunSession: false,
        ),
        World1CanonicalProgressionTargetV1.advanceReviewPass,
      );

      expect(
        resolveWorld1CanonicalProgressionTargetV1(
          continueAdvancesFlow: true,
          isInReviewPass: false,
          hasReviewQueue: false,
          isAtLastStep: true,
          isCheckpointSession: false,
          isCampaignSpineSession: true,
          isTablePracticeSession: false,
          isDailyRunSession: false,
        ),
        World1CanonicalProgressionTargetV1.openCampaignSpineResult,
      );
    },
  );

  test('world1 canonical policy boundary maps result and retry states', () {
    final resultBoundary = buildWorld1CanonicalLocalPolicyBoundaryV1(
      outcomeVisible: true,
      continueAdvancesFlow: true,
      progressionTarget:
          World1CanonicalProgressionTargetV1.openCampaignSpineResult,
      primaryLabel: 'RESULT',
      secondaryLabel: 'RETRY',
      isPrimaryBusy: false,
      onPrimaryPressed: () {},
      onSecondaryPressed: () {},
    );
    expect(
      resultBoundary.continuationState.visualState,
      SharedLearnerContinuationVisualStateV1.completionLike,
    );
    expect(
      resultBoundary.routeCompletionBoundary.primaryAction.category,
      SharedLearnerTerminalControlCategoryV1.resultLike,
    );

    final retryBoundary = buildWorld1CanonicalLocalPolicyBoundaryV1(
      outcomeVisible: true,
      continueAdvancesFlow: false,
      progressionTarget: World1CanonicalProgressionTargetV1.retryCurrentStep,
      primaryLabel: 'RETRY',
      secondaryLabel: null,
      isPrimaryBusy: false,
      onPrimaryPressed: () {},
      onSecondaryPressed: null,
    );
    expect(
      retryBoundary.continuationState.visualState,
      SharedLearnerContinuationVisualStateV1.retryLike,
    );
    expect(
      retryBoundary.routeCompletionBoundary.primaryAction.category,
      SharedLearnerTerminalControlCategoryV1.retryLike,
    );
  });
}
