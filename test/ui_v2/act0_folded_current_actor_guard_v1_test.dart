// Reuses the synthetic PKR03 / #393 fixture. These are consumer falsifiers,
// not newly authored catalog hands or full poker-state validation.
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
  Set<String> folded = const <String>{},
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
          isFolded:
              folded.contains(label.toLowerCase()) ||
              !live.contains(label.toLowerCase()),
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

const _heroFold = <String>[..._preflop, 'Flop: BB bets 2 BB', 'BTN folds'];

Act0TableStateV1 _feedback(Act0TableStateV1 table) =>
    act0FeedbackTableForRunnerV1(
      runner: _authoredTask('actions_check_drill').runner.copyWith(
        table: table,
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: 'check',
      ),
      taskFamily: Act0TaskFamilyV1.decision,
    );

Act0TableStateV1 _teaching(Act0TableStateV1 table) =>
    act0TeachingTableForRunnerV1(
      table,
      Act0TeachingStepV1(
        title: 'Synthetic fold probe',
        body: 'Only a consumer fixture.',
        table: table,
      ),
    );

void _expectWithheld(Act0TableStateV1 table) {
  expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe ?? false, isFalse);
  expect(act0TableChoreographyPlanForTableV1(table), isNull);
}

void _expectReady(Act0TableStateV1 table) {
  expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isTrue);
  final plan = act0TableChoreographyPlanForTableV1(table);
  expect(plan, isNotNull);
  final frame = act0TableChoreographyFrameAfterBeatV1(
    plan!,
    plan.beats.length - 1,
  );
  expect(frame.heroDecisionReady, isTrue);
  expect(frame.focusSeatId, 'btn');
  expect(frame.foldedSeatIds, isNot(contains('btn')));
}

void main() {
  test('executed BTN fold makes current replay actor unsafe', () {
    final table = _syntheticTable(_heroFold, live: const {'bb'});
    expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isFalse);
  });

  test('executed BTN fold cannot emit heroDecisionReady', () {
    final table = _syntheticTable(_heroFold, live: const {'bb'});
    expect(act0TableChoreographyPlanForTableV1(table), isNull);
  });

  test('executed fold rejects stale live current-hero flags', () {
    _expectWithheld(_syntheticTable(_heroFold));
  });

  test('source folded flag rejects current hero without a trail fold', () {
    _expectWithheld(
      _syntheticTable([..._preflop, 'Flop: BB checks'], folded: const {'btn'}),
    );
  });

  test('replay also rejects a demonstrably folded nonhero current actor', () {
    final table = _syntheticTable([
      ..._preflop,
      'Flop: BB bets 2 BB',
      'BTN raises 6 BB',
      'BB folds',
    ], actor: 'bb');
    expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isFalse);
  });

  for (final trailOwned in [false, true]) {
    final evidence = trailOwned ? 'executed fold' : 'source flag';
    final table = trailOwned
        ? _syntheticTable(_heroFold)
        : _syntheticTable(
            [..._preflop, 'Flop: BB checks'],
            folded: const {'btn'},
          );
    test('teaching preserves $evidence restriction', () {
      _expectWithheld(_teaching(table));
    });
    test('feedback preserves $evidence restriction', () {
      _expectWithheld(_feedback(table));
    });
  }

  test('live BTN after BB check remains ready despite folded opponents', () {
    _expectReady(_syntheticTable([..._preflop, 'Flop: BB checks']));
  });

  test('a typed teaching note is not an executed hero fold', () {
    final table = _syntheticTable([..._preflop, 'Flop: BB checks']);
    _expectReady(
      table.copyWith(
        actionTrail: [
          ...table.actionTrail,
          const Act0ActionTrailItemV1.note(label: 'BTN folds'),
        ],
      ),
    );
  });

  test('teaching and feedback preserve the live-hero positive control', () {
    final table = _syntheticTable([..._preflop, 'Flop: BB checks']);
    _expectReady(_teaching(table));
    _expectReady(_feedback(table));
  });
}
