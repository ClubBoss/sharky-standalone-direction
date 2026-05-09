import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/map/season1_checkpoint_selector_v1.dart';

void main() {
  group('selectSeason1CheckpointPackIdV1', () {
    test('completed=0,2 -> w1_3', () {
      expect(selectSeason1CheckpointPackIdV1(0), 'season1_checkpoint_w1_3_v1');
      expect(selectSeason1CheckpointPackIdV1(2), 'season1_checkpoint_w1_3_v1');
    });

    test('completed=3,5 -> w4_6', () {
      expect(selectSeason1CheckpointPackIdV1(3), 'season1_checkpoint_w4_6_v1');
      expect(selectSeason1CheckpointPackIdV1(5), 'season1_checkpoint_w4_6_v1');
    });

    test('completed=6,9 -> w7_10', () {
      expect(selectSeason1CheckpointPackIdV1(6), 'season1_checkpoint_w7_10_v1');
      expect(selectSeason1CheckpointPackIdV1(9), 'season1_checkpoint_w7_10_v1');
    });

    test('negative counts clamp to first chapter checkpoint', () {
      expect(selectSeason1CheckpointPackIdV1(-1), 'season1_checkpoint_w1_3_v1');
    });
  });
}
