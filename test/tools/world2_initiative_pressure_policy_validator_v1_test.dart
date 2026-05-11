import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_initiative_pressure_policy_validator_v1.dart';

void main() {
  test('initiative pressure policy family boundary is deterministic', () {
    final report = validateWorld2InitiativePressurePolicyDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json',
      ]),
    );
    expect(report.checkedSources, unorderedEquals(report.familySources));
    expect(report.checkedCount, 2);
    expect(report.excludedCount, 0);
    expect(report.excludedSources, isEmpty);
    expect(report.excludedReasons, isEmpty);
  });

  test('validator catches contradictory pressure owner target', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_pressure_target",
        "kind": "initiative_aggressor_choice_v1",
        "prompt": "Hero raised and villain called. Who is more likely to continue pressure on the flop?",
        "initiative_policy_shape_v1": "pressure_owner",
        "pressure_owner_v1": "hero",
        "available_actions_v1": ["hero", "villain"],
        "expected": {"actionId": "villain"},
        "error_class": "initiative_aggressor_choice_mismatch",
        "why_v1": "Hero is more likely to continue pressure first.",
        "feedback_correct_v1": "Correct.",
        "feedback_incorrect_v1": "Incorrect."
      }
      ''');

    final issues = validateWorld2InitiativePressurePolicySpecV1(
      spec: spec,
      source: 'memory://broken_pressure_target',
    );

    expect(
      issues,
      contains(
        contains(
          'expected.actionId villain contradicts pressure_owner_v1 hero',
        ),
      ),
    );
  });

  test('validator catches contradictory pressure copy', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_pressure_copy",
        "kind": "initiative_aggressor_choice_v1",
        "prompt": "Hero raised and villain called. Who is more likely to continue pressure on the flop?",
        "initiative_policy_shape_v1": "pressure_owner",
        "pressure_owner_v1": "hero",
        "available_actions_v1": ["hero", "villain"],
        "expected": {"actionId": "hero"},
        "error_class": "initiative_aggressor_choice_mismatch",
        "why_v1": "Villain is more likely to continue pressure first.",
        "feedback_correct_v1": "Correct.",
        "feedback_incorrect_v1": "Incorrect."
      }
      ''');

    final issues = validateWorld2InitiativePressurePolicySpecV1(
      spec: spec,
      source: 'memory://broken_pressure_copy',
    );

    expect(
      issues,
      contains(
        contains('villain pressure copy contradicts pressure_owner_v1 hero'),
      ),
    );
  });

  test('residue drills carry the authored pressure policy seam', () {
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

    expect(
      validateWorld2InitiativePressurePolicySpecV1(
        spec: liveResidue,
        source: 'memory://live_residue',
      ),
      isEmpty,
    );
    expect(
      validateWorld2InitiativePressurePolicySpecV1(
        spec: reviewResidue,
        source: 'memory://review_residue',
      ),
      isEmpty,
    );
  });
}
