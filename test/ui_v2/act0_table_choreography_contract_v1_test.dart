import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

void main() {
  group('Act0 table choreography contract', () {
    test('projects the canonical W6 turn hand in source order', () {
      final table = _table(
        street: 'Turn',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: '7', suit: 'h'),
          Act0CardStateV1(rank: '2', suit: 's'),
          Act0CardStateV1(rank: '2', suit: 'd'),
        ],
        trail: const <String>[
          'BTN bets flop',
          'BB calls',
          'BB checks turn',
          'BTN acts',
        ],
      );

      final plan = act0TableChoreographyPlanForTableV1(table);

      expect(plan, isNotNull);
      expect(plan!.initialStreet, Act0TableChoreographyStreetV1.flop);
      expect(plan.finalStreet, Act0TableChoreographyStreetV1.turn);
      expect(
        plan.beats.map((beat) => beat.kind),
        orderedEquals(const <Act0TableChoreographyBeatKindV1>[
          Act0TableChoreographyBeatKindV1.actionFocus,
          Act0TableChoreographyBeatKindV1.commitmentMove,
          Act0TableChoreographyBeatKindV1.actionFocus,
          Act0TableChoreographyBeatKindV1.commitmentMove,
          Act0TableChoreographyBeatKindV1.commitmentsCollect,
          Act0TableChoreographyBeatKindV1.turnReveal,
          Act0TableChoreographyBeatKindV1.actionFocus,
          Act0TableChoreographyBeatKindV1.heroDecisionReady,
        ]),
      );
      expect(plan.beats[1].commitment!.amountLabel, isEmpty);
      expect(plan.beats[3].commitment!.amountLabel, isEmpty);
    });

    test('preserves exact source amount and never invents a missing amount', () {
      final table = _table(
        street: 'Flop',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: '7', suit: 'h'),
          Act0CardStateV1(rank: '2', suit: 's'),
        ],
        trail: const <String>[
          'BTN bets 3 BB flop',
          'BB calls',
          'BTN acts',
        ],
      );

      final plan = act0TableChoreographyPlanForTableV1(table)!;
      final commitments = plan.beats
          .where(
            (beat) =>
                beat.kind ==
                Act0TableChoreographyBeatKindV1.commitmentMove,
          )
          .toList(growable: false);

      expect(commitments, hasLength(2));
      expect(commitments[0].commitment!.amountLabel, '3 BB');
      expect(commitments[1].commitment!.amountLabel, isEmpty);
    });

    test('check has focus but no chip motion and fold recesses', () {
      final table = _table(
        street: 'Flop',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: '8', suit: 'h'),
          Act0CardStateV1(rank: '4', suit: 'd'),
        ],
        trail: const <String>[
          'BB checks flop',
          'CO folds',
          'BTN acts',
        ],
      );

      final plan = act0TableChoreographyPlanForTableV1(table)!;

      expect(
        plan.beats
            .where(
              (beat) =>
                  beat.kind ==
                  Act0TableChoreographyBeatKindV1.commitmentMove,
            )
            .isEmpty,
        isTrue,
      );
      expect(
        plan.beats.any(
          (beat) =>
              beat.kind == Act0TableChoreographyBeatKindV1.foldRecess &&
              beat.actorSeatId == 'co',
        ),
        isTrue,
      );
    });

    test('flop, turn and river reveals use board-owned card counts', () {
      final table = _table(
        street: 'River',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: '8', suit: 'h'),
          Act0CardStateV1(rank: '4', suit: 'd'),
          Act0CardStateV1(rank: 'J', suit: 'c'),
          Act0CardStateV1(rank: '2', suit: 's'),
        ],
        trail: const <String>[
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'Flop dealt',
          'BB checks',
          'Turn dealt',
          'BB checks',
          'River dealt',
          'BB checks',
          'BTN acts',
        ],
      );

      final plan = act0TableChoreographyPlanForTableV1(table)!;
      expect(
        plan.beats.map((beat) => beat.kind),
        containsAllInOrder(const <Act0TableChoreographyBeatKindV1>[
          Act0TableChoreographyBeatKindV1.flopReveal,
          Act0TableChoreographyBeatKindV1.turnReveal,
          Act0TableChoreographyBeatKindV1.riverReveal,
        ]),
      );

      final flopIndex = plan.beats.indexWhere(
        (beat) => beat.kind == Act0TableChoreographyBeatKindV1.flopReveal,
      );
      final turnIndex = plan.beats.indexWhere(
        (beat) => beat.kind == Act0TableChoreographyBeatKindV1.turnReveal,
      );
      final riverIndex = plan.beats.indexWhere(
        (beat) => beat.kind == Act0TableChoreographyBeatKindV1.riverReveal,
      );
      expect(
        act0TableChoreographyFrameAfterBeatV1(
          plan,
          flopIndex,
        ).visibleBoardCardCount,
        3,
      );
      expect(
        act0TableChoreographyFrameAfterBeatV1(
          plan,
          turnIndex,
        ).visibleBoardCardCount,
        4,
      );
      expect(
        act0TableChoreographyFrameAfterBeatV1(
          plan,
          riverIndex,
        ).visibleBoardCardCount,
        5,
      );
    });

    test('commitments persist until a source-proven street boundary', () {
      final plan = act0TableChoreographyPlanForTableV1(
        _table(
          street: 'Turn',
          board: const <Act0CardStateV1>[
            Act0CardStateV1(rank: 'K', suit: 'c'),
            Act0CardStateV1(rank: '7', suit: 'h'),
            Act0CardStateV1(rank: '2', suit: 's'),
            Act0CardStateV1(rank: '2', suit: 'd'),
          ],
          trail: const <String>[
            'BTN bets flop',
            'BB calls',
            'BB checks turn',
            'BTN acts',
          ],
        ),
      )!;

      final secondCommitment = plan.beats.indexWhere(
        (beat) =>
            beat.kind == Act0TableChoreographyBeatKindV1.commitmentMove &&
            beat.actorSeatId == 'bb',
      );
      final collect = plan.beats.indexWhere(
        (beat) =>
            beat.kind ==
            Act0TableChoreographyBeatKindV1.commitmentsCollect,
      );
      expect(
        act0TableChoreographyFrameAfterBeatV1(
          plan,
          secondCommitment,
        ).commitments.keys,
        containsAll(<String>['btn', 'bb']),
      );
      expect(
        act0TableChoreographyFrameAfterBeatV1(
          plan,
          collect,
        ).commitments,
        isEmpty,
      );
    });

    test('terminal frame restores the exact authored table object', () {
      final table = _table(
        street: 'Turn',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: '7', suit: 'h'),
          Act0CardStateV1(rank: '2', suit: 's'),
          Act0CardStateV1(rank: '2', suit: 'd'),
        ],
        trail: const <String>[
          'BTN bets flop',
          'BB calls',
          'BB checks turn',
          'BTN acts',
        ],
      );
      final plan = act0TableChoreographyPlanForTableV1(table)!;
      final terminal = act0TableChoreographyFrameAfterBeatV1(
        plan,
        plan.beats.length - 1,
      );

      expect(terminal.heroDecisionReady, isTrue);
      expect(act0TableForChoreographyFrameV1(table, terminal), same(table));
      expect(table.potLabel, 'Pot 11 BB');
    });

    test('malformed and unreconciled source history fails closed', () {
      final unknownCard = _table(
        street: 'Turn',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: '7', suit: 'h'),
          Act0CardStateV1(rank: '2', suit: 's'),
          Act0CardStateV1(rank: '?', suit: '?'),
        ],
        trail: const <String>['BB checks turn', 'BTN acts'],
      );
      final skippedStreet = _table(
        street: 'River',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: '7', suit: 'h'),
          Act0CardStateV1(rank: '2', suit: 's'),
          Act0CardStateV1(rank: 'J', suit: 'd'),
          Act0CardStateV1(rank: '4', suit: 'c'),
        ],
        trail: const <String>[
          'BTN bets flop',
          'BB checks river',
          'BTN acts',
        ],
      );
      final proseCards = _table(
        street: 'Turn',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: '7', suit: 'h'),
          Act0CardStateV1(rank: '2', suit: 's'),
          Act0CardStateV1(rank: '2', suit: 'd'),
        ],
        trail: const <String>[
          'BTN bets flop',
          'Turn: red 2 pairs board',
          'BTN acts',
        ],
      );

      expect(act0TableChoreographyPlanForTableV1(unknownCard), isNull);
      expect(act0TableChoreographyPlanForTableV1(skippedStreet), isNull);
      expect(act0TableChoreographyPlanForTableV1(proseCards), isNull);
    });

    test('actor-focus answer-risk suppresses choreography', () {
      final table = _table(
        street: 'Flop',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: '8', suit: 'h'),
          Act0CardStateV1(rank: '4', suit: 'd'),
        ],
        trail: const <String>['BB checks flop', 'BTN acts'],
      );

      expect(
        act0TableChoreographyPlanForTableV1(
          table,
          actorFocusSafe: false,
        ),
        isNull,
      );
    });
  });
}

Act0TableStateV1 _table({
  required String street,
  required List<Act0CardStateV1> board,
  required List<String> trail,
}) {
  return Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: const <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
      ),
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'UTG',
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'HJ',
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'CO',
      ),
    ],
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'Q', suit: 'd'),
    ],
    boardCards: board,
    streetLabel: street,
    potLabel: 'Pot 11 BB',
    toCallLabel: '',
    centerLabel: 'Decision',
    actionTrail: trail
        .map((label) => Act0ActionTrailItemV1(label: label))
        .toList(growable: false),
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: const <String>['btn', 'bb'],
    highlightedCardIds: const <String>[],
  );
}
