import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_board_tap_truth_validator_v1.dart';

void main() {
  test('lane doc, registry, and board-tap family stay aligned', () {
    final lane = File(
      'docs/plan/world2_truth_lane_next_v1.md',
    ).readAsStringSync();
    final registry = File(
      'docs/plan/world2_truth_family_registry_v1.md',
    ).readAsStringSync();

    expect(lane, contains('deterministic runtime-anchor truth'));
    expect(lane, contains('`board_tap`'));
    expect(registry, contains('`board_tap`'));
    expect(
      registry,
      contains('`lib/services/world2_board_tap_truth_validator_v1.dart`'),
    );
    expect(
      registry,
      contains('`tools/validate_world2_board_tap_truth_v1.dart`'),
    );
    expect(
      registry,
      contains('`test/tools/world2_board_tap_truth_validator_v1_test.dart`'),
    );
  });

  test('World 2 board-tap family boundary is deterministic and fully checked', () {
    final report = validateWorld2BoardTapTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_left_context.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_right_context.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.tap_turn_context.json',
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.tap_river_context.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_flop_sequence_anchor.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_river_sequence_anchor.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_turn_sequence_anchor.json',
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_flop_mid_checkpoint_anchor.json',
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_turn_checkpoint_anchor.json',
      ]),
    );
    expect(report.checkedCount, 9);
    expect(report.skippedCount, 0);
    expect(report.checkedSources, unorderedEquals(report.familySources));
    expect(report.skippedSources, isEmpty);
    expect(report.skippedReasons, isEmpty);
  });

  test('validator catches board-slot contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_board_tap_copy",
        "kind": "board_tap",
        "prompt": "Tap the turn slot before deciding second barrel or checkback.",
        "intent_v1": "position_ip_advantage",
        "why_v1": "River anchor must be locked before continuation choice.",
        "expected": {
          "boardSlot": "river"
        },
        "error_class": "expected_action_mismatch",
        "feedback_correct_v1": "Correct. River context is identified.",
        "feedback_incorrect_v1": "Incorrect. River slot must be identified first."
      }
      ''');

    final issues = validateWorld2BoardTapTruthSpecV1(
      spec: spec,
      source: 'memory://broken_board_tap_copy',
    );

    expect(
      issues,
      contains(
        contains('expected boardSlot river contradicts board-tap truth turn'),
      ),
    );
    expect(
      issues,
      contains(contains('river copy contradicts board-tap truth')),
    );
  });

  test('authored board_tap drills expose a normalized scenario payload', () {
    final spec = DrillSpecV1.fromJsonString(
      File(
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_left_context.json',
      ).readAsStringSync(),
    );

    final scenario = spec.scenarioBoardTapContextV1;

    expect(scenario, isNotNull);
    expect(scenario!.expectedBoardSlotV1, 'flop_left');
  });
}
