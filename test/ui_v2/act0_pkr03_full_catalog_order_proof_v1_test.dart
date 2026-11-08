// PKR-03 street sequence: full-catalog order proof with explicit reasons.
//
// Every authored playedHand table gets a verdict and a stable reason code
// from act0BettingRoundOrderProofForTableV1. Nothing here invents an action,
// a fold or a stack: an omitted prefix, an unrecorded exit or an unknown
// current-actor stack stays UNPROVED with its reason. Negative cases mutate
// real catalog tables (wrong street, skipped response, action after close,
// folded or all-in actor acting, premature hand end) and must contradict;
// contradicting tables are never replayed or choreographed.

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

final _tasks = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList) task,
];

Act0TableStateV1 _authored(String taskId) =>
    _tasks.singleWhere((t) => t.taskId == taskId).runner.table;

Act0TableStateV1 _withTrail(Act0TableStateV1 t, List<String> trail) =>
    t.copyWith(
      actionTrail: [
        for (final label in trail) Act0ActionTrailItemV1(label: label),
      ],
    );

List<String> _trail(Act0TableStateV1 t) => [
  for (final item in t.actionTrail)
    if (!item.isNote) item.label,
];

Act0SeatStateV1 _withStack(Act0SeatStateV1 s, String? stackLabel) =>
    Act0SeatStateV1(
      seatId: s.seatId,
      seatLabel: s.seatLabel,
      displayName: s.displayName,
      isHero: s.isHero,
      isDealerButton: s.isDealerButton,
      isSmallBlind: s.isSmallBlind,
      isBigBlind: s.isBigBlind,
      blindAmountLabel: s.blindAmountLabel,
      isActive: s.isActive,
      isTarget: s.isTarget,
      isInHand: s.isInHand,
      isFolded: s.isFolded,
      hasActed: s.hasActed,
      isLastAggressor: s.isLastAggressor,
      isOccupied: s.isOccupied,
      stackLabel: stackLabel,
      holeCards: s.holeCards,
      cardsVisibleMode: s.cardsVisibleMode,
      currentBetLabel: s.currentBetLabel,
      bet: s.bet,
    );

Act0TableStateV1 _stack(Act0TableStateV1 t, String seatId, String? label) =>
    t.copyWith(
      seats: [
        for (final s in t.seats) s.seatId == seatId ? _withStack(s, label) : s,
      ],
    );

void _contradicts(Act0TableStateV1 table, String reason) {
  final proof = act0BettingRoundOrderProofForTableV1(table);
  expect(proof.truth, Act0BettingRoundOrderTruthV1.contradiction);
  expect(proof.reason, reason);
  // A contradicting history is never replayed or choreographed.
  expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe ?? false, isFalse);
  expect(act0TableChoreographyPlanForTableV1(table), isNull);
}

void _proof(
  Act0TableStateV1 table,
  Act0BettingRoundOrderTruthV1 truth,
  String reason,
) {
  final proof = act0BettingRoundOrderProofForTableV1(table);
  expect((proof.truth, proof.reason), (truth, reason));
}

// Fully recorded authored histories whose order, round closure and end are
// proven, and the authored current decisions whose actor has no authored
// stack (order proven up to the decision; ability to act not authored).
const _consistent = <String>{
  'your_first_hand_preflop',
  'your_first_hand_private_cards_recheck',
  'your_first_hand_showdown',
  'your_first_hand_recap',
  'w4_protection_check',
};

// Exact reason partition of the authored playedHand catalog (314 tables).
const _reasonCounts = <String, int>{
  'no_recorded_history': 193,
  'history_starts_after_blinds': 35,
  'current_actor_stack_unknown': 34,
  'out_of_hand_without_recorded_fold': 27,
  'unsupported_grammar': 15,
  'consistent_closed_history': 5,
  'dead_button_or_empty_blind': 3,
  'empty_seat_acts': 1,
  'roster_incomplete_or_marked_all_in': 1,
};

void main() {
  group('full authored catalog', () {
    final played = [
      for (final t in _tasks)
        if (t.runner.table.scope == Act0TableScopeV1.playedHand) t,
    ];

    test('every playedHand table has an exact verdict and reason', () {
      expect(played, hasLength(314));
      final counts = <String, int>{};
      final byTruth = <Act0BettingRoundOrderTruthV1, Set<String>>{};
      for (final t in played) {
        final proof = act0BettingRoundOrderProofForTableV1(t.runner.table);
        counts[proof.reason] = (counts[proof.reason] ?? 0) + 1;
        byTruth.putIfAbsent(proof.truth, () => {}).add(t.taskId);
      }
      expect(counts, _reasonCounts);
      expect(byTruth[Act0BettingRoundOrderTruthV1.consistent], _consistent);
      // The only authored contradiction is a real source defect: the trail
      // records 'UTG folds' while the UTG seat is empty.
      expect(byTruth[Act0BettingRoundOrderTruthV1.contradiction], {
        'position_checkpoint_position_checkpoint_table_notice',
      });
    });

    test(
      'every playedHand snapshot keeps street, board and decision truth',
      () {
        const boardForStreet = {'Preflop': 0, 'Flop': 3, 'Turn': 4, 'River': 5};
        for (final t in played) {
          final table = t.runner.table;
          expect(
            table.boardCards.length,
            boardForStreet[table.streetLabel],
            reason: '${t.taskId} street ${table.streetLabel}',
          );
          final live = table.seats.where(
            (s) => s.isOccupied && s.isInHand && !s.isFolded,
          );
          final activeId = table.activeSeatId?.trim() ?? '';
          if (activeId.isEmpty) continue;
          final active = table.seats.where((s) => s.seatId == activeId);
          expect(active, hasLength(1), reason: t.taskId);
          // A pending decision needs a live, occupied actor and an opponent.
          expect(active.single.isOccupied, isTrue, reason: t.taskId);
          expect(active.single.isInHand, isTrue, reason: t.taskId);
          expect(active.single.isFolded, isFalse, reason: t.taskId);
          expect(live.length, greaterThanOrEqualTo(2), reason: t.taskId);
        }
      },
    );

    test('the empty-seat contradiction is fail-closed for consumers', () {
      final table = _authored(
        'position_checkpoint_position_checkpoint_table_notice',
      );
      expect(_trail(table), ['UTG folds', 'HJ folds', 'CO acts']);
      expect(
        table.seats.singleWhere((s) => s.seatLabel == 'UTG').isOccupied,
        isFalse,
      );
      _contradicts(table, 'empty_seat_acts');
    });
  });

  group('negative controls on a fully recorded authored hand', () {
    final recap = _authored('your_first_hand_recap');
    final full = _trail(recap);
    final preflop = full.sublist(0, 9);

    test('the unmutated river history is proven', () {
      _proof(
        recap,
        Act0BettingRoundOrderTruthV1.consistent,
        'consistent_closed_history',
      );
    });

    test('a skipped street contradicts', () {
      _contradicts(
        _withTrail(recap, [
          ...preflop,
          'Flop: BB checks',
          'Flop: BTN checks',
          'River: BB checks',
          'River: BTN checks',
        ]),
        'street_skipped_or_backwards',
      );
    });

    test('a street going backwards contradicts', () {
      _contradicts(
        _withTrail(recap, [
          ...preflop,
          'Flop: BB checks',
          'Flop: BTN checks',
          'Turn: BB checks',
          'Turn: BTN checks',
          'Flop: BB checks',
        ]),
        'street_skipped_or_backwards',
      );
    });

    test('a skipped response contradicts', () {
      final skipped = [...full]..remove('BB calls 2 BB more');
      _contradicts(_withTrail(recap, skipped), 'out_of_turn_actor');
    });

    test('an action after the river closed contradicts', () {
      _contradicts(
        _withTrail(recap, [...full, 'River: BB bets 2 BB']),
        'action_after_round_or_hand_closed',
      );
    });

    test('a folded player acting contradicts', () {
      _contradicts(
        _withTrail(recap, [...preflop, 'Flop: CO checks']),
        'folded_actor_acts',
      );
    });

    test('an all-in player acting again contradicts', () {
      _contradicts(
        _withTrail(recap, [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG folds',
          'HJ folds',
          'CO folds',
          'BTN shoves 100 BB',
          'SB folds',
          'BB calls 100 BB',
          'Flop: BB checks',
          'BTN checks',
        ]),
        'all_in_actor_acts_again',
      );
    });

    test('play after everyone else folded contradicts', () {
      _contradicts(
        _withTrail(recap, [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG folds',
          'HJ folds',
          'CO folds',
          'BTN folds',
          'SB folds',
          'Flop: BB checks',
        ]),
        'round_not_closed_or_hand_over',
      );
    });
  });

  group('current decision', () {
    final flop = _authored('your_first_hand_flop');

    test('an authored decision without the actor stack stays unproved', () {
      expect(flop.activeSeatId, 'btn');
      _proof(
        flop,
        Act0BettingRoundOrderTruthV1.unproved,
        'current_actor_stack_unknown',
      );
    });

    test('the same decision with an authored positive stack is proven', () {
      _proof(
        _stack(flop, 'btn', '97 BB'),
        Act0BettingRoundOrderTruthV1.consistent,
        'consistent_current_decision',
      );
    });

    test('an explicit zero stack stays outside the proof', () {
      _proof(
        _stack(flop, 'btn', '0 BB'),
        Act0BettingRoundOrderTruthV1.unproved,
        'zero_stack_outside_proof',
      );
    });

    test('the last actor cannot also hold the decision', () {
      final bb = flop.copyWith(activeSeatId: 'bb');
      _contradicts(_stack(bb, 'bb', '97 BB'), 'current_actor_acts_twice');
    });

    test('a decision after the hand is over contradicts', () {
      final over = _withTrail(flop, [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG folds',
        'HJ folds',
        'CO folds',
        'BTN raises to 3 BB',
        'SB folds',
        'BB folds',
      ]).copyWith(streetLabel: 'Preflop', boardCards: const []);
      _contradicts(over, 'decision_after_round_or_hand_closed');
    });
  });

  group('decision marker and open grammar', () {
    final utg = _authored('hand_discipline_buckets_trash');

    test('a marker naming another seat than the active one contradicts', () {
      expect(_trail(utg).last, 'UTG acts');
      _contradicts(
        utg.copyWith(activeSeatId: 'hj'),
        'decision_marker_not_active_seat',
      );
    });

    test('a marker before a later action contradicts', () {
      _contradicts(
        _withTrail(utg, [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG acts',
          'UTG folds',
        ]),
        'decision_marker_not_last',
      );
    });

    test('an open after a raise is not read as a first-in raise', () {
      _proof(
        _withTrail(utg, [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG raises to 3 BB',
          'HJ opens 6 BB',
        ]),
        Act0BettingRoundOrderTruthV1.unproved,
        'open_not_first_in_preflop',
      );
    });
  });

  group('independent review follow-ups', () {
    final flop = _authored('your_first_hand_flop');
    final preflop = _trail(flop).sublist(0, 9);

    test('consumers refuse a contradicting mutation of a replay-safe base', () {
      // The authored flop table is shown as a replay and choreographed.
      expect(act0StreetReplayFromTableV1(flop)?.isConsumerSafe, isTrue);
      final skipped = [..._trail(flop)]..remove('BB calls 2 BB more');
      _contradicts(_withTrail(flop, skipped), 'out_of_turn_actor');
      _contradicts(
        _withTrail(flop, [...preflop, 'Flop: CO checks']),
        'folded_actor_acts',
      );
    });

    test('a checked-to decision needs an opponent who can still act', () {
      // Reviewer counterexample: BTN may have called all-in for 3 BB, so BB
      // could have no flop decision at all.
      final bbToAct = _stack(
        _withTrail(flop, [...preflop, 'Flop: BB acts']),
        'bb',
        '97 BB',
      ).copyWith(activeSeatId: 'bb');
      _proof(
        bbToAct,
        Act0BettingRoundOrderTruthV1.unproved,
        'opponents_may_be_all_in',
      );
      _proof(
        _stack(bbToAct, 'btn', '97 BB'),
        Act0BettingRoundOrderTruthV1.consistent,
        'consistent_current_decision',
      );
    });

    test('a marker naming a folded seat contradicts', () {
      _contradicts(
        _withTrail(flop, [
          ...preflop,
          'Flop: BB checks',
          'CO acts',
        ]).copyWith(activeSeatId: ''),
        'active_actor_folded',
      );
    });

    test('a marker on another street than the snapshot contradicts', () {
      _contradicts(
        _withTrail(flop, [...preflop, 'Flop: BB checks', 'Turn: BTN acts']),
        'decision_marker_wrong_street',
      );
    });

    test('an open after a limp is not a first-in raise', () {
      final allLive = flop.copyWith(
        seats: [
          for (final s in flop.seats)
            Act0SeatStateV1(
              seatId: s.seatId,
              seatLabel: s.seatLabel,
              displayName: s.displayName,
              isHero: s.isHero,
              isDealerButton: s.isDealerButton,
              isSmallBlind: s.isSmallBlind,
              isBigBlind: s.isBigBlind,
              isOccupied: s.isOccupied,
              isInHand: true,
              isFolded: false,
              stackLabel: '97 BB',
              holeCards: s.holeCards,
              cardsVisibleMode: s.cardsVisibleMode,
            ),
        ],
      );
      _proof(
        _withTrail(allLive, [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG calls 1 BB',
          'HJ opens 3 BB',
        ]).copyWith(streetLabel: 'Preflop', boardCards: const []),
        Act0BettingRoundOrderTruthV1.unproved,
        'open_not_first_in_preflop',
      );
    });

    test('one label on an empty and an occupied seat is ambiguous', () {
      final utg = flop.seats.singleWhere((s) => s.seatLabel == 'UTG');
      final duplicated = flop.copyWith(
        seats: [
          ...flop.seats,
          Act0SeatStateV1(
            seatId: 'utg_empty',
            seatLabel: utg.seatLabel,
            displayName: utg.displayName,
            isOccupied: false,
          ),
        ],
      );
      final proof = act0BettingRoundOrderProofForTableV1(duplicated);
      expect(proof.truth, isNot(Act0BettingRoundOrderTruthV1.consistent));
      expect(proof.reason, isNot('empty_seat_acts'));
    });
  });
}
