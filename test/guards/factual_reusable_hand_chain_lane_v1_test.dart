import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_hand_chain_mixed_subset_validator_v1.dart';

void main() {
  test(
    'factual reusable hand-chain lane registry stays aligned with code and tests',
    () {
      const lanePath = 'docs/plan/factual_reusable_hand_chain_lane_v1.md';
      final content = File(lanePath).readAsStringSync();

      expect(File(lanePath).existsSync(), isTrue);
      expect(content, contains('`hand_chain_v1`'));
      expect(content, contains('`factualReusable`'));
      expect(content, contains('`w2_s07_position_then_initiative_v1`'));
      expect(content, contains('`w2_s08_texture_then_outs_v1`'));
      expect(content, contains('`w2_s09_position_initiative_texture_v1`'));
      expect(
        content,
        contains(
          '`lib/services/world2_hand_chain_mixed_subset_validator_v1.dart`',
        ),
      );
      expect(
        content,
        contains(
          '`test/tools/world2_hand_chain_mixed_subset_validator_v1_test.dart`',
        ),
      );
      expect(
        content,
        contains(
          '`test/ui_v2/session_drill_player_hand_chain_contract_test.dart`',
        ),
      );
    },
  );

  test(
    'representative factual hand-chain content satisfies the explicit lane contract',
    () {
      final positionInitiative = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json',
        ).readAsStringSync(),
      );
      final textureOuts = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json',
        ).readAsStringSync(),
      );

      expect(positionInitiative.kind, DrillKindV1.handChain);
      expect(
        positionInitiative.chainIdV1,
        'w2_s07_position_then_initiative_v1',
      );
      expect(positionInitiative.chainStepsV1, hasLength(2));
      expect(
        positionInitiative.chainStepsV1!.first.questionShapeV1,
        'in_position',
      );
      expect(
        positionInitiative.chainStepsV1!.first.feedbackCorrectV1,
        isNotNull,
      );
      expect(
        positionInitiative.chainStepsV1!.first.feedbackIncorrectV1,
        isNotNull,
      );

      expect(textureOuts.kind, DrillKindV1.handChain);
      expect(textureOuts.chainIdV1, 'w2_s08_texture_then_outs_v1');
      expect(textureOuts.chainStepsV1, hasLength(2));
      expect(textureOuts.chainStepsV1!.last.heroHoleCardsV1, hasLength(2));
      expect(textureOuts.chainStepsV1!.last.boardCardsV1, hasLength(3));
      expect(textureOuts.chainStepsV1!.last.availableActionsV1, const <String>[
        '4',
        '8',
        '9',
        '15',
      ]);

      final positionInitiativeTexture = DrillSpecV1.fromJsonString(
        File(
          'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json',
        ).readAsStringSync(),
      );
      expect(positionInitiativeTexture.kind, DrillKindV1.handChain);
      expect(
        positionInitiativeTexture.chainIdV1,
        'w2_s09_position_initiative_texture_v1',
      );
      expect(positionInitiativeTexture.chainStepsV1, hasLength(3));
      expect(positionInitiativeTexture.chainStepsV1!.first.playerCountV1, 4);
      expect(
        positionInitiativeTexture.chainStepsV1![1].initiativeOwnerV1,
        'hero',
      );
      expect(
        positionInitiativeTexture.chainStepsV1!.last.boardCardsV1,
        hasLength(3),
      );
    },
  );

  test(
    'current factual hand-chain lane remains validator-clean and explicitly bounded',
    () {
      final report = validateWorld2HandChainMixedSubsetDirectoryV1(
        'content/worlds/world2/v1/sessions',
      );

      expect(report.issues, isEmpty);
      expect(
        report.factualSubsetSources,
        unorderedEquals(<String>[
          'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json',
          'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json',
          'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json',
        ]),
      );
      expect(
        report.policyCoupledSources,
        isNot(
          contains(
            'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json',
          ),
        ),
      );
      expect(
        report.policyCoupledSources,
        isNot(
          contains(
            'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json',
          ),
        ),
      );
      expect(
        report.capstoneSources,
        isNot(
          contains(
            'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json',
          ),
        ),
      );
    },
  );
}
