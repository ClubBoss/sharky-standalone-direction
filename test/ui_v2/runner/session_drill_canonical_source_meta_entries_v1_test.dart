import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_hand_chain_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_outs_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_seat_context_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_source_meta_entries_v1.dart';

void main() {
  test(
    'session drill canonical source meta entries resolve position family shape',
    () {
      final entries = buildSessionDrillCanonicalSourceMetaEntriesV1(
        const SessionDrillCanonicalSourceMetaInputV1(
          family: FactualRunnerHostFamilyV1.position,
          street: 'FLOP',
          playerCount: 6,
          heroLabel: 'BTN',
          villainLabel: 'BB',
          activeSeats: <String>['BTN', 'SB', 'BB'],
          foldedSeats: <String>['CO'],
          emptySeats: <String>['UTG'],
        ),
      );

      expect(entries.length, 7);
      expect(
        entries.first.testKey,
        'session_drill_player_position_source_street_v1',
      );
      expect(entries.first.text, 'Street: FLOP');
      expect(entries[2].text, 'Hero: BTN');
      expect(entries[4].text, 'Active: BTN, SB, BB');
    },
  );

  test(
    'session drill canonical source meta entries resolve hand-chain sparse shape',
    () {
      final entries = buildSessionDrillCanonicalSourceMetaEntriesV1(
        const SessionDrillCanonicalSourceMetaInputV1(
          family: FactualRunnerHostFamilyV1.factualHandChain,
          street: 'TURN',
          heroLabel: 'Ah Kh',
          boardCards: <String>['Qs', 'Jh', '2c', 'Td'],
        ),
      );

      expect(entries.length, 3);
      expect(
        entries.map((entry) => entry.testKey).toList(growable: false),
        <String>[
          'session_drill_player_hand_chain_source_street_v1',
          'session_drill_player_hand_chain_source_hero_v1',
          'session_drill_player_hand_chain_source_board_v1',
        ],
      );
    },
  );

  test(
    'session drill canonical source meta entries keep preflop hand-chain street visible without board leakage',
    () {
      final entries = buildSessionDrillCanonicalSourceMetaEntriesV1(
        const SessionDrillCanonicalSourceMetaInputV1(
          family: FactualRunnerHostFamilyV1.factualHandChain,
          street: 'PREFLOP',
          heroLabel: 'QQ',
        ),
      );

      expect(entries.length, 2);
      expect(entries.first.testKey, 'session_drill_player_hand_chain_source_street_v1');
      expect(entries.first.text, 'Street: PREFLOP');
      expect(entries[1].testKey, 'session_drill_player_hand_chain_source_hero_v1');
      expect(
        entries.any(
          (entry) => entry.testKey == 'session_drill_player_hand_chain_source_board_v1',
        ),
        isFalse,
      );
    },
  );

  test(
    'session drill canonical source meta input accepts canonical resolved outs state',
    () {
      final input = buildSessionDrillCanonicalSourceMetaInputForFamilyV1(
        family: FactualRunnerHostFamilyV1.outs,
        resolvedOutsStateV1: resolveSessionDrillCanonicalOutsScenarioStateV1(
          const DrillSpecV1(
            id: 'count_flush_draw_nine_outs',
            kind: DrillKindV1.outsCountChoice,
            prompt: 'Count the outs for the flush draw.',
            expected: DrillExpectedV1(actionId: '9'),
            errorClass: 'outs_error',
            streetV1: 'turn',
            boardCardsV1: <String>['Ah', '7h', '2c', 'Td'],
            heroHoleCardsV1: <String>['Kh', 'Qh'],
            availableActionsV1: <String>['4', '8', '9', '15'],
            expectedActionV1: '9',
          ),
        ),
      );

      expect(input.street, 'TURN');
      expect(input.heroLabel, 'Kh Qh');
      expect(input.boardCards, <String>['Ah', '7h', '2c', 'Td']);
    },
  );

  test(
    'session drill canonical source meta input normalizes initiative family facts',
    () {
      final input = buildSessionDrillCanonicalSourceMetaInputForFamilyV1(
        family: FactualRunnerHostFamilyV1.initiative,
        resolvedSeatContextStateV1:
            resolveSessionDrillCanonicalSeatContextScenarioStateV1(
              const DrillSpecV1(
                id: 'initiative_drill',
                kind: DrillKindV1.initiativeAggressorChoice,
                prompt: 'Prompt',
                expected: DrillExpectedV1(actionId: 'bet'),
                errorClass: 'initiative_error',
                streetV1: 'turn',
                playerCountV1: 3,
                heroSeatV1: 'btn',
                villainSeatV1: 'bb',
                activeSeatsV1: <String>['btn', 'bb', 'sb'],
                lastAggressorV1: 'hero',
                initiativeOwnerV1: 'villain',
                availableActionsV1: <String>['bet', 'check'],
                expectedActionV1: 'bet',
              ),
            ),
      );

      expect(input.street, 'TURN');
      expect(input.heroLabel, 'BTN');
      expect(input.villainLabel, 'BB');
      expect(input.activeSeats, <String>['BTN', 'BB', 'SB']);
      expect(input.lastAggressor, 'HERO');
      expect(input.initiativeOwner, 'VILLAIN');
    },
  );

  test(
    'session drill canonical source meta input accepts canonical resolved position seat state',
    () {
      final input = buildSessionDrillCanonicalSourceMetaInputForFamilyV1(
        family: FactualRunnerHostFamilyV1.position,
        resolvedSeatContextStateV1:
            resolveSessionDrillCanonicalSeatContextScenarioStateV1(
              const DrillSpecV1(
                id: 'position_drill',
                kind: DrillKindV1.positionThinkingChoice,
                prompt: 'Prompt',
                expected: DrillExpectedV1(actionId: 'hero'),
                errorClass: 'position_error',
                streetV1: 'flop',
                playerCountV1: 6,
                heroSeatV1: 'btn',
                villainSeatV1: 'bb',
                activeSeatsV1: <String>['btn', 'sb', 'bb'],
                foldedSeatsV1: <String>['co'],
                emptySeatsV1: <String>['utg'],
                availableActionsV1: <String>['hero', 'villain'],
                expectedActionV1: 'hero',
              ),
            ),
      );

      expect(input.street, 'FLOP');
      expect(input.heroLabel, 'BTN');
      expect(input.villainLabel, 'BB');
      expect(input.activeSeats, <String>['BTN', 'SB', 'BB']);
      expect(input.foldedSeats, <String>['CO']);
      expect(input.emptySeats, <String>['UTG']);
    },
  );

  test(
    'session drill canonical source meta input accepts canonical resolved texture state',
    () {
      final input = buildSessionDrillCanonicalSourceMetaInputForFamilyV1(
        family: FactualRunnerHostFamilyV1.texture,
        resolvedTextureStateV1:
            resolveSessionDrillCanonicalBoardTextureScenarioStateV1(
              sessionId: 'w5.s04',
              spec: const DrillSpecV1(
                id: 'classify_texture_turn_connected_v1',
                kind: DrillKindV1.boardTextureClassifier,
                prompt:
                    'The turn keeps this connected. Classify the board texture.',
                expected: DrillExpectedV1(actionId: 'connected'),
                errorClass: 'board_texture_mismatch',
                boardTextureV1: 'connected',
              ),
            ),
      );

      expect(input.street, 'TURN');
      expect(input.boardCards, <String>['Js', 'Td', '9c', '8h']);
    },
  );

  test(
    'session drill canonical source meta input accepts canonical resolved hand-chain state',
    () {
      final input = buildSessionDrillCanonicalSourceMetaInputForFamilyV1(
        family: FactualRunnerHostFamilyV1.factualHandChain,
        resolvedHandChainStateV1:
            resolveSessionDrillCanonicalHandChainScenarioStateV1(
              factualStepV1: const DrillScenarioHandChainStepContextV1(
                coreV1: DrillScenarioCoreV1(
                  introV1: 'Prompt',
                  streetV1: 'river',
                ),
                tableContextV1: DrillScenarioTableContextV1(
                  boardContextV1: DrillScenarioBoardContextV1(
                    heroHoleCardsV1: <String>['Ah', 'Kh'],
                    boardCardsV1: <String>['Qs', 'Jh', '2c', 'Td', '9d'],
                  ),
                ),
              ),
            ),
      );

      expect(input.street, 'RIVER');
      expect(input.heroLabel, 'Ah Kh');
      expect(input.boardCards, <String>['Qs', 'Jh', '2c', 'Td', '9d']);
    },
  );
}
