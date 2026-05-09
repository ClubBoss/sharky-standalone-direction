import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_board_texture_truth_validator_v1.dart';
import 'dart:io';

void main() {
  test('World 2 board-texture family boundary is deterministic', () {
    final report = validateWorld2BoardTextureTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );

    expect(report.issues, isEmpty);
    expect(
      report.familySources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_coordinated_jack_ten_nine_two_tone.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_paired_king_king_three_rainbow.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json',
      ]),
    );
    expect(
      report.checkedSources,
      unorderedEquals(<String>[
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_coordinated_jack_ten_nine_two_tone.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_paired_king_king_three_rainbow.json',
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json',
      ]),
    );
    expect(report.skippedSources, isEmpty);
    expect(report.checkedCount, 4);
    expect(report.skippedCount, 0);
  });

  test('validator catches board-texture label contradictions', () {
    final spec = DrillSpecV1.fromJsonString('''
      {
        "id": "broken_paired_copy",
        "kind": "board_texture_classifier_v1",
        "prompt": "Flop K-K-3 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.",
        "street_v1": "flop",
        "board_cards_v1": ["Kh", "Kd", "3c"],
        "board_texture_v1": "paired",
        "available_actions_v1": ["call", "raise"],
        "expected_action": "call",
        "error_class": "expected_action_mismatch",
        "why_v1": "This coordinated flop builds pressure.",
        "feedback_correct_v1": "Correct. This connected board builds pressure fast.",
        "feedback_incorrect_v1": "Incorrect. This connected texture creates many draw paths."
      }
      ''');

    final issues = validateWorld2BoardTextureTruthSpecV1(
      spec: spec,
      source: 'memory://broken_connected_label',
    );

    expect(
      issues,
      contains(contains('connected-texture copy contradicts board truth')),
    );
  });

  test('dry subset now validates through the same board-texture truth seam', () {
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

    expect(liveResidue.boardTexturePolicyShapeV1, 'pressure_level');
    expect(liveResidue.boardTexturePolicyTargetV1, 'calmer');
    expect(liveResidue.boardTextureV1, 'dry');
    expect(liveResidue.expectedActionV1, 'call');
    expect(reviewResidue.boardTexturePolicyShapeV1, 'pressure_level');
    expect(reviewResidue.boardTexturePolicyTargetV1, 'calmer');
    expect(reviewResidue.boardTextureV1, 'dry');
    expect(reviewResidue.expectedActionV1, 'call');

    expect(liveResidue.streetV1, 'flop');
    expect(liveResidue.boardCardsV1, const <String>['As', '7d', '2c']);
    expect(reviewResidue.streetV1, 'flop');
    expect(reviewResidue.boardCardsV1, const <String>['As', '7d', '2c']);

    final report = validateWorld2BoardTextureTruthDirectoryV1(
      'content/worlds/world2/v1/sessions',
    );
    expect(report.issues, isEmpty);
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json',
      ),
    );
    expect(
      report.checkedSources,
      contains(
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json',
      ),
    );
    expect(report.skippedSources, isEmpty);
  });

  test('exact board-texture subset exposes normalized scenario payload', () {
    final exactSpec = DrillSpecV1.fromJsonString(
      File(
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_paired_king_king_three_rainbow.json',
      ).readAsStringSync(),
    );

    final textureContext = exactSpec.scenarioBoardTextureContextV1;
    expect(textureContext, isNotNull);
    expect(textureContext!.streetV1, 'flop');
    expect(textureContext.boardCardsV1, const <String>['Kh', 'Kd', '3c']);
    expect(textureContext.boardTextureV1, 'paired');
    expect(textureContext.availableActionsV1, const <String>['call', 'raise']);
    expect(textureContext.expectedActionIdV1, 'call');
  });
}
