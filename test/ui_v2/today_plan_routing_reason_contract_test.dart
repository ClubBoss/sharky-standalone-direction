import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  test('review-gated routing reason uses existing rhythm reason text', () {
    final line = todayPlanRoutingReasonLineV1(
      normalizedNextPackId: 'world1_spine_campaign_v1',
      reviewDueForNextPack: true,
      mapRhythmReason: 'Review required',
    );
    expect(line, 'Why: Review required.');
  });

  test('followup b0 and b2 map to deterministic adaptive focus reasons', () {
    expect(
      todayPlanRoutingReasonLineV1(
        normalizedNextPackId: 'world5_spine_followup_v1_b0',
        reviewDueForNextPack: false,
        mapRhythmReason: 'Continue',
      ),
      'Why: To-call accuracy needs reinforcement.',
    );
    expect(
      todayPlanRoutingReasonLineV1(
        normalizedNextPackId: 'world5_spine_followup_v1_b2',
        reviewDueForNextPack: false,
        mapRhythmReason: 'Continue',
      ),
      'Why: Expected-action accuracy needs reinforcement.',
    );
  });

  test('absent routing target falls back safely and deterministically', () {
    final first = todayPlanRoutingReasonLineV1(
      normalizedNextPackId: '',
      reviewDueForNextPack: false,
      mapRhythmReason: 'Continue',
    );
    final second = todayPlanRoutingReasonLineV1(
      normalizedNextPackId: '',
      reviewDueForNextPack: false,
      mapRhythmReason: 'Continue',
    );
    expect(first, 'Why: No next campaign pack is available yet.');
    expect(second, first);
  });
}
