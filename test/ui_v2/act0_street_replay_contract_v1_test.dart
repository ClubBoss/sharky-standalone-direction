import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

void main() {
  const multiStreetTable = Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 2,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        stackLabel: '40 BB',
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
        ],
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        stackLabel: '40 BB',
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: '?', suit: ''),
          Act0CardStateV1(rank: '?', suit: ''),
        ],
        cardsVisibleMode: Act0CardsVisibleModeV1.faceDown,
      ),
    ],
    heroCards: <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
    ],
    boardCards: <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: 'J', suit: 'c'),
      Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '9', suit: 'c'),
    ],
    streetLabel: 'River',
    potLabel: 'Pot 12 BB',
    toCallLabel: 'To call 4 BB',
    centerLabel: 'Facing river shove',
    focusCalloutLabel: 'Board completes the flush.',
    actionTrail: <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
      Act0ActionTrailItemV1(label: 'Flop: BB checks'),
      Act0ActionTrailItemV1(label: 'BTN bets 2 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 2 BB'),
      Act0ActionTrailItemV1(label: 'Turn: BB checks'),
      Act0ActionTrailItemV1(label: 'BTN checks'),
      Act0ActionTrailItemV1(label: 'River: BB shoves 4 BB'),
    ],
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: <String>['btn'],
    highlightedCardIds: <String>['board_4'],
  );

  test(
    'builds deterministic street steps from action trail and table state',
    () {
      final replay = act0StreetReplayFromTableV1(multiStreetTable);

      expect(replay, isNotNull);
      expect(replay!.completeness, Act0StreetReplayCompletenessV1.complete);
      expect(replay.heroPosition, 'BTN');
      expect(replay.opponentPosition, 'BB');
      expect(replay.effectiveStackBb, '40 BB');
      expect(replay.currentDecisionActor, 'Hero');
      expect(replay.currentDecisionSummaryKey, 'Facing river shove');
      expect(replay.sourceRefs, <String>[
        'streetLabel',
        'actionTrail',
        'activeSeatId',
        'heroSeatId',
      ]);
      expect(
        replay.steps.map((step) => step.street).toList(growable: false),
        <Act0StreetReplayStreetV1>[
          Act0StreetReplayStreetV1.preflop,
          Act0StreetReplayStreetV1.preflop,
          Act0StreetReplayStreetV1.preflop,
          Act0StreetReplayStreetV1.preflop,
          Act0StreetReplayStreetV1.flop,
          Act0StreetReplayStreetV1.flop,
          Act0StreetReplayStreetV1.flop,
          Act0StreetReplayStreetV1.turn,
          Act0StreetReplayStreetV1.turn,
          Act0StreetReplayStreetV1.river,
        ],
      );
      expect(replay.currentStreet, Act0StreetReplayStreetV1.river);
      expect(replay.steps.last.isCurrentStreet, isTrue);
      expect(replay.steps.last.youAreHereLabel, 'You are here');
      expect(replay.steps.last.actorLabel, 'BB');
      expect(replay.steps.last.actionTypeLabel, 'shoves');
      expect(replay.steps.last.amountLabel, '4 BB');
      expect(replay.steps.last.order, 9);
      expect(replay.steps.last.boardCardsAtStreet, <String>[
        'Kc',
        'Qh',
        'Jc',
        '2d',
        '9c',
      ]);
      expect(replay.steps.last.actionSummary, 'BB shoves 4 BB');
      expect(
        replay.decisionContext,
        'Facing river shove. Pot 12 BB. To call 4 BB.',
      );
      expect(replay.keyClue, 'Board completes the flush.');
    },
  );

  test('caps board cards by street to avoid future information leakage', () {
    final replay = act0StreetReplayFromTableV1(multiStreetTable);

    expect(replay, isNotNull);
    final stepsByStreet =
        <Act0StreetReplayStreetV1, List<Act0StreetReplayStepV1>>{};
    for (final step in replay!.steps) {
      stepsByStreet
          .putIfAbsent(step.street, () => <Act0StreetReplayStepV1>[])
          .add(step);
    }

    expect(
      stepsByStreet[Act0StreetReplayStreetV1.preflop]!.map(
        (step) => step.boardCardsAtStreet,
      ),
      everyElement(isEmpty),
    );
    expect(
      stepsByStreet[Act0StreetReplayStreetV1.flop]!.map(
        (step) => step.boardCardsAtStreet,
      ),
      everyElement(<String>['Kc', 'Qh', 'Jc']),
    );
    expect(
      stepsByStreet[Act0StreetReplayStreetV1.turn]!.map(
        (step) => step.boardCardsAtStreet,
      ),
      everyElement(<String>['Kc', 'Qh', 'Jc', '2d']),
    );
    expect(
      stepsByStreet[Act0StreetReplayStreetV1.river]!.map(
        (step) => step.boardCardsAtStreet,
      ),
      everyElement(<String>['Kc', 'Qh', 'Jc', '2d', '9c']),
    );
  });

  test('fails closed when actor truth is missing from an action step', () {
    final replay = act0StreetReplayFromTableV1(
      multiStreetTable.copyWith(
        actionTrail: const <Act0ActionTrailItemV1>[
          Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
          Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
          Act0ActionTrailItemV1(label: 'raises 3 BB'),
        ],
      ),
    );

    expect(replay, isNotNull);
    expect(replay!.completeness, Act0StreetReplayCompletenessV1.insufficient);
    expect(replay.steps, isEmpty);
  });

  test('does not create replay without source-owned street context', () {
    final replay = act0StreetReplayFromTableV1(
      multiStreetTable.copyWith(
        streetLabel: '',
        centerLabel: '',
        actionTrail: const <Act0ActionTrailItemV1>[],
      ),
    );

    expect(replay, isNull);
  });

  test(
    'rejects reverse street chronology rather than repainting past state',
    () {
      final replay = act0StreetReplayFromTableV1(
        multiStreetTable.copyWith(
          actionTrail: const <Act0ActionTrailItemV1>[
            Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
            Act0ActionTrailItemV1(label: 'Flop: BB checks'),
            Act0ActionTrailItemV1(label: 'Turn: BTN bets 4 BB'),
            Act0ActionTrailItemV1(label: 'Flop: BB calls 4 BB'),
          ],
        ),
      );
      expect(replay, isNotNull);
      expect(replay!.isConsumerSafe, isFalse);
      expect(replay.completeness, Act0StreetReplayCompletenessV1.insufficient);
      expect(replay.steps, isEmpty);
    },
  );

  test(
    'rejects trail entries from a future street beyond current decision',
    () {
      final replay = act0StreetReplayFromTableV1(
        multiStreetTable.copyWith(
          streetLabel: 'Turn',
          actionTrail: const <Act0ActionTrailItemV1>[
            Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
            Act0ActionTrailItemV1(label: 'Flop: BB checks'),
            Act0ActionTrailItemV1(label: 'Turn: BTN bets 4 BB'),
            Act0ActionTrailItemV1(label: 'River: BTN bets 6 BB'),
          ],
        ),
      );
      expect(replay, isNotNull);
      expect(replay!.isConsumerSafe, isFalse);
      expect(replay.steps, isEmpty);
    },
  );

  test('rejects a seat acting again after its source trail fold', () {
    final replay = act0StreetReplayFromTableV1(
      multiStreetTable.copyWith(
        actionTrail: const <Act0ActionTrailItemV1>[
          Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
          Act0ActionTrailItemV1(label: 'BB folds'),
          Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        ],
      ),
    );
    expect(replay, isNotNull);
    expect(replay!.isConsumerSafe, isFalse);
    expect(replay.steps, isEmpty);
  });

  test('catalog replay source census is explicitly scoped, not 367 proof', () {
    var withTrail = 0;
    var consumerSafe = 0;
    var suppressed = 0;
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          if (task.runner.table.actionTrail.isEmpty) continue;
          withTrail++;
          final replay = act0StreetReplayFromTableV1(task.runner.table);
          if (replay?.isConsumerSafe == true) {
            consumerSafe++;
          } else {
            suppressed++;
          }
        }
      }
    }
    print(
      'PKR03_AUTHORED_SOURCE_TRAILS=$withTrail '
      'CONSUMER_SAFE=$consumerSafe SUPPRESSED=$suppressed',
    );
    expect(withTrail, greaterThan(0));
    // A known safe history is only replay evidence, not a complete legal
    // poker hand or proof of all 367 graded tasks.
    expect(consumerSafe + suppressed, withTrail);
  });
}
