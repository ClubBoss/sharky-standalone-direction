import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_board_tap_truth_validator_v1.dart';

void main() {
  test('deterministic board-tap lane registry stays aligned with code', () {
    const lanePath = 'docs/plan/deterministic_board_tap_lane_v1.md';
    final content = File(lanePath).readAsStringSync();

    expect(File(lanePath).existsSync(), isTrue);
    expect(content, contains('`board_tap`'));
    expect(content, contains('`expected.boardSlot`'));
    expect(content, contains('`flop_left`'));
    expect(content, contains('`flop_mid`'));
    expect(content, contains('`flop_right`'));
    expect(content, contains('`turn`'));
    expect(content, contains('`river`'));
    expect(
      content,
      contains('`lib/services/world2_board_tap_truth_validator_v1.dart`'),
    );
    expect(
      content,
      contains('`test/tools/world2_board_tap_truth_validator_v1_test.dart`'),
    );
    expect(
      content,
      contains('`docs/plan/world2_runtime_anchor_source_contract_v1.md`'),
    );
  });

  test('representative board-tap content satisfies the lane contract', () {
    final spec = DrillSpecV1.fromJsonString(
      File(
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_left_context.json',
      ).readAsStringSync(),
    );

    expect(spec.kind, DrillKindV1.boardTap);
    expect(spec.expected.boardSlot, 'flop_left');
    expect(spec.whyV1, isNotNull);
    expect(spec.feedbackCorrectV1, isNotNull);
    expect(spec.feedbackIncorrectV1, isNotNull);
  });

  test('current board-tap lane remains validator-clean and fully checked', () {
    final report = validateWorld2BoardTapTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(report.checkedCount, 9);
    expect(report.skippedCount, 0);
    expect(report.familySources, unorderedEquals(<String>[
      'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_left_context.json',
      'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_right_context.json',
      'content/worlds/world2/v1/sessions/w2.s05/drills/d.tap_turn_context.json',
      'content/worlds/world2/v1/sessions/w2.s06/drills/d.tap_river_context.json',
      'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_flop_sequence_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_river_sequence_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_turn_sequence_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_flop_mid_checkpoint_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_turn_checkpoint_anchor.json',
    ]));
  });
}
