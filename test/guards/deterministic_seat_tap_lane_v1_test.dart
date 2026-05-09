import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_seat_tap_truth_validator_v1.dart';

void main() {
  test('deterministic seat-tap lane registry stays aligned with code', () {
    const lanePath = 'docs/plan/deterministic_seat_tap_lane_v1.md';
    final content = File(lanePath).readAsStringSync();

    expect(File(lanePath).existsSync(), isTrue);
    expect(content, contains('`seat_tap`'));
    expect(content, contains('`expected.role`'));
    expect(content, contains('`expected.seatId`'));
    expect(content, contains('`btn`'));
    expect(content, contains('`sb`'));
    expect(content, contains('`bb`'));
    expect(content, contains('`S*`'));
    expect(
      content,
      contains('`lib/services/world2_seat_tap_truth_validator_v1.dart`'),
    );
    expect(
      content,
      contains('`test/tools/world2_seat_tap_truth_validator_v1_test.dart`'),
    );
    expect(
      content,
      contains('`docs/plan/world2_runtime_anchor_source_contract_v1.md`'),
    );
  });

  test('representative seat-tap content satisfies the lane contract', () {
    final spec = DrillSpecV1.fromJsonString(
      File(
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_sb.json',
      ).readAsStringSync(),
    );

    expect(spec.kind, DrillKindV1.seatTap);
    expect(spec.expected.role, 'sb');
    expect(spec.whyV1, isNotNull);
    expect(spec.feedbackCorrectV1, isNotNull);
    expect(spec.feedbackIncorrectV1, isNotNull);
  });

  test('current seat-tap lane remains validator-clean and fully checked', () {
    final report = validateWorld2SeatTapTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(report.checkedCount, 17);
    expect(report.skippedCount, 0);
    expect(report.familySources, unorderedEquals(<String>[
      'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_bb.json',
      'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_btn.json',
      'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_sb.json',
      'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_seat_s6.json',
      'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_btn.json',
      'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s0.json',
      'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s1.json',
      'content/worlds/world2/v1/sessions/w2.s03/drills/d.find_bb.json',
      'content/worlds/world2/v1/sessions/w2.s03/drills/d.find_sb.json',
      'content/worlds/world2/v1/sessions/w2.s05/drills/d.find_btn_turn_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s06/drills/d.find_bb_river_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s07/drills/d.find_btn_pressure_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s07/drills/d.find_seat_s3_pressure_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s09/drills/d.find_bb_bridge_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s09/drills/d.find_seat_s5_bridge_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s10/drills/d.find_btn_checkpoint_anchor.json',
      'content/worlds/world2/v1/sessions/w2.s10/drills/d.find_seat_s6_checkpoint_anchor.json',
    ]));
  });
}
