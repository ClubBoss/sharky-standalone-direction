import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_advancement_dispatch_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_progression_handoff_v1.dart';

void main() {
  test(
    'world1 canonical mode completion resolves result and close actions',
    () {
      expect(
        resolveWorld1CanonicalModeCompletionActionV1(
          isReviewQueueSession: false,
          isCheckpointSession: false,
          isCampaignSpineSession: true,
          isTablePracticeSession: false,
          isDailyRunSession: false,
          isAtLastStep: false,
        ),
        World1CanonicalModeCompletionActionV1.completeCampaignSpineResult,
      );

      expect(
        resolveWorld1CanonicalModeCompletionActionV1(
          isReviewQueueSession: false,
          isCheckpointSession: false,
          isCampaignSpineSession: false,
          isTablePracticeSession: false,
          isDailyRunSession: true,
          isAtLastStep: false,
        ),
        World1CanonicalModeCompletionActionV1.closePack,
      );
    },
  );

  test(
    'world1 canonical review advancement resolves delegate and cursor move',
    () {
      expect(
        resolveWorld1CanonicalReviewAdvanceActionV1(
          isInReviewPass: false,
          isLastReviewStep: false,
        ),
        World1CanonicalReviewAdvanceActionV1.delegateToModeCompletion,
      );
      expect(
        resolveWorld1CanonicalReviewAdvanceActionV1(
          isInReviewPass: true,
          isLastReviewStep: false,
        ),
        World1CanonicalReviewAdvanceActionV1.applyNextReviewCursor,
      );
    },
  );

  test(
    'world1 canonical progression dispatch invokes the matching callback',
    () async {
      var called = '';
      await runWorld1CanonicalProgressionDispatchV1(
        target: World1CanonicalProgressionTargetV1.openTablePracticeResult,
        callbacks: World1CanonicalAdvancementCallbacksV1(
          onAdvanceReviewQueue: () async => called = 'review',
          onStartReviewPass: () async => called = 'start',
          onOpenCheckpointResult: () async => called = 'checkpoint',
          onOpenCampaignSpineResult: () async => called = 'campaign',
          onOpenTablePracticeResult: () async => called = 'table_practice',
          onClosePack: () async => called = 'close',
          onAdvanceStep: () async => called = 'advance',
        ),
      );

      expect(called, 'table_practice');
    },
  );
}
