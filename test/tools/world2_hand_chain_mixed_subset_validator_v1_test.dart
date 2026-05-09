import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_hand_chain_mixed_subset_validator_v1.dart';

void main() {
  test('queue, registry, and mixed hand_chain pilot stay aligned', () {
    final queue = File(
      'docs/plan/world2_truth_family_queue_v1.md',
    ).readAsStringSync();
    final registry = File(
      'docs/plan/world2_truth_family_registry_v1.md',
    ).readAsStringSync();

    expect(queue, contains('`hand_chain_v1`'));
    expect(
      queue,
      contains('R272 closes the final current capstone chain shape'),
    );
    expect(registry, contains('`hand_chain_v1`'));
    expect(
      registry,
      contains(
        '`lib/services/world2_hand_chain_mixed_subset_validator_v1.dart`',
      ),
    );
    expect(
      registry,
      contains('`tools/validate_world2_hand_chain_mixed_subset_v1.dart`'),
    );
    expect(
      registry,
      contains(
        '`test/tools/world2_hand_chain_mixed_subset_validator_v1_test.dart`',
      ),
    );
  });

  test('World 2 mixed hand_chain pilot boundary is deterministic', () {
    final report = validateWorld2HandChainMixedSubsetDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json',
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.chain_texture_outs_action_v1.json',
        'content/worlds/world2/v1/sessions/w2.s11/drills/d.chain_position_initiative_action_v1.json',
        'content/worlds/world2/v1/sessions/w2.s12/drills/d.chain_world2_capstone_v1.json',
        'content/worlds/world2/v1/sessions/w2.s13/drills/d.chain_texture_outs_continue_v1.json',
        'content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json',
      ]),
    );
    expect(
      report.checkedSources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json',
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.chain_texture_outs_action_v1.json',
        'content/worlds/world2/v1/sessions/w2.s11/drills/d.chain_position_initiative_action_v1.json',
        'content/worlds/world2/v1/sessions/w2.s12/drills/d.chain_world2_capstone_v1.json',
        'content/worlds/world2/v1/sessions/w2.s13/drills/d.chain_texture_outs_continue_v1.json',
        'content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json',
      ]),
    );
    expect(report.checkedCount, 8);
    expect(report.skippedCount, 0);
    expect(
      report.factualSubsetSources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json',
      ]),
    );
    expect(
      report.policyCoupledSources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.chain_texture_outs_action_v1.json',
        'content/worlds/world2/v1/sessions/w2.s11/drills/d.chain_position_initiative_action_v1.json',
        'content/worlds/world2/v1/sessions/w2.s13/drills/d.chain_texture_outs_continue_v1.json',
        'content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json',
      ]),
    );
    expect(
      report.capstoneSources,
      equals(<String>[
        'content/worlds/world2/v1/sessions/w2.s12/drills/d.chain_world2_capstone_v1.json',
      ]),
    );
  });

  test(
    'classifies factual mixed hand_chain subset separately from policy and capstone chains',
    () {
      final factualPilot = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_position_then_initiative_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s07_position_then_initiative_v1",
        "prompt":"Play this short two-step World 2 scenario chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {"street":"preflop","prompt":"Step 1","expected_action":"hero","available_actions_v1":["hero","villain"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},
          {"street":"flop","prompt":"Step 2","expected_action":"hero","available_actions_v1":["hero","villain"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"}
        ]
      }
      ''');
      final factualBoardContext = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_texture_then_outs_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s08_texture_then_outs_v1",
        "prompt":"Play this short two-step board-context chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {"street":"flop","prompt":"Step 1","expected_action":"raise","available_actions_v1":["call","raise"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},
          {"street":"flop","prompt":"Step 2","expected_action":"9","available_actions_v1":["4","8","9","15"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"}
        ]
      }
      ''');
      final policyCluster = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_position_initiative_texture_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s09_position_initiative_texture_v1",
        "prompt":"Play this short three-step table-state chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {"street":"preflop","prompt":"Step 1","expected_action":"hero","available_actions_v1":["hero","villain"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},
          {"street":"flop","prompt":"Step 2","expected_action":"hero","available_actions_v1":["hero","villain"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},
          {"street":"flop","prompt":"Step 3","expected_action":"raise","available_actions_v1":["call","raise"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"}
        ]
      }
      ''');
      final capstoneCluster = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_world2_capstone_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s12_world2_capstone_v1",
        "prompt":"Play this capstone four-step chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {"street":"preflop","prompt":"Step 1","expected_action":"hero","available_actions_v1":["hero","villain"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},
          {"street":"flop","prompt":"Step 2","expected_action":"hero","available_actions_v1":["hero","villain"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},
          {"street":"flop","prompt":"Step 3","expected_action":"raise","available_actions_v1":["call","raise"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},
          {"street":"flop","prompt":"Step 4","expected_action":"raise","available_actions_v1":["call","raise"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"}
        ]
      }
      ''');

      expect(
        classifyWorld2HandChainSubsetV1(factualPilot),
        World2HandChainSubsetClassV1.factualReusable,
      );
      expect(
        classifyWorld2HandChainSubsetV1(factualBoardContext),
        World2HandChainSubsetClassV1.factualReusable,
      );
      expect(
        classifyWorld2HandChainSubsetV1(policyCluster),
        World2HandChainSubsetClassV1.factualReusable,
      );
      expect(
        classifyWorld2HandChainSubsetV1(capstoneCluster),
        World2HandChainSubsetClassV1.capstoneComposition,
      );
    },
  );

  test('validator catches mixed pilot order drift', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_position_then_initiative_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s07_position_then_initiative_v1",
        "prompt":"Play this short two-step World 2 scenario chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1: Keep the same seats. Hero opened from the button and villain called. Who has initiative now?",
            "expected_action":"hero",
            "available_actions_v1":["hero","villain"],
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"initiative_aggressor_choice_mismatch"
          },
          {
            "street":"preflop",
            "prompt":"Step 2: Hero is on the button and villain is in the big blind. Who is in position?",
            "expected_action":"hero",
            "available_actions_v1":["hero","villain"],
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"position_thinking_choice_mismatch"
          }
        ]
      }
      ''');

    final issues = validateWorld2HandChainMixedSubsetSpecV1(
      spec: spec,
      source: 'memory://chain_position_then_initiative_v1',
    );

    expect(
      issues,
      contains(
        'memory://chain_position_then_initiative_v1: mixed hand_chain pilot step1 must stay preflop',
      ),
    );
    expect(
      issues,
      contains(
        'memory://chain_position_then_initiative_v1: mixed hand_chain pilot step2 must stay flop',
      ),
    );
  });

  test(
    'factual hand-chain position step prefers question_shape_v1 over prompt parsing',
    () {
      final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_position_then_initiative_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s07_position_then_initiative_v1",
        "prompt":"Play this short two-step World 2 scenario chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"preflop",
            "prompt":"Step 1: Hero is on the button and villain is in the big blind. Who acts later after the flop?",
            "question_shape_v1":"in_position",
            "expected_action":"hero",
            "available_actions_v1":["hero","villain"],
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"position_thinking_choice_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 2: Keep the same seats. Hero opened from the button and villain called. Who has initiative now?",
            "expected_action":"hero",
            "available_actions_v1":["hero","villain"],
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"initiative_aggressor_choice_mismatch"
          }
        ]
      }
      ''');

      expect(
        validateWorld2HandChainMixedSubsetSpecV1(
          spec: spec,
          source: 'memory://chain_position_then_initiative_v1',
        ),
        isEmpty,
      );
    },
  );

  test('validator supports position initiative pressure cluster reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_position_initiative_texture_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s09_position_initiative_texture_v1",
        "prompt":"Play this short three-step table-state chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"preflop",
            "prompt":"Step 1: Hero is on the button and villain is in the big blind. Who is in position?",
            "expected_action":"hero",
            "available_actions_v1":["hero","villain"],
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"position_thinking_choice_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 2: Keep the same seats. Hero opened preflop and villain called. Who has initiative on the flop?",
            "expected_action":"hero",
            "available_actions_v1":["hero","villain"],
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"initiative_aggressor_choice_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 3: Now the flop comes Jh Th 9c. Which action matches the more pressure-building texture?",
            "intent_v1":"texture_pressure_building",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","9c"],
            "available_actions_v1":["call","raise"],
            "expected_action":"raise",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch",
            "why_v1":"Connected two-tone boards create more pressure."
          }
        ]
      }
      ''');

    expect(
      validateWorld2HandChainMixedSubsetSpecV1(
        spec: spec,
        source: 'memory://chain_position_initiative_texture_v1',
      ),
      isEmpty,
    );
  });

  test('validator supports texture outs followup cluster reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_texture_outs_action_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s10_texture_outs_action_v1",
        "prompt":"Play this short three-step board-context chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1: On this flop, which action matches the more pressure-building texture?",
            "intent_v1":"texture_pressure_building",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","9c"],
            "available_actions_v1":["call","raise"],
            "expected_action":"raise",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch",
            "why_v1":"Connected two-tone boards create more pressure."
          },
          {
            "street":"flop",
            "prompt":"Step 2: Keep the same flop. Hero holds Qh 8h. How many outs improve hero to a flush?",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "board_cards_v1":["Jh","Th","9c"],
            "hero_hole_cards_v1":["Qh","8h"],
            "available_actions_v1":["4","8","9","15"],
            "expected_action":"9",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 3: Keep the same flop and hand. With a strong draw on this pressure-building board, which simple action fits better?",
            "intent_v1":"draw_pressure_assertive",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","9c"],
            "hero_hole_cards_v1":["Qh","8h"],
            "available_actions_v1":["call","raise"],
            "expected_action":"raise",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch",
            "why_v1":"A strong draw plus a dynamic flop supports the assertive line."
          }
        ]
      }
      ''');

    expect(
      validateWorld2HandChainMixedSubsetSpecV1(
        spec: spec,
        source: 'memory://chain_texture_outs_action_v1',
      ),
      isEmpty,
    );
  });

  test('validator supports texture outs singleton cluster reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_texture_then_outs_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s08_texture_then_outs_v1",
        "prompt":"Play this short board-context chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1: On this flop, which action matches the more pressure-building texture?",
            "intent_v1":"texture_pressure_building",
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","9c"],
            "available_actions_v1":["call","raise"],
            "expected_action":"raise",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch",
            "why_v1":"Connected two-tone boards build more pressure fast."
          },
          {
            "street":"flop",
            "prompt":"Step 2: Keep the same flop. Hero holds Qh 8h. How many outs improve hero to a flush?",
            "board_cards_v1":["Jh","Th","9c"],
            "hero_hole_cards_v1":["Qh","8h"],
            "available_actions_v1":["4","8","9","15"],
            "expected_action":"9",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          }
        ]
      }
      ''');

    expect(
      validateWorld2HandChainMixedSubsetSpecV1(
        spec: spec,
        source: 'memory://chain_texture_then_outs_v1',
      ),
      isEmpty,
    );
  });

  test('validator supports capstone cluster reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_world2_capstone_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s12_world2_capstone_v1",
        "prompt":"Play this short four-step World 2 capstone chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"preflop",
            "prompt":"Step 1: Hero is on the button and villain is in the big blind. Who is in position?",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "available_actions_v1":["hero","villain"],
            "expected_action":"hero",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 2: Keep the same seats. Hero opened preflop and villain called. Who has initiative on the flop?",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "available_actions_v1":["hero","villain"],
            "expected_action":"hero",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 3: Keep the same scene. The flop comes Jh Th 9c. Which action matches the more pressure-building texture?",
            "intent_v1":"texture_pressure_building",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","9c"],
            "available_actions_v1":["call","raise"],
            "expected_action":"raise",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 4: Keep the same flop. Hero holds Qh 8h and still has initiative. Which simple action fits best now?",
            "intent_v1":"draw_pressure_assertive",
            "player_count_v1":4,
            "hero_seat_v1":"btn",
            "villain_seat_v1":"bb",
            "active_seats_v1":["btn","bb"],
            "folded_seats_v1":["co"],
            "empty_seats_v1":["sb"],
            "last_aggressor_v1":"hero",
            "initiative_owner_v1":"hero",
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","9c"],
            "hero_hole_cards_v1":["Qh","8h"],
            "available_actions_v1":["call","raise"],
            "expected_action":"raise",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          }
        ]
      }
      ''');

    expect(
      validateWorld2HandChainMixedSubsetSpecV1(
        spec: spec,
        source: 'memory://chain_world2_capstone_v1',
      ),
      isEmpty,
    );
  });
}
