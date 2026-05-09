import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/skill_tags_v1.dart';

void main() {
  group('skillTagsForPackIdV1', () {
    test('world1 campaign returns stable foundational tags', () {
      expect(skillTagsForPackIdV1('world1_spine_campaign_v1'), const <String>[
        'Seat order',
        'Blinds',
        'Position labels',
      ]);
    });

    test('mid-band worlds return chapter tags', () {
      expect(
        skillTagsForPackIdV1('world5_spine_followup_v1_b1'),
        const <String>['Position labels', 'Late seats', 'Consistency'],
      );
    });

    test('late-band worlds return chapter tags', () {
      expect(skillTagsForPackIdV1('world9_spine_campaign_v1'), const <String>[
        'Consistency',
        'Position labels',
        'Seat recall',
      ]);
    });

    test('chapter checkpoints return explicit checkpoint tags', () {
      expect(skillTagsForPackIdV1('season1_checkpoint_w4_6_v1'), const <String>[
        'Late seats',
        'Blind order',
        'Seat reset',
      ]);
    });

    test('unknown pack returns empty and summary is empty', () {
      expect(skillTagsForPackIdV1('unknown_pack'), isEmpty);
      expect(skillTagsSummaryForPackIdV1('unknown_pack'), '');
    });

    test('summary uses deterministic truncation', () {
      expect(
        skillTagsSummaryForPackIdV1('world2_spine_campaign_v1', maxTags: 2),
        'Seat order, Blinds',
      );
    });
  });
}
