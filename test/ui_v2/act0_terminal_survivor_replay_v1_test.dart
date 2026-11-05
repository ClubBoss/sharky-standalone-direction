// Synthetic continuation of the retained PKR03 / #393 six-seat fixture.
// No catalog hand or general poker-state validator is introduced.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

const _preflop = [
  'SB blind 0.5 BB',
  'BB blind 1 BB',
  'UTG folds',
  'HJ folds',
  'CO folds',
  'BTN raises 3 BB',
  'SB folds',
  'BB calls 3 BB',
];
const _threeWay = [
  'SB blind 0.5 BB',
  'BB blind 1 BB',
  'UTG folds',
  'HJ folds',
  'CO raises 3 BB',
  'BTN calls 3 BB',
  'SB folds',
  'BB calls 3 BB',
];
const _priorFolds = {'UTG', 'HJ', 'CO', 'SB'};
const _terminal = [..._preflop, 'Flop: BB bets 2 BB', 'BTN folds', 'BB checks'];

Act0TableStateV1 _table(
  List<String> trail, {
  String actor = 'btn',
  Set<String> folded = _priorFolds,
  Set<String> outOfHand = const {},
}) => Act0TableStateV1(
  scope: Act0TableScopeV1.playedHand,
  tableFormat: Act0TableFormatV1.sixMax,
  playerCount: 6,
  seats: [
    for (final label in ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'])
      Act0SeatStateV1(
        seatId: label.toLowerCase(),
        seatLabel: label,
        displayName: label == 'BTN' ? 'Hero' : label,
        isHero: label == 'BTN',
        isActive: actor == label.toLowerCase(),
        isFolded: folded.contains(label),
        isInHand: !folded.contains(label) && !outOfHand.contains(label),
      ),
  ],
  heroCards: const [
    Act0CardStateV1(rank: 'A', suit: 's'),
    Act0CardStateV1(rank: 'K', suit: 'd'),
  ],
  boardCards: const [
    Act0CardStateV1(rank: 'A', suit: 'h'),
    Act0CardStateV1(rank: '7', suit: 'c'),
    Act0CardStateV1(rank: '2', suit: 'd'),
  ],
  streetLabel: 'Flop',
  potLabel: 'Pot 8.5 BB',
  toCallLabel: '',
  centerLabel: 'Synthetic terminal-hand probe',
  actionTrail: [for (final label in trail) Act0ActionTrailItemV1(label: label)],
  activeSeatId: actor,
  heroSeatId: 'btn',
  highlightedSeatIds: const [],
  highlightedCardIds: const [],
);

void _expectUnavailable(Act0TableStateV1 table) {
  final replay = act0StreetReplayFromTableV1(table);
  expect(replay, isNotNull);
  expect(replay!.isConsumerSafe, isFalse);
  expect(replay.completeness, Act0StreetReplayCompletenessV1.insufficient);
  expect(replay.steps, isEmpty);
}

void main() {
  test('sole survivor cannot check after the last opponent folded', () {
    _expectUnavailable(
      _table(_terminal, actor: 'bb', folded: {..._priorFolds, 'BTN'}),
    );
  });

  test('executed folds prove terminal even with stale all-live flags', () {
    _expectUnavailable(_table(_terminal, actor: 'bb', folded: const {}));
  });

  test('terminal fold needs no extra action to invalidate pending replay', () {
    _expectUnavailable(
      _table(_terminal.take(_terminal.length - 1).toList(), actor: 'bb'),
    );
  });

  test(
    'explicit source folds can prove terminal despite an abridged trail',
    () {
      _expectUnavailable(
        _table(
          ['Flop: BB bets 2 BB'],
          actor: 'bb',
          folded: {..._priorFolds, 'BTN'},
        ),
      );
    },
  );

  test('two survivors keep their pending decision', () {
    final replay = act0StreetReplayFromTableV1(
      _table([..._preflop, 'Flop: BB bets 2 BB']),
    );
    expect(replay?.isConsumerSafe, isTrue);
    expect(replay!.currentDecisionActor, 'Hero');
    expect(replay.steps.last.actionSummary, 'BB bets 2 BB');
  });

  test('three-way hand after one flop fold still has two survivors', () {
    final replay = act0StreetReplayFromTableV1(
      _table([..._threeWay, 'Flop: BB bets 2 BB', 'CO folds']),
    );
    expect(replay?.isConsumerSafe, isTrue);
    expect(replay!.steps.last.actorLabel, 'CO');
    expect(replay.currentDecisionActor, 'Hero');
  });

  test('typed fold note cannot end a two-survivor hand', () {
    final table = _table([..._preflop, 'Flop: BB bets 2 BB']);
    final replay = act0StreetReplayFromTableV1(
      table.copyWith(
        actionTrail: [
          ...table.actionTrail,
          const Act0ActionTrailItemV1.note(label: 'BTN folds'),
        ],
      ),
    );
    expect(replay?.isConsumerSafe, isTrue);
    expect(replay!.steps.length, table.actionTrail.length);
  });

  test('typed post-terminal action cannot restore a decision', () {
    final table = _table(
      _terminal.take(_terminal.length - 1).toList(),
      actor: 'bb',
    );
    _expectUnavailable(
      table.copyWith(
        actionTrail: [
          ...table.actionTrail,
          const Act0ActionTrailItemV1.note(label: 'BB checks'),
        ],
      ),
    );
  });

  test('incomplete roster is not new evidence that every opponent folded', () {
    final table = _table(_terminal, actor: 'bb', folded: const {});
    // A partial source roster remains outside this terminal proof. This does
    // not certify that this deliberately incomplete fixture is a lawful hand.
    final replay = act0StreetReplayFromTableV1(
      table.copyWith(
        seats: table.seats.where((seat) => seat.seatId != 'co').toList(),
      ),
    );
    expect(replay?.isConsumerSafe, isTrue);
  });

  test('out-of-hand alone does not invent an unrecorded opponent fold', () {
    final replay = act0StreetReplayFromTableV1(
      _table(
        [..._threeWay, 'Flop: BB bets 2 BB', 'BTN folds', 'BB checks'],
        actor: 'bb',
        folded: const {'UTG', 'HJ', 'SB'},
        outOfHand: const {'CO'},
      ),
    );
    expect(replay?.isConsumerSafe, isTrue);
  });
}
