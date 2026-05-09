import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  test(
    'early-world review, checkpoint, and continuation rhythm stay aligned across the shared seam',
    () {
      final world2Continue = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world2_spine_campaign_v1',
        reviewRequired: false,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: '',
      );
      final world2QuickReview = mapReviewQueueStripLabelsV1(
        reviewRequired: false,
        normalizedNextPackId: 'world2_spine_campaign_v1',
      );
      final world2Checkpoint = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world2_spine_campaign_v1',
        reviewRequired: true,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: 'Review required',
      );

      expect(
        world2Continue.reasonLine,
        'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now asks you to read visible table truth before you choose.',
      );
      expect(
        world2QuickReview.value,
        'Quick review: refresh the World 1 foundations before the next World 2 session.',
      );
      expect(
        progressionRouteReasonValueTextV1(world2Checkpoint.reasonLine),
        'Checkpoint review: lock the World 1 foundations before the next World 2 session.',
      );

      final world3Continue = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world3_spine_campaign_v1',
        reviewRequired: false,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: '',
      );
      final world3QuickReview = mapReviewQueueStripLabelsV1(
        reviewRequired: false,
        normalizedNextPackId: 'world3_spine_campaign_v1',
      );
      final world3Checkpoint = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world3_spine_campaign_v1',
        reviewRequired: true,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: 'Review required',
      );

      expect(
        world3Continue.reasonLine,
        'Why: World 2 grounded visible table truth and pressure reads. World 3 now turns that clarity into the first simple open / call / fold framework.',
      );
      expect(
        world3QuickReview.value,
        'Quick review: refresh the World 2 table-reading bridge before the next World 3 session.',
      );
      expect(
        progressionRouteReasonValueTextV1(world3Checkpoint.reasonLine),
        'Checkpoint review: lock the World 2 table-reading bridge before the next World 3 session.',
      );
    },
  );
}
