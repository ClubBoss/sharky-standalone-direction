import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/personalization/weak_pattern_review_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  test('canonical learner journey review surfaces share one finish framing', () {
    const reviewContract = WeakPatternReviewContractV1(
      weaknessLabel: 'Board Texture',
      reviewGoal: 'Name the board texture first, then choose the line.',
      targetEntryId: 'w2.s04',
      focusId: 'board_texture',
    );

    expect(learnerJourneyReviewSurfaceTitleV1(), 'Review target');
    expect(
      reviewContract.reasonLine,
      'Review target: Board Texture. Goal: Name the board texture first, then choose the line.',
    );

    final quickReview = mapReviewQueueStripLabelsV1(reviewRequired: false);
    expect(
      quickReview.value,
      'Quick review: refresh missed spots before the next lesson.',
    );

    final requiredReview = mapReviewQueueStripLabelsV1(reviewRequired: true);
    expect(
      requiredReview.value,
      'Review missed spots before the next lesson.',
    );
    expect(
      learnerJourneyReviewQueueHeadlineTextV1(reviewRequired: true),
      'Up next: Review missed spots',
    );
    expect(
      learnerJourneyReviewQueueSummaryTextV1(reviewRequired: true),
      'Review before the next lesson',
    );
  });
}
