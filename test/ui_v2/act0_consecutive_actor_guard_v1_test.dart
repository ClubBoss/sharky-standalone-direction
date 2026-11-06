// Reuses the executed PKR03 synthetic oracle fixture and nine witness bodies.
// Base: ac70160d48f116988da22fffe496453d888f11f2. No catalog facts are added.
// Ordinary NLHE acting-in-turn constraint: https://www.pokertda.com/view-poker-tda-rules/ rule52.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

const _preflop = <String>[
  'SB blind 0.5 BB',
  'BB blind 1 BB',
  'UTG folds',
  'HJ folds',
  'CO folds',
  'BTN raises 3 BB',
  'SB folds',
  'BB calls 3 BB',
];

const _heroCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'd'),
];

const _board = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd'),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 's'),
];

const _hidden = <Act0CardStateV1>[
  Act0CardStateV1(rank: '?', suit: ''),
  Act0CardStateV1(rank: '?', suit: ''),
];

Act0TableStateV1 _syntheticTable(
  List<String> trail, {
  String street = 'Flop',
  String actor = 'btn',
  Set<String> live = const <String>{'btn', 'bb'},
  String pot = 'Pot 6.5 BB',
}) {
  final boardCount = <String, int>{
    'Preflop': 0,
    'Flop': 3,
    'Turn': 4,
    'River': 5,
  }[street]!;
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      for (final label in const <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'])
        Act0SeatStateV1(
          seatId: label.toLowerCase(),
          seatLabel: label,
          displayName: label == 'BTN' ? 'Hero' : label,
          isHero: label == 'BTN',
          isDealerButton: label == 'BTN',
          isSmallBlind: label == 'SB',
          isBigBlind: label == 'BB',
          isInHand: live.contains(label.toLowerCase()),
          isFolded: !live.contains(label.toLowerCase()),
          isActive: actor == label.toLowerCase(),
          stackLabel: '100 BB',
          holeCards: label == 'BTN' ? _heroCards : _hidden,
          cardsVisibleMode: label == 'BTN'
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        ),
    ],
    heroCards: _heroCards,
    boardCards: _board.take(boardCount).toList(growable: false),
    streetLabel: street,
    potLabel: pot,
    toCallLabel: '',
    centerLabel: 'Independent synthetic PKR03 probe',
    actionTrail: <Act0ActionTrailItemV1>[
      for (final label in trail) Act0ActionTrailItemV1(label: label),
    ],
    activeSeatId: actor,
    heroSeatId: 'btn',
    highlightedSeatIds: const <String>[],
    highlightedCardIds: const <String>[],
  );
}

Act0LessonTaskV1 _authoredTask(String id) => <Act0LessonTaskV1>[
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons) ...lesson.taskList,
].singleWhere((task) => task.taskId == id);

void _expectUnsafe(Act0TableStateV1 table, String reason) {
  final replay = act0StreetReplayFromTableV1(table);
  expect(replay?.isConsumerSafe ?? false, isFalse, reason: reason);
}

void main() {
  test('legal heads-up survivors: BB checks, BTN may act', () {
    final table = _syntheticTable(<String>[..._preflop, 'Flop: BB checks']);
    final replay = act0StreetReplayFromTableV1(table);
    expect(replay, isNotNull);
    expect(replay!.isConsumerSafe, isTrue);
    expect(replay.steps.last.actorLabel, 'BB');
    expect(replay.currentDecisionActor, 'Hero');
    expect(act0TableChoreographyPlanForTableV1(table), isNotNull);
  });

  test('checked-through flop permits the next turn round', () {
    final table = _syntheticTable(<String>[
      ..._preflop,
      'Flop: BB checks',
      'BTN checks',
      'Turn: BB checks',
    ], street: 'Turn');
    final replay = act0StreetReplayFromTableV1(table);
    expect(replay?.isConsumerSafe, isTrue);
    expect(replay!.currentStreet, Act0StreetReplayStreetV1.turn);
    expect(act0TableChoreographyPlanForTableV1(table), isNotNull);
  });

  test('retains merged prohibition: Turn to Flop', () {
    _expectUnsafe(
      _syntheticTable(<String>[
        ..._preflop,
        'Flop: BB checks',
        'BTN checks',
        'Turn: BB checks',
        'Flop: BTN checks',
      ], street: 'Turn'),
      'Existing PR352 backward-street guard must remain intact.',
    );
  });

  test('retains merged prohibition: future River at current Turn', () {
    _expectUnsafe(
      _syntheticTable(<String>[
        ..._preflop,
        'Flop: BB checks',
        'BTN checks',
        'Turn: BB checks',
        'River: BTN checks',
      ], street: 'Turn'),
      'Existing PR352 future-street guard must remain intact.',
    );
  });

  test('retains merged prohibition: folded actor acts again', () {
    _expectUnsafe(
      _syntheticTable(
        <String>[..._preflop, 'Flop: BB bets 2 BB', 'BTN folds', 'BTN checks'],
        live: const <String>{'bb'},
        pot: 'Pot 8.5 BB',
      ),
      'Existing PR352 post-fold action guard must remain intact.',
    );
  });

  test('actor alternation: one seat cannot check twice consecutively', () {
    _expectUnsafe(
      _syntheticTable(<String>[..._preflop, 'Flop: BB checks', 'BB checks']),
      'The first BB check passes action to live BTN; BB cannot act again.',
    );
  });

  test('choreography rejects duplicate actor before offering a decision', () {
    final table = _syntheticTable(<String>[
      ..._preflop,
      'Flop: BB checks',
      'BB checks',
    ]);
    expect(
      act0TableChoreographyPlanForTableV1(table),
      isNull,
      reason: 'Animation consumes the same authored actor-order truth.',
    );
  });

  test('actual Runner teaching projection cannot launder actor disorder', () {
    final table = _syntheticTable(<String>[
      ..._preflop,
      'Flop: BB checks',
      'BB checks',
    ]);
    final projected = act0TeachingTableForRunnerV1(
      table,
      Act0TeachingStepV1(
        title: 'Synthetic probe',
        body: 'Only a test fixture.',
        table: table,
      ),
    );
    _expectUnsafe(projected, 'Runner teaching must preserve legality guards.');
  });

  test('actual Runner feedback projection cannot launder actor disorder', () {
    final table = _syntheticTable(<String>[
      ..._preflop,
      'Flop: BB checks',
      'BB checks',
    ]);
    // The runner is a template only. The injected table remains SYNTHETIC.
    final runner = _authoredTask('actions_check_drill').runner.copyWith(
      table: table,
      phase: Act0LessonPhaseV1.review,
      selectedOptionId: 'check',
    );
    final projected = act0FeedbackTableForRunnerV1(
      runner: runner,
      taskFamily: Act0TaskFamilyV1.decision,
    );
    _expectUnsafe(projected, 'Feedback must not certify an illegal history.');
  });

  test('the same actor may close flop and open the next street', () {
    final table = _syntheticTable(
      [
        ..._preflop,
        'Flop: BB checks',
        'BTN bets 2 BB',
        'BB calls 2 BB',
        'Turn: BB checks',
      ],
      street: 'Turn',
      pot: 'Pot 10.5 BB',
    );
    expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isTrue);
    expect(act0TableChoreographyPlanForTableV1(table), isNotNull);
  });

  test(
    'an intervening opponent raise permits the first actor to act again',
    () {
      final table = _syntheticTable([
        ..._preflop,
        'Flop: BB bets 2 BB',
        'BTN raises 6 BB',
        'BB raises 10 BB',
      ], pot: 'Pot 22.5 BB');
      expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isTrue);
      expect(act0TableChoreographyPlanForTableV1(table), isNotNull);
    },
  );

  test('repeating a street prefix does not grant a second turn', () {
    final table = _syntheticTable([
      ..._preflop,
      'Flop: BB checks',
      'Flop: BB checks',
    ]);
    _expectUnsafe(table, 'The second Flop prefix is still the same round.');
    expect(act0TableChoreographyPlanForTableV1(table), isNull);
  });

  test('a teaching note does not grant a second turn', () {
    final source = _syntheticTable([
      ..._preflop,
      'Flop: BB checks',
      'BB checks',
    ]);
    final trail = [...source.actionTrail];
    trail.insert(
      trail.length - 1,
      const Act0ActionTrailItemV1.note(label: 'Teaching observation'),
    );
    final table = source.copyWith(actionTrail: trail);
    _expectUnsafe(table, 'A nonexecuted note cannot transfer the action.');
    expect(act0TableChoreographyPlanForTableV1(table), isNull);
  });

  test(
    'a bet followed immediately by a raise by the same actor is rejected',
    () {
      final table = _syntheticTable([
        ..._preflop,
        'Flop: BB bets 2 BB',
        'BB raises 6 BB',
      ], pot: 'Pot 12.5 BB');
      _expectUnsafe(
        table,
        'A new verb does not grant the bettor a second turn.',
      );
      expect(act0TableChoreographyPlanForTableV1(table), isNull);
    },
  );
}
