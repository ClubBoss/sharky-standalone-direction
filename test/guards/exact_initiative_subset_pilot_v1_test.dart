import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_initiative_truth_validator_v1.dart';

void main() {
  test('exact initiative subset pilot registry stays aligned with code', () {
    const lanePath = 'docs/plan/exact_initiative_subset_pilot_v1.md';
    final content = File(lanePath).readAsStringSync();

    expect(File(lanePath).existsSync(), isTrue);
    expect(content, contains('`initiative_aggressor_choice_v1`'));
    expect(content, contains('`last_aggressor_v1`'));
    expect(content, contains('`initiative_owner_v1`'));
    expect(content, contains('Who was the last aggressor?'));
    expect(content, contains('Who has initiative?'));
    expect(
      content,
      contains('`lib/services/world2_initiative_truth_validator_v1.dart`'),
    );
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
    'representative initiative exact-subset content satisfies the pilot contract',
    () {
      final initiativeSpec = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_has_initiative_open_vs_call.json',
        ).readAsStringSync(),
      );
      final aggressorSpec = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_villain_last_aggressor_open_vs_call.json',
        ).readAsStringSync(),
      );

      expect(initiativeSpec.kind, DrillKindV1.initiativeAggressorChoice);
      expect(initiativeSpec.lastAggressorV1, isNotNull);
      expect(initiativeSpec.initiativeOwnerV1, isNotNull);
      expect(initiativeSpec.activeSeatsV1, isNotNull);
      expect(initiativeSpec.streetV1, isNotNull);
      expect(initiativeSpec.expected.actionId, 'hero');

      expect(aggressorSpec.kind, DrillKindV1.initiativeAggressorChoice);
      expect(aggressorSpec.lastAggressorV1, isNotNull);
      expect(aggressorSpec.initiativeOwnerV1, isNotNull);
      expect(aggressorSpec.activeSeatsV1, isNotNull);
      expect(aggressorSpec.streetV1, isNotNull);
      expect(aggressorSpec.expected.actionId, 'villain');
    },
  );

  test(
    'exact initiative subset pilot remains validator-clean with explicit exclusions',
    () {
      final report = validateWorld2InitiativeTruthDirectoryV1(
        'content/worlds/world2/v1/sessions',
      );

      expect(report.issues, isEmpty);
      expect(report.checkedCount, 2);
      expect(report.skippedCount, 2);
      expect(
        report.checkedSources,
        unorderedEquals(<String>[
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_has_initiative_open_vs_call.json',
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_villain_last_aggressor_open_vs_call.json',
        ]),
      );
      expect(
        report.skippedSources,
        unorderedEquals(<String>[
          'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json',
          'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json',
        ]),
      );
    },
  );
}
