import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_outs_truth_validator_v1.dart';

void main() {
  test(
    'deterministic outs lane registry stays aligned with code and tests',
    () {
      const lanePath = 'docs/plan/deterministic_outs_lane_v1.md';
      final content = File(lanePath).readAsStringSync();

      expect(File(lanePath).existsSync(), isTrue);
      expect(content, contains('`outs_count_choice_v1`'));
      expect(content, contains('`4|8|9|15`'));
      expect(
        content,
        contains('`lib/services/world2_outs_truth_validator_v1.dart`'),
      );
      expect(
        content,
        contains('`test/tools/world2_outs_truth_validator_v1_test.dart`'),
      );
      expect(
        content,
        contains(
          '`test/ui_v2/session_drill_player_world2_outs_contract_test.dart`',
        ),
      );
    },
  );

  test('representative outs content satisfies the explicit lane contract', () {
    final spec = DrillSpecV1.fromJsonString(
      File(
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_flush_draw_nine_outs.json',
      ).readAsStringSync(),
    );

    expect(spec.kind, DrillKindV1.outsCountChoice);
    expect(spec.streetV1, 'flop');
    expect(spec.heroHoleCardsV1, hasLength(2));
    expect(spec.boardCardsV1, hasLength(3));
    expect(spec.availableActionsV1, const <String>['4', '8', '9', '15']);
    expect(spec.expected.actionId, '9');
    expect(spec.feedbackCorrectV1, isNotNull);
    expect(spec.feedbackIncorrectV1, isNotNull);
  });

  test('current outs lane remains validator-clean and fully checked', () {
    final report = validateWorld2OutsTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(report.checkedCount, 3);
    expect(report.skippedCount, 0);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_flush_draw_nine_outs.json',
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_open_ended_straight_draw_eight_outs.json',
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_gutshot_four_outs.json',
      ]),
    );
  });
}
