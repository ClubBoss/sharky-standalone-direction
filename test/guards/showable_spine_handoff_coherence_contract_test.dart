import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';

void main() {
  test(
    'showable spine handoff labels stay coherent through the canonical seam',
    () {
      final campaignStory = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world1_spine_campaign_v1',
        reviewRequired: false,
        activePackId: 'world1_spine_campaign_v1',
        nextHandIndex: 1,
        rhythmReason: '',
      );
      final reviewStory = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world1_spine_campaign_v1',
        reviewRequired: true,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: 'Missed spots ready',
      );
      final checkpointStory = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world1_spine_campaign_v1',
        reviewRequired: true,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: 'Review required',
      );

      expect(campaignStory.target.routeLabel, 'Campaign spine');
      expect(
        campaignStory.reasonLine,
        'Why: Continue your next campaign route.',
      );
      expect(
        progressionRouteReasonValueTextV1(reviewStory.reasonLine),
        'Missed spots ready.',
      );
      expect(
        progressionRouteReasonValueTextV1(checkpointStory.reasonLine),
        'Review required.',
      );
    },
  );

  test(
    'result and map no longer pin stale local showable-spine handoff prose',
    () {
      final resultSource = File(
        'lib/ui_v2/screens/session_result_screen.dart',
      ).readAsStringSync();
      final mapSource = File(
        'lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart',
      ).readAsStringSync();

      expect(resultSource, isNot(contains('Next up: continue campaign spine')));
      expect(
        resultSource,
        isNot(contains('Checkpoint: review your top mistakes.')),
      );
      expect(
        mapSource,
        isNot(contains('Review ready: revisit your top mistakes.')),
      );
      expect(resultSource, contains('_spineHandoffRouteStoryV1?.reasonLine'));
      expect(mapSource, contains('mapCheckpointPendingReasonTextV1('));
    },
  );
}
