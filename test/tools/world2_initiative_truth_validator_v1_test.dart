import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_initiative_truth_validator_v1.dart';

void main() {
  test('queue, registry, and initiative family stay aligned', () {
    final queue = File(
      'docs/plan/world2_truth_family_queue_v1.md',
    ).readAsStringSync();
    final registry = File(
      'docs/plan/world2_truth_family_registry_v1.md',
    ).readAsStringSync();

    expect(queue, contains('`initiative_aggressor_choice_v1`'));
    expect(queue, contains('`initiative_aggressor_choice_v1`'));
    expect(
      queue,
      contains(
        'exact initiative questions and the authored `pressure_owner_v1` subset now resolve through one bounded validator seam',
      ),
    );
    expect(registry, contains('`initiative_aggressor_choice_v1`'));
    expect(
      registry,
      contains('`lib/services/world2_initiative_truth_validator_v1.dart`'),
    );
    expect(
      registry,
      contains('`tools/validate_world2_initiative_truth_v1.dart`'),
    );
    expect(
      registry,
      contains('`test/tools/world2_initiative_truth_validator_v1_test.dart`'),
    );
  });

  test('World 2 initiative family boundary is deterministic', () {
    final report = validateWorld2InitiativeTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_has_initiative_open_vs_call.json',
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json',
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_villain_last_aggressor_open_vs_call.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json',
      ]),
    );
    expect(
      report.checkedSources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_has_initiative_open_vs_call.json',
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json',
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_villain_last_aggressor_open_vs_call.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json',
      ]),
    );
    expect(report.skippedSources, isEmpty);
    expect(report.checkedCount, 4);
    expect(report.skippedCount, 0);
  });

  test('validator catches initiative-copy contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_initiative_copy",
        "kind": "initiative_aggressor_choice_v1",
        "prompt": "Hero raised preflop and villain called. Who has initiative on the flop?",
        "player_count_v1": 2,
        "hero_seat_v1": "btn",
        "villain_seat_v1": "bb",
        "active_seats_v1": ["btn", "bb"],
        "street_v1": "flop",
        "last_aggressor_v1": "hero",
        "initiative_owner_v1": "hero",
        "available_actions_v1": ["hero", "villain"],
        "expected": {"actionId": "hero"},
        "error_class": "initiative_aggressor_choice_mismatch",
        "why_v1": "Villain keeps initiative here.",
        "feedback_correct_v1": "Correct. Villain has initiative on the flop.",
        "feedback_incorrect_v1": "Incorrect. Villain keeps initiative here."
      }
      ''');

    final issues = validateWorld2InitiativeTruthSpecV1(
      spec: spec,
      source: 'memory://broken_initiative_copy',
    );

    expect(
      issues,
      contains(
        contains('villain initiative copy contradicts initiative truth'),
      ),
    );
  });

  test(
    'initiative pressure-owner subset now validates through the same family seam',
    () {
      final liveResidue = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json',
        ).readAsStringSync(),
      );
      final reviewResidue = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json',
        ).readAsStringSync(),
      );

      expect(liveResidue.pressureOwnerV1, 'hero');
      expect(liveResidue.initiativePolicyShapeV1, 'pressure_owner');
      expect(liveResidue.expected.actionId, 'hero');
      expect(reviewResidue.pressureOwnerV1, 'hero');
      expect(reviewResidue.initiativePolicyShapeV1, 'pressure_owner');
      expect(reviewResidue.expected.actionId, 'hero');

      final report = validateWorld2InitiativeTruthDirectoryV1(
        'content/worlds/world2/v1/sessions',
      );
      expect(report.issues, isEmpty);
      expect(
        report.checkedSources,
        contains(
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json',
        ),
      );
      expect(
        report.checkedSources,
        contains(
          'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json',
        ),
      );
      expect(report.skippedSources, isEmpty);
    },
  );

  test(
    'authored exact initiative drills expose a normalized scenario payload',
    () {
      final spec = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_has_initiative_open_vs_call.json',
        ).readAsStringSync(),
      );

      final scenario = spec.scenarioInitiativeContextV1;

      expect(scenario, isNotNull);
      expect(scenario!.streetV1, 'flop');
      expect(scenario.playerCountV1, 2);
      expect(scenario.heroSeatV1, 'btn');
      expect(scenario.villainSeatV1, 'bb');
      expect(scenario.activeSeatsV1, equals(<String>['btn', 'bb']));
      expect(scenario.lastAggressorV1, 'hero');
      expect(scenario.initiativeOwnerV1, 'hero');
      expect(scenario.expectedActionIdV1, 'hero');
    },
  );
}
