import 'dart:convert';

import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import '../support/act0_table_truth_v1.dart';
import 'act0_b132_origin_choreography_reference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

void main() {
  test('W1–W12 plans are byte-identical to origin/main', () {
    final worlds = Act0ShellStateV1.authoredCatalog.worlds.where(
      (w) => w.worldNumber <= 12,
    );
    for (final world in worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          final runner = task.runner;
          final tables = [
            runner.table,
            for (final step in runner.teachingSteps) ...[
              step.table ?? runner.table,
              act0TeachingTableForRunnerV1(runner.table, step),
            ],
            for (final option in runner.options)
              act0FeedbackTableForRunnerV1(
                runner: runner.copyWith(
                  phase: Act0LessonPhaseV1.review,
                  selectedOptionId: option.id,
                  teachingStepIndex: runner.teachingSteps.length,
                ),
                taskFamily: task.resolvedTaskFamily,
              ),
            act0FeedbackTableForRunnerV1(
              runner: runner.copyWith(phase: Act0LessonPhaseV1.review),
              taskFamily: task.resolvedTaskFamily,
            ),
          ];
          for (final table in tables) {
            final before = originChoreographyPlanV1(table);
            final after = act0TableChoreographyPlanForTableV1(table);
            expect(_planBytes(after), _planBytes(before), reason: task.taskId);
            expect(after?.verifiedHistory, isNull, reason: task.taskId);
          }
        }
      }
    }
  });
  for (final (token, sourceIndex, kind, total, delta) in [
    ('posts', 0, Act0SeatBetKindV1.post, '0.5 BB', 0.5),
    ('raises to', 6, Act0SeatBetKindV1.raise, '9 BB', 8.5),
    ('calls more', 8, Act0SeatBetKindV1.call, '9 BB', 6.0),
  ]) {
    test('six-max $token preserves exact street total and contribution', () {
      final plan = act0TableChoreographyPlanForTableV1(_ledgerTable())!;
      final beat = plan.beats.singleWhere(
        (beat) => beat.sourceIndex == sourceIndex && beat.commitment != null,
      );
      expect(beat.commitment!.kind, kind);
      expect(beat.commitment!.amountLabel, total);
      expect(beat.contribution!.amountBb, delta);
    });
  }
  test(
    'preflop prefix establishes the first street without guessing the board',
    () {
      final plan = act0TableChoreographyPlanForTableV1(_ledgerTable())!;
      expect(plan.initialStreet, Act0TableChoreographyStreetV1.preflop);
      expect(plan.initialBoardCardCount, 0);
    },
  );
  test(
    'six-max preflop prefix, posts, raises to, calls more replay and conserve chips',
    () {
      final table = _ledgerTable();
      final plan = act0TableChoreographyPlanForTableV1(table)!;
      expect(plan.initialStreet, Act0TableChoreographyStreetV1.preflop);
      expect(plan.verifiedHistory!.decisionError('btn'), isNull);
      final commits = plan.beats
          .where((beat) => beat.commitment != null)
          .toList();
      expect(commits.map((beat) => beat.commitment!.kind), [
        Act0SeatBetKindV1.post,
        Act0SeatBetKindV1.post,
        Act0SeatBetKindV1.raise,
        Act0SeatBetKindV1.raise,
        Act0SeatBetKindV1.call,
      ]);
      expect(commits.map((beat) => beat.commitment!.amountLabel), [
        '0.5 BB',
        '1 BB',
        '3 BB',
        '9 BB',
        '9 BB',
      ]);
      expect(commits.map((beat) => beat.contribution!.amountBb), [
        0.5,
        1,
        3,
        8.5,
        6,
      ]);
      final collect = plan.beats.indexWhere(
        (beat) =>
            beat.kind == Act0TableChoreographyBeatKindV1.commitmentsCollect,
      );
      final before = act0TableChoreographyFrameAfterBeatV1(plan, collect - 1);
      final after = act0TableChoreographyFrameAfterBeatV1(plan, collect + 1);
      expect(before.commitments['btn']!.amountLabel, '9 BB');
      expect(after.commitments, isEmpty);
      for (final frame in [before, after]) {
        final projected = act0TableForChoreographyFrameV1(table, frame);
        expect(projected.potLabel, 'Pot 19 BB');
        expect(projected.handContributions!.entries.map((e) => e.amountBb), [
          0.5,
          1,
          3,
          8.5,
          6,
        ]);
      }
      expect(
        act0TableForChoreographyFrameV1(
          table,
          act0TableChoreographyFrameAfterBeatV1(plan, plan.beats.length - 1),
        ),
        same(table),
      );
    },
  );
  test(
    'new grammar fails closed on unknown tokens, inconsistent chips or illegal turns',
    () {
      final table = _ledgerTable();
      for (final replacement in [
        'preflop: SB raises about 9 BB',
        'preflop: SB raises to 8 BB',
        'preflop: SB raises to 9 BB extra',
      ]) {
        final trail = [...table.actionTrail];
        trail[6] = Act0ActionTrailItemV1(label: replacement);
        expect(
          act0TableChoreographyPlanForTableV1(
            table.copyWith(
              actionTrail: trail,
              handContributions: table.handContributions,
            ),
          ),
          isNull,
          reason: replacement,
        );
      }
      final trail = [...table.actionTrail];
      final fold = trail[2];
      trail[2] = trail[3];
      trail[3] = fold;
      expect(
        act0TableChoreographyPlanForTableV1(
          table.copyWith(
            actionTrail: trail,
            handContributions: table.handContributions,
          ),
        ),
        isNull,
      );
    },
  );
  test(
    'a plain call total and an explicit additional call have identical commitments',
    () {
      final source = _ledgerTable();
      final total = [...source.actionTrail];
      total[8] = const Act0ActionTrailItemV1(label: 'preflop: BTN calls 9 BB');
      expect(
        _planBytes(
          act0TableChoreographyPlanForTableV1(
            source.copyWith(
              actionTrail: total,
              handContributions: source.handContributions,
            ),
          ),
        ),
        _planBytes(act0TableChoreographyPlanForTableV1(source)),
      );
    },
  );
  test('explicit all-in suffix must exhaust the source stack', () {
    final table = _ledgerTable();
    final trail = table.actionTrail.take(8).toList();
    trail[6] = const Act0ActionTrailItemV1(
      label: 'preflop: SB raises to 9 BB (all-in)',
    );
    final ledger = table.handContributions!;
    Act0TableStateV1 withStack(double stack) => table.copyWith(
      streetLabel: 'Preflop',
      boardCards: const [],
      actionTrail: trail,
      handContributions: Act0HandContributionsV1(
        throughStreet: PokerStreet.preflop,
        startingStackBbBySeat: {...ledger.startingStackBbBySeat, 'sb': stack},
        entries: ledger.entries.take(4).toList(),
      ),
    );
    final plan = act0TableChoreographyPlanForTableV1(withStack(9));
    expect(plan, isNotNull);
    expect(
      plan!.beats.lastWhere((beat) => beat.commitment != null).commitment!.kind,
      Act0SeatBetKindV1.allIn,
    );
    expect(act0TableChoreographyPlanForTableV1(withStack(100)), isNull);
  });
  test('D6 requires a legal complete six-max replay, not merely grammar', () {
    final source = _ledgerTable();
    final timeline = act0TableChoreographyPlanForTableV1(
      source,
    )!.verifiedHistory!;
    final world = Act0ShellStateV1.authoredCatalog.worldById('world_8');
    final lesson = world.lessons.first;
    final task = lesson.taskList.first;
    String status(Act0TableStateV1 table) => auditTableTruth(
      worlds: [
        world.copyWith(
          lessons: [
            lesson.copyWith(
              tasks: [
                Act0LessonTaskV1(
                  taskId: task.taskId,
                  title: task.title,
                  phase: task.phase,
                  rewardXp: task.rewardXp,
                  runner: task.runner.copyWith(table: table),
                ),
              ],
            ),
          ],
        ),
      ],
    ).singleWhere((row) => row.invariant == 'D6.history_support').result;
    expect(status(source), 'PASS');
    expect(status(source.copyWith(handTimelinePrefix: timeline)), 'PASS');
    expect(
      status(
        source.copyWith(handTimelinePrefix: timeline, decisionSeatId: 'sb'),
      ),
      'FAIL',
    );
    expect(
      status(
        source.copyWith(
          actionTrail: const [Act0ActionTrailItemV1(label: 'unknown')],
          handContributions: source.handContributions,
        ),
      ),
      'NEEDS_SOURCE_CONTEXT',
    );
  });

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

    test(
      'preserves exact source amount and never invents a missing amount',
      () {
        final table = _table(
          street: 'Flop',
          board: const <Act0CardStateV1>[
            Act0CardStateV1(rank: 'K', suit: 'c'),
            Act0CardStateV1(rank: '7', suit: 'h'),
            Act0CardStateV1(rank: '2', suit: 's'),
          ],
          trail: const <String>['BTN bets 3 BB flop', 'BB calls', 'BTN acts'],
        );

        final plan = act0TableChoreographyPlanForTableV1(table)!;
        final commitments = plan.beats
            .where(
              (beat) =>
                  beat.kind == Act0TableChoreographyBeatKindV1.commitmentMove,
            )
            .toList(growable: false);

        expect(commitments, hasLength(2));
        expect(commitments[0].commitment!.amountLabel, '3 BB');
        expect(commitments[1].commitment!.amountLabel, isEmpty);
      },
    );

    test('check has focus but no chip motion and fold recesses', () {
      final table = _table(
        street: 'Flop',
        board: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: '8', suit: 'h'),
          Act0CardStateV1(rank: '4', suit: 'd'),
        ],
        trail: const <String>['BB checks flop', 'CO folds', 'BTN acts'],
      );

      final plan = act0TableChoreographyPlanForTableV1(table)!;

      expect(
        plan.beats
            .where(
              (beat) =>
                  beat.kind == Act0TableChoreographyBeatKindV1.commitmentMove,
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
            beat.kind == Act0TableChoreographyBeatKindV1.commitmentsCollect,
      );
      expect(
        act0TableChoreographyFrameAfterBeatV1(
          plan,
          secondCommitment,
        ).commitments.keys,
        containsAll(<String>['btn', 'bb']),
      );
      expect(
        act0TableChoreographyFrameAfterBeatV1(plan, collect).commitments,
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
        trail: const <String>['BTN bets flop', 'BB checks river', 'BTN acts'],
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
        act0TableChoreographyPlanForTableV1(table, actorFocusSafe: false),
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
    scope: Act0TableScopeV1.playedHand,
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
      Act0SeatStateV1(seatId: 'bb', seatLabel: 'BB', displayName: 'Big blind'),
      Act0SeatStateV1(seatId: 'utg', seatLabel: 'UTG', displayName: 'UTG'),
      Act0SeatStateV1(seatId: 'hj', seatLabel: 'HJ', displayName: 'HJ'),
      Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'CO'),
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

String _planBytes(Act0TableChoreographyPlanV1? plan) => jsonEncode(
  plan == null
      ? null
      : [
          plan.initialStreet.name,
          plan.finalStreet.name,
          plan.heroSeatId,
          [
            for (final beat in plan.beats)
              [
                beat.kind.name,
                beat.street.name,
                beat.actorSeatId,
                beat.actorLabel,
                beat.sourceIndex,
                beat.commitment?.kind.name,
                beat.commitment?.label,
                beat.commitment?.amountLabel,
                beat.contribution?.amountBb,
              ],
          ],
        ],
);

Act0TableStateV1 _ledgerTable() {
  final table = _table(
    street: 'Flop',
    board: const [
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: '7', suit: 'h'),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
    trail: const [
      'preflop: SB posts 0.5 BB',
      'preflop: BB posts 1 BB',
      'preflop: UTG folds',
      'preflop: HJ folds',
      'preflop: CO folds',
      'preflop: BTN raises to 3 BB',
      'preflop: SB raises to 9 BB',
      'preflop: BB folds',
      'preflop: BTN calls 6 BB more',
      'flop: SB checks',
    ],
  );
  return table.copyWith(
    seats: [
      for (final seat in table.seats)
        Act0SeatStateV1(
          seatId: seat.seatId,
          seatLabel: seat.seatLabel,
          displayName: seat.displayName,
          isHero: seat.isHero,
          isDealerButton: seat.seatId == 'btn',
          isSmallBlind: seat.seatId == 'sb',
          isBigBlind: seat.seatId == 'bb',
          isFolded: !['btn', 'sb'].contains(seat.seatId),
          isInHand: ['btn', 'sb'].contains(seat.seatId),
          isActive: seat.isHero,
          holeCards: seat.isHero ? table.heroCards : const [],
        ),
    ],
    decisionSeatId: 'btn',
    potLabel: 'Pot 19 BB',
    handContributions: const Act0HandContributionsV1(
      throughStreet: PokerStreet.flop,
      startingStackBbBySeat: {
        'utg': 100,
        'hj': 100,
        'co': 100,
        'btn': 100,
        'sb': 100,
        'bb': 100,
      },
      entries: [
        Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.blind,
          0.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.blind,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          3,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.wager,
          8.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          6,
        ),
      ],
    ),
  );
}
