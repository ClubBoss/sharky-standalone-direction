import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_action_choice_policy_validator_v1.dart';

void main() {
  test('queue, registry, and action_choice policy lane stay aligned', () {
    final queue = File(
      'docs/plan/world2_truth_family_queue_v1.md',
    ).readAsStringSync();
    final registry = File(
      'docs/plan/world2_truth_family_registry_v1.md',
    ).readAsStringSync();

    expect(queue, contains('`action_choice`'));
    expect(
      queue,
      contains(
        'R254 onboards `action_choice` as the first trainer-policy lane pilot',
      ),
    );
    expect(registry, contains('`action_choice`'));
    expect(
      registry,
      contains('`lib/services/world2_action_choice_policy_validator_v1.dart`'),
    );
    expect(
      registry,
      contains('`tools/validate_world2_action_choice_policy_v1.dart`'),
    );
    expect(
      registry,
      contains(
        '`test/tools/world2_action_choice_policy_validator_v1_test.dart`',
      ),
    );
  });

  test('World 2 action_choice policy family boundary is deterministic', () {
    final report = validateWorld2ActionChoicePolicyDirectoryV1(
      'content/worlds/world2/v1',
    );

    expect(report.issues, isEmpty);
    expect(report.checkedCount, 87);
    expect(report.excludedCount, 0);
    expect(report.familySources.length, 87);
    expect(report.checkedSources.length, 87);
    expect(report.excludedSources, isEmpty);
    expect(report.excludedReasons, isEmpty);
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.bridge_review_dry_cheap_continue_v1.json',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.bridge_review_connected_future_street_release_v1.json',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.bridge_review_paired_fair_price_continue_v1.json',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.bridge_review_wet_expensive_release_v1.json',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json#step1',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.chain_texture_outs_action_v1.json#step1',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json#step3',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s11/drills/d.chain_position_initiative_action_v1.json#step3',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s12/drills/d.chain_world2_capstone_v1.json#step3',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.chain_texture_outs_action_v1.json#step3',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s12/drills/d.chain_world2_capstone_v1.json#step4',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s13/drills/d.chain_texture_outs_continue_v1.json#step3',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s13/drills/d.chain_texture_outs_continue_v1.json#step1',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json#step1',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json#step3',
      ),
    );
  });

  test('validator catches contradictory acceptable_actions framing', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_call_tolerance",
        "kind": "action_choice",
        "prompt": "Choose the defined response.",
        "intent_v1": "position_ip_advantage",
        "why_v1": "The authored default stays passive here.",
        "expected": {"actionId": "call"},
        "acceptable_actions": ["call", "raise"],
        "error_class": "action_selection"
      }
      ''');

    final issues = validateWorld2ActionChoicePolicySpecV1(
      spec: spec,
      source: 'memory://broken_call_tolerance',
    );

    expect(
      issues,
      contains(
        contains(
          'acceptable_actions call/raise contradict expected.actionId call',
        ),
      ),
    );
  });

  test('validator catches out-of-family policy bucket usage', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_intent_bucket",
        "kind": "action_choice",
        "prompt": "Choose the authored response.",
        "intent_v1": "world2_showdown_bridge",
        "why_v1": "Stay inside the authored policy bucket.",
        "expected": {"actionId": "raise"},
        "acceptable_actions": ["raise", "call"],
        "error_class": "action_selection"
      }
      ''');

    final issues = validateWorld2ActionChoicePolicySpecV1(
      spec: spec,
      source: 'memory://broken_intent_bucket',
    );

    expect(
      issues,
      contains(
        contains(
          'intent_v1 must stay within the World 2 action_choice policy buckets',
        ),
      ),
    );
  });

  test('validator supports normalized hand_chain action-policy step reuse', () {
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
            "why_v1":"Connected boards build more pressure."
          },
          {
            "street":"flop",
            "prompt":"Step 2",
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
      validateWorld2ActionChoicePolicyChainStepV1(
        step: spec.chainStepsV1!.first,
        source: 'memory://chain_texture_then_outs_v1#step1',
      ),
      isEmpty,
    );
  });

  test('validator supports strong-draw assertive hand_chain step reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_texture_outs_action_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s10_texture_outs_action_v1",
        "prompt":"Play this short board-context chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1",
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
            "prompt":"Step 2: With a strong draw on this pressure-building board, which simple action fits better?",
            "intent_v1":"draw_pressure_assertive",
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
      validateWorld2ActionChoicePolicyChainStepV1(
        step: spec.chainStepsV1!.last,
        source: 'memory://chain_texture_outs_action_v1#step2',
      ),
      isEmpty,
    );
  });

  test('validator supports manageable-price continue hand_chain step reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_texture_outs_continue_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s13_texture_outs_continue_v1",
        "prompt":"Play this short draw-and-price chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1",
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
            "prompt":"Step 2: Villain makes a small bet, so the price to continue is manageable. Which simple action fits better now?",
            "intent_v1":"draw_price_continue",
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","9c"],
            "hero_hole_cards_v1":["Qh","8h"],
            "available_actions_v1":["fold","call"],
            "expected_action":"call",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch",
            "why_v1":"A strong draw plus a manageable price is enough to continue."
          }
        ]
      }
      ''');

    expect(
      validateWorld2ActionChoicePolicyChainStepV1(
        step: spec.chainStepsV1!.last,
        source: 'memory://chain_texture_outs_continue_v1#step2',
      ),
      isEmpty,
    );
  });

  test('validator supports poor-price release hand_chain step reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_texture_outs_fold_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s14_texture_outs_fold_v1",
        "prompt":"Play this short draw-and-price discipline chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1",
            "board_cards_v1":["Jh","Th","4h"],
            "hero_hole_cards_v1":["Qd","8d"],
            "available_actions_v1":["4","8","9","15"],
            "expected_action":"4",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 2: Villain makes a bigger bet, so the price to continue is poor. Which simple action fits better now?",
            "intent_v1":"draw_price_release",
            "board_texture_v1":"coordinated_two_tone",
            "board_cards_v1":["Jh","Th","4h"],
            "hero_hole_cards_v1":["Qd","8d"],
            "available_actions_v1":["fold","call"],
            "expected_action":"fold",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch",
            "why_v1":"A weak gutshot plus a poor price is not enough to continue."
          }
        ]
      }
      ''');

    expect(
      validateWorld2ActionChoicePolicyChainStepV1(
        step: spec.chainStepsV1!.last,
        source: 'memory://chain_texture_outs_fold_v1#step2',
      ),
      isEmpty,
    );
  });

  test('validator supports pressure-board follow-up hand_chain step reuse', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_position_initiative_action_v1",
        "kind":"hand_chain_v1",
        "chain_id":"w2_s11_position_initiative_action_v1",
        "prompt":"Play this short table-state action chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1",
            "available_actions_v1":["hero","villain"],
            "expected_action":"hero",
            "feedback_correct_v1":"Correct.",
            "feedback_incorrect_v1":"Incorrect.",
            "error_class":"expected_action_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 2: Which simple action fits better on this pressure-building board?",
            "intent_v1":"texture_pressure_building",
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
      validateWorld2ActionChoicePolicyChainStepV1(
        step: spec.chainStepsV1!.last,
        source: 'memory://chain_position_initiative_action_v1#step2',
      ),
      isEmpty,
    );
  });
}
