import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_position_truth_validator_v1.dart';

void main() {
  test('protocol and position family stay aligned', () {
    final protocol = File(
      'docs/plan/world2_truth_family_onboarding_protocol_v1.md',
    ).readAsStringSync();
    final registry = File(
      'docs/plan/world2_truth_family_registry_v1.md',
    ).readAsStringSync();

    expect(protocol, contains('exact-answer truth'));
    expect(protocol, contains('`position_thinking_choice_v1`'));
    expect(registry, contains('`position_thinking_choice_v1`'));
    expect(
      registry,
      contains('`lib/services/world2_position_truth_validator_v1.dart`'),
    );
    expect(
      registry,
      contains('`tools/validate_world2_position_truth_v1.dart`'),
    );
    expect(
      registry,
      contains('`test/tools/world2_position_truth_validator_v1_test.dart`'),
    );
  });

  test('World 2 position family boundary is deterministic', () {
    final report = validateWorld2PositionTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_in_position_btn_vs_bb.json',
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_out_of_position_bb_vs_btn.json',
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_villain_acts_later_co_vs_btn.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_position_villain_acts_later_btn_vs_co.json',
      ]),
    );
    expect(
      report.checkedSources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_in_position_btn_vs_bb.json',
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_out_of_position_bb_vs_btn.json',
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_villain_acts_later_co_vs_btn.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_position_villain_acts_later_btn_vs_co.json',
      ]),
    );
    expect(report.skippedSources, isEmpty);
    expect(report.checkedCount, 4);
    expect(report.skippedCount, 0);
  });

  test('validator catches position-copy contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_position_copy",
        "kind": "position_thinking_choice_v1",
        "prompt": "Hero is on the button and villain is in the big blind. Who is in position after the flop?",
        "player_count_v1": 2,
        "hero_seat_v1": "btn",
        "villain_seat_v1": "bb",
        "active_seats_v1": ["btn", "bb"],
        "street_v1": "flop",
        "available_actions_v1": ["hero", "villain"],
        "expected": {"actionId": "hero"},
        "error_class": "position_thinking_choice_mismatch",
        "why_v1": "Villain is in position here.",
        "feedback_correct_v1": "Correct. Villain acts later after the flop.",
        "feedback_incorrect_v1": "Incorrect. Villain is in position here."
      }
      ''');

    final issues = validateWorld2PositionTruthSpecV1(
      spec: spec,
      source: 'memory://broken_position_copy',
    );

    expect(
      issues,
      contains(contains('villain in-position copy contradicts position truth')),
    );
    expect(
      issues,
      contains(contains('villain acts-later copy contradicts position truth')),
    );
  });

  test('validator supports preflop in-position seat questions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "preflop_position_chain_shape",
        "kind": "position_thinking_choice_v1",
        "question_shape_v1": "in_position",
        "prompt": "Hero is on the button and villain is in the big blind. Who is in position?",
        "player_count_v1": 4,
        "hero_seat_v1": "btn",
        "villain_seat_v1": "bb",
        "active_seats_v1": ["btn", "bb"],
        "folded_seats_v1": ["co"],
        "empty_seats_v1": ["sb"],
        "street_v1": "preflop",
        "available_actions_v1": ["hero", "villain"],
        "expected": {"actionId": "hero"},
        "error_class": "position_thinking_choice_mismatch",
        "why_v1": "The button keeps position over the big blind.",
        "feedback_correct_v1": "Correct. Hero is in position here.",
        "feedback_incorrect_v1": "Incorrect. Hero is in position here."
      }
      ''');

    expect(
      validateWorld2PositionTruthSpecV1(
        spec: spec,
        source: 'memory://preflop_position_chain_shape',
      ),
      isEmpty,
    );
  });

  test('validator prefers question_shape_v1 over prompt parsing', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "position_shape_metadata_preferred",
        "kind": "position_thinking_choice_v1",
        "question_shape_v1": "out_of_position",
        "prompt": "Hero is on the button and villain is in the big blind. Who acts later after the flop?",
        "player_count_v1": 4,
        "hero_seat_v1": "bb",
        "villain_seat_v1": "btn",
        "active_seats_v1": ["btn", "bb"],
        "street_v1": "flop",
        "available_actions_v1": ["hero", "villain"],
        "expected": {"actionId": "hero"},
        "error_class": "position_thinking_choice_mismatch",
        "why_v1": "Hero is out of position here.",
        "feedback_correct_v1": "Correct. Hero is out of position here.",
        "feedback_incorrect_v1": "Incorrect. Hero is out of position here."
      }
      ''');

    expect(
      validateWorld2PositionTruthSpecV1(
        spec: spec,
        source: 'memory://position_shape_metadata_preferred',
      ),
      isEmpty,
    );
    expect(
      deriveWorld2PositionTruthV1(spec).question,
      World2PositionTruthQuestionV1.outOfPosition,
    );
  });

  test('validator still excludes preflop acts-later question shapes', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "preflop_acts_later_not_supported",
        "kind": "position_thinking_choice_v1",
        "prompt": "Hero is on the button and villain is in the big blind. Who acts later?",
        "player_count_v1": 4,
        "hero_seat_v1": "btn",
        "villain_seat_v1": "bb",
        "active_seats_v1": ["btn", "bb"],
        "street_v1": "preflop",
        "available_actions_v1": ["hero", "villain"],
        "expected": {"actionId": "hero"},
        "error_class": "position_thinking_choice_mismatch"
      }
      ''');

    expect(
      validateWorld2PositionTruthSpecV1(
        spec: spec,
        source: 'memory://preflop_acts_later_not_supported',
      ),
      isEmpty,
    );
    expect(() => deriveWorld2PositionTruthV1(spec), throwsStateError);
  });

  test('exact position drills expose normalized scenario position context', () {
    final spec = DrillSpecV1.fromJsonString(
      File(
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_in_position_btn_vs_bb.json',
      ).readAsStringSync(),
    );

    final context = spec.scenarioPositionContextV1;
    expect(context, isNotNull);
    expect(context!.streetV1, 'flop');
    expect(context.playerCountV1, 4);
    expect(context.heroSeatV1, 'btn');
    expect(context.villainSeatV1, 'bb');
    expect(context.activeSeatsV1, const <String>['btn', 'bb']);
    expect(context.foldedSeatsV1, const <String>['co']);
    expect(context.emptySeatsV1, const <String>['sb']);
    expect(context.availableActionsV1, const <String>['hero', 'villain']);
    expect(context.expectedActionIdV1, 'hero');
  });
}
