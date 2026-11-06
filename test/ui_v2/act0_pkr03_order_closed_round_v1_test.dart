// External PKR-03 adjacent witnesses. This is NOT production source.
// Review base: PR400 0347f0db65e1400ced700320a75a11b8fef9c353.
// Reuses the six-seat facts from pkr03_independent_runtime_falsifiers_v2_test.dart
// in SHARKY_PKR_020305_CONTINUATION_20261105.zip, SHA256:
// d4080a939a007f561191f02d03c9e46b496aa82c9c1c4f1386332ed945fc1f0c.
// The retained original oracle is unchanged.
//
// All tables below are SYNTHETIC. Default seats have 100 BB remaining at the
// displayed snapshot; no starting stack amount is inferred. The unsupported
// cases explicitly replace these defaults. Ordinary NLHE, 0.5/1 BB blinds,
// no ante/rake/straddle. Named call/raise amounts in these fixtures denote the
// actor's total commitment on that street, matching the original preflop
// fixture convention. These tests do not certify numeric sizing or grading.
// Selecting a different Hero only changes the observer of the synthetic hand.

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

const _seatLabels = <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];
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
const _threeWayPreflop = <String>[
  'SB blind 0.5 BB',
  'BB blind 1 BB',
  'UTG folds',
  'HJ raises 3 BB',
  'CO folds',
  'BTN calls 3 BB',
  'SB folds',
  'BB calls 3 BB',
];
const _threeWay = <String>{'hj', 'btn', 'bb'};
const _checkedFlop = <String>[..._preflop, 'Flop: BB checks', 'BTN checks'];
const _matchedFlop = <String>[
  ..._preflop,
  'Flop: BB checks',
  'BTN bets 2 BB',
  'BB calls 2 BB',
];
const _reraisedFlop = <String>[
  ..._threeWayPreflop,
  'Flop: BB bets 2 BB',
  'HJ raises 6 BB',
  'BTN raises 10 BB',
];
const _heroCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'd'),
];
const _hiddenCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '?', suit: ''),
  Act0CardStateV1(rank: '?', suit: ''),
];
const _board = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd'),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 's'),
];

Act0TableStateV1 _table(
  List<String> trail, {
  String street = 'Flop',
  String actor = 'btn',
  String hero = 'btn',
  Set<String> live = const <String>{'btn', 'bb'},
  String pot = 'Pot 6.5 BB',
  Map<String, String?> stackLabels = const <String, String?>{},
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
      for (final label in _seatLabels)
        Act0SeatStateV1(
          seatId: label.toLowerCase(),
          seatLabel: label,
          displayName: label.toLowerCase() == hero ? 'Hero' : label,
          isHero: label.toLowerCase() == hero,
          isDealerButton: label == 'BTN',
          isSmallBlind: label == 'SB',
          isBigBlind: label == 'BB',
          isInHand: live.contains(label.toLowerCase()),
          isFolded: !live.contains(label.toLowerCase()),
          isActive: actor == label.toLowerCase(),
          stackLabel: stackLabels.containsKey(label.toLowerCase())
              ? stackLabels[label.toLowerCase()]
              : '100 BB',
          holeCards: label.toLowerCase() == hero ? _heroCards : _hiddenCards,
          cardsVisibleMode: label.toLowerCase() == hero
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        ),
    ],
    heroCards: _heroCards,
    boardCards: _board.take(boardCount).toList(growable: false),
    streetLabel: street,
    potLabel: pot,
    toCallLabel: '',
    centerLabel: 'Independent synthetic PKR03 adjacent witness',
    actionTrail: <Act0ActionTrailItemV1>[
      for (final label in trail) Act0ActionTrailItemV1(label: label),
    ],
    activeSeatId: actor,
    heroSeatId: hero,
    highlightedSeatIds: const <String>[],
    highlightedCardIds: const <String>[],
  );
}

void _expectReady(Act0TableStateV1 table) {
  expect(
    act0BettingRoundOrderTruthForTableV1(table),
    Act0BettingRoundOrderTruthV1.consistent,
  );
  expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isTrue);
  expect(act0TableChoreographyPlanForTableV1(table), isNotNull);
}

void _expectContradiction(Act0TableStateV1 table) {
  expect(
    act0BettingRoundOrderTruthForTableV1(table),
    Act0BettingRoundOrderTruthV1.contradiction,
  );
  expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe ?? false, isFalse);
  expect(act0TableChoreographyPlanForTableV1(table), isNull);
}

void _expectUnproved(Act0TableStateV1 table) {
  expect(
    act0BettingRoundOrderTruthForTableV1(table),
    Act0BettingRoundOrderTruthV1.unproved,
  );
  // Unproved is not legal or illegal. Legacy presentation outside the narrow
  // proof envelope is not newly approved or blanket-suppressed by this test.
}

Act0LessonTaskV1 _authoredTemplate(String taskId) => <Act0LessonTaskV1>[
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons) ...lesson.taskList,
].singleWhere((task) => task.taskId == taskId);

void main() {
  group('SYNTHETIC adjacent actor and round obligations', () {
    test('valid three-way BB, HJ, BTN actions return the response to BB', () {
      _expectReady(
        _table(
          <String>[
            ..._threeWayPreflop,
            'Flop: BB checks',
            'HJ bets 2 BB',
            'BTN calls 2 BB',
          ],
          actor: 'bb',
          hero: 'bb',
          live: _threeWay,
          pot: 'Pot 13.5 BB',
        ),
      );
    });

    test('two checks do not finish a three-player flop', () {
      _expectReady(
        _table(
          <String>[..._threeWayPreflop, 'Flop: BB checks', 'HJ checks'],
          live: _threeWay,
          pot: 'Pot 9.5 BB',
        ),
      );
    });

    test('matched flop bet-call permits a real next-street decision', () {
      _expectReady(
        _table(
          <String>[..._matchedFlop, 'Turn: BB checks'],
          street: 'Turn',
          pot: 'Pot 10.5 BB',
        ),
      );
    });

    test('an extra same-street bet after bet-call has no poker turn', () {
      _expectContradiction(
        _table(
          <String>[..._matchedFlop, 'BTN bets 1 BB'],
          actor: 'bb',
          hero: 'bb',
          pot: 'Pot 11.5 BB',
        ),
      );
    });

    test('a re-raise gives a previously acting BB another response', () {
      _expectReady(
        _table(
          _reraisedFlop,
          actor: 'bb',
          hero: 'bb',
          live: _threeWay,
          pot: 'Pot 27.5 BB',
        ),
      );
    });

    test('BB responding to a re-raise does not discharge the HJ response', () {
      _expectContradiction(
        _table(
          <String>[..._reraisedFlop, 'BB calls 10 BB', 'Turn: BB checks'],
          street: 'Turn',
          live: _threeWay,
          pot: 'Pot 35.5 BB',
        ),
      );
    });

    test('both prior actors may respond before the next three-way street', () {
      _expectReady(
        _table(
          <String>[
            ..._reraisedFlop,
            'BB calls 10 BB',
            'HJ calls 10 BB',
            'Turn: BB checks',
            'HJ checks',
          ],
          street: 'Turn',
          live: _threeWay,
          pot: 'Pot 39.5 BB',
        ),
      );
    });

    test('a final active marker cannot give BB two consecutive turns', () {
      _expectContradiction(
        _table(
          <String>[..._preflop, 'Flop: BB checks'],
          actor: 'bb',
          hero: 'bb',
        ),
      );
    });

    test('with only BB and BTN live, BTN cannot act first postflop', () {
      _expectContradiction(
        _table(
          <String>[..._preflop, 'Flop: BTN checks'],
          actor: 'bb',
          hero: 'bb',
        ),
      );
    });

    test('a final Flop boundary cannot skip the remaining BB response', () {
      for (final includeMarker in <bool>[true, false]) {
        _expectContradiction(
          _table(
            <String>[
              ..._preflop.take(_preflop.length - 1),
              if (includeMarker) 'Flop:',
            ],
            actor: 'bb',
            hero: 'bb',
            pot: 'Pot 4.5 BB',
          ),
        );
      }
    });

    test('a final Flop boundary does not give BTN the first action', () {
      for (final includeMarker in <bool>[true, false]) {
        _expectContradiction(
          _table(<String>[..._preflop, if (includeMarker) 'Flop:']),
        );
      }
    });

    test('a final Flop boundary preserves the legal first BB decision', () {
      for (final includeMarker in <bool>[true, false]) {
        final table = _table(
          <String>[..._preflop, if (includeMarker) 'Flop:'],
          actor: 'bb',
          hero: 'bb',
        );
        expect(
          act0BettingRoundOrderTruthForTableV1(table),
          Act0BettingRoundOrderTruthV1.consistent,
          reason: 'includeMarker=$includeMarker',
        );
        expect(
          act0StreetReplayFromTableV1(table)?.isConsumerSafe,
          isTrue,
          reason: 'includeMarker=$includeMarker',
        );
        // Choreography requires its own explicit street/action grammar.
        // A legal round transition does not broaden that consumer's grammar.
      }
    });
  });

  group('SYNTHETIC unsupported facts remain explicitly unproved', () {
    test('a missing current-live stack does not prove ability to act', () {
      _expectUnproved(
        _table(
          <String>[..._preflop, 'Flop: BB checks'],
          stackLabels: const <String, String?>{'btn': null},
        ),
      );
    });

    test('zero remaining stack is outside the ordinary-action proof', () {
      _expectUnproved(
        _table(
          <String>[..._preflop, 'Flop: BB checks'],
          stackLabels: const <String, String?>{'bb': '0 BB'},
        ),
      );
    });

    test('an incomplete roster cannot prove all response obligations', () {
      final table = _table(<String>[..._preflop, 'Flop: BB checks']);
      _expectUnproved(
        table.copyWith(
          seats: table.seats.where((seat) => seat.seatId != 'co').toList(),
        ),
      );
    });

    test('an explicit all-in hand is not certified by the ordinary guard', () {
      _expectUnproved(
        _table(
          <String>[..._preflop, 'Flop: BB shoves 2 BB'],
          pot: 'Pot 8.5 BB',
          stackLabels: const <String, String?>{'bb': '0 BB'},
        ),
      );
    });

    test('additional-call wording is not silently treated as call-to', () {
      _expectUnproved(
        _table(<String>[
          ..._preflop.take(_preflop.length - 1),
          'BB calls 2 BB more',
          'Flop: BB checks',
        ]),
      );
    });

    test('suffix street grammar remains outside the narrow proof', () {
      _expectUnproved(_table(<String>[..._preflop, 'BB checks flop']));
    });
  });

  group('SYNTHETIC closed-round truth through actual Runner projections', () {
    test('teaching cannot turn a closed-round extra bet into safe replay', () {
      final table = _table(<String>[
        ..._checkedFlop,
        'BB bets 1 BB',
      ], pot: 'Pot 7.5 BB');
      final projected = act0TeachingTableForRunnerV1(
        table,
        Act0TeachingStepV1(
          title: 'Synthetic PKR03 adjacent witness',
          body: 'Only an external test fixture.',
          table: table,
        ),
      );
      _expectContradiction(projected);
    });

    test('feedback cannot turn a closed-round extra bet into safe replay', () {
      final table = _table(<String>[
        ..._checkedFlop,
        'BB bets 1 BB',
      ], pot: 'Pot 7.5 BB');
      // The authored task provides a Runner template, not invented source data.
      // Its table is explicitly replaced by the same synthetic witness.
      final runner = _authoredTemplate('actions_check_drill').runner.copyWith(
        table: table,
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: 'check',
      );
      final projected = act0FeedbackTableForRunnerV1(
        runner: runner,
        taskFamily: Act0TaskFamilyV1.decision,
      );
      _expectContradiction(projected);
    });
  });
}
