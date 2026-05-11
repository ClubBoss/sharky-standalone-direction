import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_board_texture_truth_validator_v1.dart';

void main() {
  test('board-texture dry policy pilot registry stays aligned with code', () {
    const pilotPath = 'docs/plan/board_texture_dry_subset_policy_pilot_v1.md';
    final content = File(pilotPath).readAsStringSync();

    expect(File(pilotPath).existsSync(), isTrue);
    expect(content, contains('`board_texture_classifier_v1`'));
    expect(content, contains('trainer-policy semantics'));
    expect(content, contains('`board_texture_policy_shape_v1`'));
    expect(content, contains('`board_texture_policy_target_v1`'));
    expect(content, contains('`expected_action`'));
    expect(content, contains('`pressure_level`'));
    expect(content, contains('`calmer`'));
    expect(
      content,
      contains(
        '`test/tools/world2_board_texture_truth_validator_v1_test.dart`',
      ),
    );
    expect(
      content,
      contains(
        '`test/ui_v2/session_drill_player_world2_board_texture_contract_test.dart`',
      ),
    );
    expect(
      content,
      contains(
        '`test/ui_v2/session_drill_player_board_texture_contract_test.dart`',
      ),
    );
    expect(
      content,
      contains(
        '`content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json`',
      ),
    );
    expect(
      content,
      contains(
        '`content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json`',
      ),
    );
  });

  test(
    'board-texture dry residue content satisfies the bounded policy pilot contract',
    () {
      final liveResidue = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json',
        ).readAsStringSync(),
      );
      final reviewResidue = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json',
        ).readAsStringSync(),
      );

      expect(liveResidue.kind, DrillKindV1.boardTextureClassifier);
      expect(liveResidue.boardTexturePolicyShapeV1, 'pressure_level');
      expect(liveResidue.boardTexturePolicyTargetV1, 'calmer');
      expect(liveResidue.expectedActionV1, 'call');
      expect(liveResidue.whyV1, isNotNull);
      expect(liveResidue.feedbackCorrectV1, isNotNull);
      expect(liveResidue.feedbackIncorrectV1, isNotNull);

      expect(reviewResidue.kind, DrillKindV1.boardTextureClassifier);
      expect(reviewResidue.boardTexturePolicyShapeV1, 'pressure_level');
      expect(reviewResidue.boardTexturePolicyTargetV1, 'calmer');
      expect(reviewResidue.expectedActionV1, 'call');
      expect(reviewResidue.whyV1, isNotNull);
    },
  );

  test(
    'board-texture dry policy pilot remains explicitly outside exact board-texture truth',
    () {
      final report = validateWorld2BoardTextureTruthDirectoryV1(
        'content/worlds/world2/v1/sessions',
      );

      expect(report.issues, isEmpty);
      expect(
        report.skippedSources,
        contains(
          'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json',
        ),
      );
      expect(
        report.skippedSources,
        contains(
          'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json',
        ),
      );
    },
  );
}
