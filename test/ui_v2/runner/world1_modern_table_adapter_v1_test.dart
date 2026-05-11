import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart'
    as scenario_fsm;
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_modern_table_adapter_v1.dart';

String _formatUnitsToBbDisplayV1(int units) {
  final negative = units < 0;
  final absUnits = units.abs();
  final whole = absUnits ~/ 2;
  final hasHalf = absUnits.isOdd;
  final bb = hasHalf ? '$whole.5' : '$whole';
  return negative ? '-$bb' : bb;
}

void main() {
  test(
    'world1 modern table adapter carries contribution math into embedded table semantics',
    () {
      final resolved = resolveWorld1ModernTableAdapterV1(
        World1ModernTableAdapterInputV1(
          seatIds: const <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
          heroSeatId: 'co',
          actingSeatId: 'co',
          selectedSeatId: null,
          foldedBySeatId: const <String, bool>{},
          committedBySeatId: const <String, int>{'btn': 2, 'sb': 1, 'bb': 2},
          pot: 5,
          currentBet: 2,
          actingSeatToCall: 2,
          lastAggressorSeatId: null,
          priceSettingActionKindV1: null,
          betOwnerSeatId: 'bb',
          currentStreet: scenario_fsm.Street.flop,
          visibleBoardCount: 3,
          heroCards: <CardModel>[
            CardModel(rank: 'A', suit: '♠'),
            CardModel(rank: 'T', suit: '♣'),
          ],
          boardCards: <CardModel>[
            CardModel(rank: 'A', suit: '♠'),
            CardModel(rank: '7', suit: '♦'),
            CardModel(rank: '2', suit: '♣'),
          ],
          promptLabel: 'Practice: Flop decision.',
          showsActingSeat: true,
        ),
      );

      expect(resolved.seatContributionAmountsV1, <int, int>{0: 2, 1: 1, 2: 2});
      expect(
        resolved.debugPotDisplayLabelV1,
        '${_formatUnitsToBbDisplayV1(5)} BB',
      );
      expect(
        resolved.debugScenePriceLabelV1,
        'TO CALL ${_formatUnitsToBbDisplayV1(2)} BB',
      );
      expect(resolved.debugPriceSetterSeatIndexV1, isNull);
      expect(resolved.debugPriceSetterCueLabelV1, isNull);
      expect(resolved.scenarioSpec.resolvedNodes.first.pot, 5);
      expect(resolved.debugScenePromptLabel, 'Practice: Flop decision.');
    },
  );

  test(
    'world1 modern table adapter resolves a real price setter without misclassifying blind posters',
    () {
      final resolved = resolveWorld1ModernTableAdapterV1(
        World1ModernTableAdapterInputV1(
          seatIds: const <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
          heroSeatId: 'co',
          actingSeatId: 'co',
          selectedSeatId: null,
          foldedBySeatId: const <String, bool>{},
          committedBySeatId: const <String, int>{
            'sb': 1,
            'bb': 2,
            'utg': 4,
            'hj': 4,
          },
          pot: 11,
          currentBet: 4,
          actingSeatToCall: 4,
          lastAggressorSeatId: 'utg',
          priceSettingActionKindV1: ActionKindV1.bet,
          betOwnerSeatId: 'utg',
          currentStreet: scenario_fsm.Street.turn,
          visibleBoardCount: 4,
          heroCards: <CardModel>[
            CardModel(rank: 'Q', suit: '♣'),
            CardModel(rank: 'J', suit: '♦'),
          ],
          boardCards: <CardModel>[
            CardModel(rank: 'Q', suit: '♠'),
            CardModel(rank: '8', suit: '♦'),
            CardModel(rank: '3', suit: '♦'),
            CardModel(rank: '2', suit: '♥'),
          ],
          promptLabel: 'Practice: Turn decision. Choose the best action.',
          showsActingSeat: true,
        ),
      );

      expect(
        resolved.debugPriceSetterSeatIndexV1,
        resolved.seatIndexForId('utg'),
      );
      expect(
        resolved.debugPriceSetterSeatIndexV1,
        isNot(resolved.seatIndexForId('sb')),
      );
      expect(
        resolved.debugPriceSetterSeatIndexV1,
        isNot(resolved.seatIndexForId('bb')),
      );
      expect(resolved.debugPriceSetterCueLabelV1, 'BET');
      expect(
        resolved.debugScenePriceLabelV1,
        'TO CALL ${_formatUnitsToBbDisplayV1(4)} BB',
      );
    },
  );

  test(
    'world1 modern table adapter maps preflop opening action to OPEN even when engine action kind is bet',
    () {
      final resolved = resolveWorld1ModernTableAdapterV1(
        World1ModernTableAdapterInputV1(
          seatIds: const <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
          heroSeatId: 'hj',
          actingSeatId: 'hj',
          selectedSeatId: null,
          foldedBySeatId: const <String, bool>{},
          committedBySeatId: const <String, int>{'sb': 1, 'bb': 2, 'utg': 5},
          pot: 8,
          currentBet: 5,
          actingSeatToCall: 3,
          lastAggressorSeatId: 'utg',
          priceSettingActionKindV1: ActionKindV1.bet,
          betOwnerSeatId: 'utg',
          currentStreet: scenario_fsm.Street.preflop,
          visibleBoardCount: 0,
          heroCards: <CardModel>[
            CardModel(rank: 'K', suit: '♠'),
            CardModel(rank: 'J', suit: '♠'),
          ],
          boardCards: const <CardModel>[],
          promptLabel: 'Practice: Preflop decision. Choose the best action.',
          showsActingSeat: true,
        ),
      );

      expect(
        resolved.debugPriceSetterSeatIndexV1,
        resolved.seatIndexForId('utg'),
      );
      expect(resolved.debugPriceSetterCueLabelV1, 'OPEN');
    },
  );

  test(
    'world1 modern table adapter maps preflop re-raises to RAISE cue copy',
    () {
      final resolved = resolveWorld1ModernTableAdapterV1(
        World1ModernTableAdapterInputV1(
          seatIds: const <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
          heroSeatId: 'hj',
          actingSeatId: 'hj',
          selectedSeatId: null,
          foldedBySeatId: const <String, bool>{},
          committedBySeatId: const <String, int>{
            'sb': 1,
            'bb': 2,
            'utg': 5,
            'hj': 8,
          },
          pot: 16,
          currentBet: 8,
          actingSeatToCall: 0,
          lastAggressorSeatId: 'hj',
          priceSettingActionKindV1: ActionKindV1.raise,
          betOwnerSeatId: 'hj',
          currentStreet: scenario_fsm.Street.preflop,
          visibleBoardCount: 0,
          heroCards: <CardModel>[
            CardModel(rank: 'K', suit: '♠'),
            CardModel(rank: 'J', suit: '♠'),
          ],
          boardCards: const <CardModel>[],
          promptLabel: 'Practice: Preflop decision. Choose the best action.',
          showsActingSeat: true,
        ),
      );

      expect(
        resolved.debugPriceSetterSeatIndexV1,
        resolved.seatIndexForId('hj'),
      );
      expect(resolved.debugPriceSetterCueLabelV1, 'RAISE');
    },
  );
}
