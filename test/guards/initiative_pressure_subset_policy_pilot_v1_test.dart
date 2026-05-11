import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_initiative_truth_validator_v1.dart';

void main() {
  test('initiative pressure policy pilot registry stays aligned with code', () {
    const pilotPath = 'docs/plan/initiative_pressure_subset_policy_pilot_v1.md';
    final content = File(pilotPath).readAsStringSync();

    expect(File(pilotPath).existsSync(), isTrue);
    expect(content, contains('`initiative_aggressor_choice_v1`'));
    expect(content, contains('trainer-policy semantics'));
    expect(content, contains('`initiative_policy_shape_v1`'));
    expect(content, contains('`pressure_owner_v1`'));
    expect(content, contains('`expected.actionId`'));
    expect(content, contains('`pressure_owner`'));
    expect(
      content,
      contains('`test/tools/world2_initiative_truth_validator_v1_test.dart`'),
    );
    expect(
      content,
      contains(
        '`test/ui_v2/session_drill_player_initiative_contract_test.dart`',
      ),
    );
    expect(
      content,
      contains(
        '`content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json`',
      ),
    );
    expect(
      content,
      contains(
        '`content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json`',
      ),
    );
  });

  test(
    'initiative pressure residue content satisfies the bounded policy pilot contract',
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

      expect(liveResidue.kind, DrillKindV1.initiativeAggressorChoice);
      expect(liveResidue.initiativePolicyShapeV1, 'pressure_owner');
      expect(liveResidue.pressureOwnerV1, 'hero');
      expect(liveResidue.expected.actionId, 'hero');
      expect(liveResidue.whyV1, isNotNull);
      expect(liveResidue.feedbackCorrectV1, isNotNull);
      expect(liveResidue.feedbackIncorrectV1, isNotNull);

      expect(reviewResidue.kind, DrillKindV1.initiativeAggressorChoice);
      expect(reviewResidue.initiativePolicyShapeV1, 'pressure_owner');
      expect(reviewResidue.pressureOwnerV1, 'hero');
      expect(reviewResidue.expected.actionId, 'hero');
      expect(reviewResidue.whyV1, isNotNull);
    },
  );

  test(
    'initiative pressure policy pilot remains explicitly outside exact initiative truth',
    () {
      final report = validateWorld2InitiativeTruthDirectoryV1(
        'content/worlds/world2/v1/sessions',
      );

      expect(report.issues, isEmpty);
      expect(
        report.skippedSources,
        contains(
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json',
        ),
      );
      expect(
        report.skippedSources,
        contains(
          'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json',
        ),
      );
    },
  );
}
