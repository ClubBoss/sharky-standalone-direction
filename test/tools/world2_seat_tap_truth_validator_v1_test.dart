import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_seat_tap_truth_validator_v1.dart';

void main() {
  test('lane doc, registry, and seat-tap family stay aligned', () {
    final lane = File(
      'docs/plan/world2_truth_lane_next_v1.md',
    ).readAsStringSync();
    final registry = File(
      'docs/plan/world2_truth_family_registry_v1.md',
    ).readAsStringSync();

    expect(
      lane,
      contains('`seat_tap` uses `expected.role` or `expected.seatId`'),
    );
    expect(lane, contains('`seat_tap`'));
    expect(registry, contains('`seat_tap`'));
    expect(
      registry,
      contains('`lib/services/world2_seat_tap_truth_validator_v1.dart`'),
    );
    expect(
      registry,
      contains('`tools/validate_world2_seat_tap_truth_v1.dart`'),
    );
    expect(
      registry,
      contains('`test/tools/world2_seat_tap_truth_validator_v1_test.dart`'),
    );
  });

  test('World 2 seat-tap family boundary is deterministic and fully checked', () {
    final report = validateWorld2SeatTapTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
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
      ]),
    );
    expect(report.checkedCount, 17);
    expect(report.skippedCount, 0);
    expect(report.checkedSources, unorderedEquals(report.familySources));
    expect(report.skippedSources, isEmpty);
    expect(report.skippedReasons, isEmpty);
  });

  test('validator catches seat-target contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_seat_tap_copy",
        "kind": "seat_tap",
        "prompt": "Tap the button seat before choosing your preflop action.",
        "intent_v1": "position_btn_vs_early",
        "why_v1": "Big blind context changes call and fold thresholds.",
        "expected": {
          "role": "bb"
        },
        "error_class": "action_order_mismatch",
        "feedback_correct_v1": "Correct. Big blind context is locked.",
        "feedback_incorrect_v1": "Incorrect. Big blind must be identified before action choice."
      }
      ''');

    final issues = validateWorld2SeatTapTruthSpecV1(
      spec: spec,
      source: 'memory://broken_seat_tap_copy',
    );

    expect(
      issues,
      contains(contains('expected role bb contradicts seat-tap truth btn')),
    );
    expect(
      issues,
      contains(contains('big-blind copy contradicts seat-tap truth')),
    );
  });

  test('authored seat_tap drills expose a normalized scenario payload', () {
    final spec = DrillSpecV1.fromJsonString(
      File(
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_sb.json',
      ).readAsStringSync(),
    );

    final scenario = spec.scenarioSeatTapContextV1;

    expect(scenario, isNotNull);
    expect(scenario!.expectedRoleV1, 'sb');
    expect(scenario.expectedSeatIdV1, isNull);
  });
}
