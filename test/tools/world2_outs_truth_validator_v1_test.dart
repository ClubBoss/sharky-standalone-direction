import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_outs_truth_validator_v1.dart';

void main() {
  test('outs_count_choice_v1 exposes normalized scenario outs payload', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "normalized_outs_payload",
        "kind": "outs_count_choice_v1",
        "prompt": "Four-flush on the flop. How many outs?",
        "street_v1": "flop",
        "hero_hole_cards_v1": ["Ah", "Qh"],
        "board_cards_v1": ["Kc", "7h", "2h"],
        "available_actions_v1": ["4", "8", "9", "15"],
        "expected": {"actionId": "9"},
        "error_class": "outs_count_choice_mismatch",
        "why_v1": "A flush draw usually has 9 outs.",
        "feedback_correct_v1": "Correct.",
        "feedback_incorrect_v1": "Incorrect."
      }
      ''');

    final scenario = spec.scenarioOutsContextV1;

    expect(scenario, isNotNull);
    expect(scenario!.streetV1, 'flop');
    expect(scenario.heroHoleCardsV1, const <String>['Ah', 'Qh']);
    expect(scenario.boardCardsV1, const <String>['Kc', '7h', '2h']);
    expect(scenario.availableActionsV1, const <String>['4', '8', '9', '15']);
    expect(scenario.expectedActionIdV1, '9');
  });

  test('World 2 outs family boundary is deterministic and fully checked', () {
    final report = validateWorld2OutsTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_flush_draw_nine_outs.json',
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_gutshot_four_outs.json',
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_open_ended_straight_draw_eight_outs.json',
      ]),
    );
    expect(report.checkedCount, 3);
    expect(report.skippedCount, 0);
    expect(report.checkedSources, unorderedEquals(report.familySources));
    expect(report.skippedSources, isEmpty);
    expect(report.skippedReasons, isEmpty);
  });

  test('validator catches outs count and draw-label contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_outs_label",
        "kind": "outs_count_choice_v1",
        "prompt": "Hero has 8c7d on 9s6h2c. How many outs improve hero to a straight on the turn?",
        "street_v1": "flop",
        "hero_hole_cards_v1": ["8c", "7d"],
        "board_cards_v1": ["9s", "6h", "2c"],
        "available_actions_v1": ["4", "8", "9", "15"],
        "expected": {"actionId": "4"},
        "error_class": "outs_count_choice_mismatch",
        "why_v1": "This gutshot has 4 outs.",
        "feedback_correct_v1": "Correct. Only 4 outs improve hero here.",
        "feedback_incorrect_v1": "Incorrect. This gutshot has only 4 outs."
      }
      ''');

    final issues = validateWorld2OutsTruthSpecV1(
      spec: spec,
      source: 'memory://broken_outs_label',
    );

    expect(
      issues,
      contains(
        contains('expected outs 4 contradict visible-card outs truth 8'),
      ),
    );
    expect(
      issues,
      contains(contains('gutshot copy contradicts visible cards')),
    );
  });

  test('validator supports chain-step outs shape reuse', () {
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
            "prompt":"Step 1",
            "expected_action":"raise",
            "available_actions_v1":["call","raise"],
            "error_class":"expected_action_mismatch"
          },
          {
            "street":"flop",
            "prompt":"Step 2: Keep the same flop. Hero holds Qh 8h. How many outs improve hero to a flush?",
            "board_cards_v1":["Jh","Th","9c"],
            "hero_hole_cards_v1":["Qh","8h"],
            "available_actions_v1":["4","8","9","15"],
            "expected_action":"9",
            "feedback_correct_v1":"Correct. With four hearts visible, nine unseen hearts remain.",
            "feedback_incorrect_v1":"Incorrect. Two hearts in hand plus two on board leave nine flush outs.",
            "error_class":"expected_action_mismatch",
            "why_v1":"Count the unseen hearts that complete the flush, not every improving card."
          }
        ]
      }
      ''');

    final issues = validateWorld2OutsTruthChainStepV1(
      step: spec.chainStepsV1![1],
      source: 'memory://chain_texture_then_outs_v1#step2',
    );

    expect(issues, isEmpty);
    expect(
      deriveWorld2OutsTruthChainStepV1(spec.chainStepsV1![1]).outsCount,
      9,
    );
  });

  test('validator catches chain-step outs contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id":"chain_bad_outs_v1",
        "kind":"hand_chain_v1",
        "chain_id":"chain_bad_outs_v1",
        "prompt":"Play chain.",
        "expected":{},
        "error_class":"unused",
        "steps":[
          {
            "street":"flop",
            "prompt":"Step 1: Keep the same flop. Hero holds Qd8d. How many clean outs improve hero to a straight?",
            "board_cards_v1":["Jh","Th","4h"],
            "hero_hole_cards_v1":["Qd","8d"],
            "available_actions_v1":["4","8","9","15"],
            "expected_action":"8",
            "feedback_correct_v1":"Correct. This gutshot has 8 outs.",
            "feedback_incorrect_v1":"Incorrect. This gutshot has 8 outs.",
            "error_class":"expected_action_mismatch",
            "why_v1":"This gutshot has 8 outs."
          },
          {
            "street":"turn",
            "prompt":"Step 2",
            "expected_action":"call",
            "available_actions_v1":["call","raise"],
            "error_class":"expected_action_mismatch"
          }
        ]
      }
      ''');

    final issues = validateWorld2OutsTruthChainStepV1(
      step: spec.chainStepsV1!.first,
      source: 'memory://chain_bad_outs_v1#step1',
    );

    expect(
      issues,
      contains(
        contains('expected outs 8 contradict visible-card outs truth 4'),
      ),
    );
    expect(
      issues,
      contains(contains('outs copy says 8 but visible cards resolve to 4')),
    );
  });
}
