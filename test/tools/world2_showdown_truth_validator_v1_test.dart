import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_showdown_truth_validator_v1.dart';

void main() {
  test(
    'showdown_winner_choice_v1 exposes normalized scenario showdown payload',
    () {
      final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "normalized_showdown_payload",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Hero has top pair and villain has second pair. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["7c", "7s"],
        "board_cards_v1": ["Ad", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Top pair beats second pair.",
        "feedback_correct_v1": "Correct.",
        "feedback_incorrect_v1": "Incorrect."
      }
      ''');

      final scenario = spec.scenarioShowdownContextV1;

      expect(scenario, isNotNull);
      expect(scenario!.streetV1, 'river');
      expect(scenario.heroHoleCardsV1, const <String>['Ah', 'Qd']);
      expect(scenario.villainHoleCardsV1, const <String>['7c', '7s']);
      expect(scenario.boardCardsV1, const <String>[
        'Ad',
        'Kc',
        '9h',
        '4s',
        '2d',
      ]);
      expect(scenario.availableActionsV1, const <String>[
        'hero',
        'villain',
        'board_plays',
      ]);
      expect(scenario.expectedActionIdV1, 'hero');
    },
  );

  test('visible-card World 2 showdown drills pass the first truth slice', () {
    final report = validateWorld2ShowdownTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_board_plays_showdown.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_hero_top_pair_showdown.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_villain_straight_showdown.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_showdown_hero_top_pair.json',
      ]),
    );
    expect(report.checkedCount, 4);
    expect(report.skippedCount, 0);
    expect(
      report.checkedSources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_board_plays_showdown.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_hero_top_pair_showdown.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_villain_straight_showdown.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_showdown_hero_top_pair.json',
      ]),
    );
    expect(report.skippedSources, isEmpty);
    expect(report.skippedReasons, isEmpty);
  });

  test(
    'validator catches actor pair-label contradictions against visible cards',
    () {
      final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_pair_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: Hero has top pair. Villain has second pair. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["7c", "7s"],
        "board_cards_v1": ["Ad", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Top pair beats second pair.",
        "feedback_correct_v1": "Correct. Hero wins with the stronger pair.",
        "feedback_incorrect_v1": "Incorrect. Top pair beats second pair."
      }
      ''');

      final issues = validateWorld2ShowdownTruthSpecV1(
        spec: spec,
        source: 'memory://broken_pair_label',
      );

      expect(
        issues,
        contains(
          contains(
            'villain pair semantics copy says secondPair but visible cards resolve to underpair',
          ),
        ),
      );
    },
  );

  test(
    'validator rejects top-pair copy when a paired board changes the made-hand category',
    () {
      final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_board_pair_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: Hero has top pair. Villain has two pair. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["7c", "7s"],
        "board_cards_v1": ["Kd", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "villain"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Villain wins because hero only has top pair on the paired board.",
        "feedback_correct_v1": "Correct. Villain wins with two pair.",
        "feedback_incorrect_v1": "Incorrect. Hero does not just have top pair here."
      }
      ''');

      final issues = validateWorld2ShowdownTruthSpecV1(
        spec: spec,
        source: 'memory://broken_board_pair_label',
      );

      expect(
        issues,
        contains(
          contains(
            'hero pair semantics copy says topPair but visible cards resolve to none',
          ),
        ),
      );
    },
  );

  test(
    'validator catches stronger-pair copy when the winner is decided by kicker',
    () {
      final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_stronger_pair_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: Hero and villain both make a pair of queens. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "3d"],
        "villain_hole_cards_v1": ["Kh", "4c"],
        "board_cards_v1": ["Qd", "Qs", "7h", "5s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Hero wins with the stronger pair.",
        "feedback_correct_v1": "Correct. Hero wins with the stronger pair.",
        "feedback_incorrect_v1": "Incorrect. Hero's stronger pair wins."
      }
      ''');

      final issues = validateWorld2ShowdownTruthSpecV1(
        spec: spec,
        source: 'memory://broken_stronger_pair_label',
      );

      expect(
        issues,
        contains(
          contains(
            'stronger pair copy contradicts visible cards because the pair ranks are tied and kicker decides',
          ),
        ),
      );
    },
  );

  test('validator catches explicit actor straight-copy contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_straight_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: Villain makes a straight. Hero only has two pair. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["7c", "7s"],
        "board_cards_v1": ["Ad", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Straight beats one pair in the fixed hand ladder.",
        "feedback_correct_v1": "Correct. Villain wins with the straight.",
        "feedback_incorrect_v1": "Incorrect. Straight outranks one pair."
      }
      ''');

    final issues = validateWorld2ShowdownTruthSpecV1(
      spec: spec,
      source: 'memory://broken_straight_label',
    );

    expect(
      issues,
      contains(contains('villain straight copy contradicts visible cards')),
    );
  });

  test('validator catches generic two-pair copy contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_two_pair_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: Villain makes a straight. Hero only has two pair. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["7c", "7s"],
        "board_cards_v1": ["Ad", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Straight beats two pair in the fixed hand ladder.",
        "feedback_correct_v1": "Correct. Villain wins with the straight.",
        "feedback_incorrect_v1": "Incorrect. Straight outranks two pair."
      }
      ''');

    final issues = validateWorld2ShowdownTruthSpecV1(
      spec: spec,
      source: 'memory://broken_two_pair_label',
    );

    expect(
      issues,
      contains(contains('two-pair copy contradicts visible cards')),
    );
  });

  test('validator catches generic underpair copy contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_underpair_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: Hero has top pair. Villain has second pair. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["9c", "3s"],
        "board_cards_v1": ["Ad", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Top pair beats an underpair here before kicker detail matters.",
        "feedback_correct_v1": "Correct. Hero wins with the stronger pair.",
        "feedback_incorrect_v1": "Incorrect. Top pair beats an underpair here."
      }
      ''');

    final issues = validateWorld2ShowdownTruthSpecV1(
      spec: spec,
      source: 'memory://broken_underpair_label',
    );

    expect(
      issues,
      contains(contains('generic underpair copy contradicts visible cards')),
    );
  });

  test('validator catches explicit board-straight copy contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_board_straight_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: The board already makes the best straight for both players. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["7c", "7s"],
        "board_cards_v1": ["Ad", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "When the board already holds the best straight, both players tie.",
        "feedback_correct_v1": "Correct. Board plays and both players tie.",
        "feedback_incorrect_v1": "Incorrect. This board makes the best straight for everyone.",
        "recap_v1": "Sometimes the board already plays for everyone."
      }
      ''');

    final issues = validateWorld2ShowdownTruthSpecV1(
      spec: spec,
      source: 'memory://broken_board_straight_label',
    );

    expect(
      issues,
      contains(
        contains('board straight copy contradicts visible showdown truth'),
      ),
    );
  });

  test('validator catches explicit board-plays copy contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_board_plays_label",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: The board already makes the best hand for everyone. Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ah", "Qd"],
        "villain_hole_cards_v1": ["7c", "7s"],
        "board_cards_v1": ["Ad", "Kc", "9h", "4s", "2d"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "hero"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Both players tie because the board plays.",
        "feedback_correct_v1": "Correct. Board plays and both players tie.",
        "feedback_incorrect_v1": "Incorrect. The best five-card hand is already on the board."
      }
      ''');

    final issues = validateWorld2ShowdownTruthSpecV1(
      spec: spec,
      source: 'memory://broken_board_plays_label',
    );

    expect(
      issues,
      contains(contains('board-plays copy contradicts visible showdown truth')),
    );
  });

  test('validator requires explicit board-plays semantics when board plays', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "missing_board_plays_semantics",
        "kind": "showdown_winner_choice_v1",
        "prompt": "Showdown check: Who wins?",
        "street_v1": "river",
        "hero_hole_cards_v1": ["Ac", "7d"],
        "villain_hole_cards_v1": ["Kc", "2h"],
        "board_cards_v1": ["Ts", "9d", "8c", "7h", "6s"],
        "available_actions_v1": ["hero", "villain", "board_plays"],
        "expected": {"actionId": "board_plays"},
        "error_class": "showdown_winner_choice_mismatch",
        "why_v1": "Use visible cards first.",
        "feedback_correct_v1": "Correct.",
        "feedback_incorrect_v1": "Incorrect."
      }
      ''');

    final issues = validateWorld2ShowdownTruthSpecV1(
      spec: spec,
      source: 'memory://missing_board_plays_semantics',
    );

    expect(
      issues,
      contains(
        contains(
          'board-plays winner truth requires explicit board-plays or split-pot copy',
        ),
      ),
    );
  });
}
