import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_board_texture_truth_validator_v1.dart';

void main() {
  test('exact board-texture subset pilot registry stays aligned with code', () {
    const pilotPath = 'docs/plan/exact_board_texture_subset_pilot_v1.md';
    final content = File(pilotPath).readAsStringSync();

    expect(File(pilotPath).existsSync(), isTrue);
    expect(content, contains('`board_texture_classifier_v1`'));
    expect(content, contains('exactly 3 `board_cards_v1`'));
    expect(content, contains('`board_texture_v1`'));
    expect(content, contains('`paired`'));
    expect(content, contains('`connected`'));
    expect(
      content,
      contains('`lib/services/world2_board_texture_truth_validator_v1.dart`'),
    );
    expect(
      content,
      contains('`test/tools/world2_board_texture_truth_validator_v1_test.dart`'),
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
    'representative board-texture exact-subset content satisfies the pilot contract',
    () {
      final connectedSpec = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_coordinated_jack_ten_nine_two_tone.json',
        ).readAsStringSync(),
      );
      final pairedSpec = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_paired_king_king_three_rainbow.json',
        ).readAsStringSync(),
      );

      expect(connectedSpec.kind, DrillKindV1.boardTextureClassifier);
      expect(connectedSpec.boardCardsV1, hasLength(3));
      expect(connectedSpec.boardTextureV1, 'connected');
      expect(connectedSpec.streetV1, 'flop');
      expect(connectedSpec.expectedActionV1, 'raise');

      expect(pairedSpec.kind, DrillKindV1.boardTextureClassifier);
      expect(pairedSpec.boardCardsV1, hasLength(3));
      expect(pairedSpec.boardTextureV1, 'paired');
      expect(pairedSpec.streetV1, 'flop');
      expect(pairedSpec.expectedActionV1, 'call');
    },
  );

  test(
    'exact board-texture subset pilot remains validator-clean with explicit exclusions',
    () {
      final report = validateWorld2BoardTextureTruthDirectoryV1(
        'content/worlds/world2/v1/sessions',
      );

      expect(report.issues, isEmpty);
      expect(report.checkedCount, 2);
      expect(report.skippedCount, 2);
      expect(
        report.checkedSources,
        unorderedEquals(<String>[
          'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_coordinated_jack_ten_nine_two_tone.json',
          'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_paired_king_king_three_rainbow.json',
        ]),
      );
      expect(
        report.skippedSources,
        unorderedEquals(<String>[
          'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json',
          'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json',
        ]),
      );
    },
  );
}
