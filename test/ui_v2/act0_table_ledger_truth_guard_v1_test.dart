import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_ledger_v1.dart';

/// Table Truth economics for the live Act0 W1-W12 route.
///
/// Every task table and teaching-table override is replayed by the source
/// ledger. A table is either certified (its trail is a legal history and the
/// pot, price, live seats, bets and next actor follow from it) or it is one of
/// the exact residuals listed below. The residual list may only shrink: a new
/// uncertified table, or a listed one that becomes certified, fails here.
void main() {
  final tasks = <Act0LessonTaskV1>[
    for (final w in Act0ShellStateV1.sample.worlds)
      for (final l in w.lessons) ...l.taskList,
  ];
  Act0LessonTaskV1 task(String id) => tasks.singleWhere((t) => t.taskId == id);
  List<Act0TableStateV1> tablesOf(Act0LessonTaskV1 t) => [
    t.runner.table,
    for (final s in t.runner.teachingSteps)
      if (s.table != null) s.table!,
  ];
  Act0SeatStateV1 seatOf(Act0TableStateV1 table, String id) =>
      table.seats.singleWhere((s) => s.seatId == id);

  test('every table holds under its scope; nothing is left unaccounted', () {
    final byStatus = <Act0TableLedgerStatusV1, List<String>>{};
    final problems = <String>[];
    var tableCount = 0;
    for (final t in tasks) {
      final tables = tablesOf(t);
      for (var i = 0; i < tables.length; i++) {
        tableCount += 1;
        final table = tables[i];
        final ledger = act0TableLedgerForV1(table);
        final id = '${t.taskId}#$i';
        byStatus.putIfAbsent(ledger.status, () => []).add(id);
        final expected = switch (table.scope) {
          Act0TableScopeV1.playedHand => Act0TableLedgerStatusV1.certified,
          Act0TableScopeV1.orientation => Act0TableLedgerStatusV1.orientation,
          Act0TableScopeV1.explanation => Act0TableLedgerStatusV1.explanatory,
        };
        if (ledger.status != expected) {
          problems.add('$id ${table.scope.name}: ${ledger.problems}');
        }
      }
    }
    expect(tasks.length, 367);
    expect(tableCount, 367);
    expect(problems, isEmpty);
    expect(byStatus[Act0TableLedgerStatusV1.certified]?.length, 317);
    expect(byStatus[Act0TableLedgerStatusV1.orientation]?.length, 46);
    expect(byStatus[Act0TableLedgerStatusV1.explanatory]?.toSet(), {
      'what_poker_is_all_in_meaning#0',
      'what_poker_is_matched_chips_transfer#0',
      'what_poker_is_side_pot_intro#0',
      'same_hand_different_seat_position_repair_same_hand_different_seat#0',
    });
  });

  test('explanation diagrams state their pots and who can win them', () {
    final sidePot = task('what_poker_is_side_pot_intro').runner.table;
    final chips = sidePot.chipExplanation!;
    expect(chips.contributions.values.fold(0.0, (a, b) => a + b), 120.5);
    expect(chips.pots.map((p) => p.amountBb), [60.5, 60]);
    expect(chips.pots.first.eligibleSeatIds, {'btn', 'co', 'bb'});
    expect(chips.pots.last.eligibleSeatIds, {'co', 'bb'});
    expect(chips.pots.last.eligibleSeatIds.contains('btn'), isFalse);
    final allIn = task('what_poker_is_all_in_meaning').runner.table;
    expect(allIn.chipExplanation!.pots.single.amountBb, 41.5);
    for (final t in [sidePot, allIn]) {
      expect(t.actionTrail.every((i) => i.isNote), isTrue);
      expect(t.scope, Act0TableScopeV1.explanation);
    }
  });

  test('W4 sizing keeps one-third 2, half 3 and pot 6 on a 6 BB flop', () {
    for (final id in ['w4_small_bet', 'w4_half_pot_bet', 'w4_pot_bet']) {
      final ledger = act0TableLedgerForV1(task(id).runner.table);
      expect(ledger.problems, isEmpty, reason: id);
      expect(ledger.potBb, 6, reason: id);
      expect(ledger.liveSeatIds, {'btn', 'bb'}, reason: id);
      expect(ledger.nextActorSeatId, 'btn', reason: id);
    }
    expect(
      task('w4_small_bet').runner.options.singleWhere((o) => o.isCorrect).id,
      'two',
    );
    expect(
      task('w4_half_pot_bet').runner.options.singleWhere((o) => o.isCorrect).id,
      'three',
    );
    expect(
      task('w4_pot_bet').runner.options.singleWhere((o) => o.isCorrect).id,
      'six',
    );
    final checkedBack = act0TableLedgerForV1(
      task('w4_protection_check').runner.table,
    );
    expect(checkedBack.problems, isEmpty);
    expect(checkedBack.nextActorSeatId, isNull);
  });

  test('W4 prices: entering pots match the pot-odds feedback', () {
    final cases = {
      'w4_good_price_call': (8.0, 1.0, 'hj'),
      'w4_bad_price_fold': (15.0, 7.0, 'hj'),
      'w4_cheap_price_marginal_call': (10.0, 1.0, 'hj'),
      'w4_big_price_marginal_fold': (15.0, 6.0, 'bb'),
      'w4_checkpoint_table_price': (7.0, 2.0, 'bb'),
    };
    cases.forEach((id, expected) {
      final table = task(id).runner.table;
      final ledger = act0TableLedgerForV1(table);
      expect(ledger.problems, isEmpty, reason: id);
      expect(ledger.potBb, expected.$1, reason: id);
      expect(ledger.heroPriceBb, expected.$2, reason: id);
      final bettor = table.seats.singleWhere(
        (s) => (s.currentBetLabel ?? '').isNotEmpty,
      );
      expect(bettor.seatId, expected.$3, reason: id);
    });
  });

  test('stacks, antes and shoves are authored where the copy states them', () {
    final bubble = task('w9_bubble_table_risk_transfer').runner.table;
    expect(seatOf(bubble, 'bb').stackLabel, 'All-in');
    expect(act0TableLedgerForV1(bubble).heroPriceBb, 15.5);
    final ante = act0TableLedgerForV1(
      task('w11_trigger_small_price_continue').runner.table,
    );
    expect(ante.potBb, 10);
    expect(ante.problems, isEmpty);
    final spr = task('w7_top_pair_spr2_transfer').runner.table;
    expect(seatOf(spr, 'btn').stackLabel, '10 BB');
    expect(act0TableLedgerForV1(spr).potBb, 8);
  });

  test('W11: HJ is the live current bettor Hero responds to', () {
    final t = task('w11_checkpoint_mixed_table_line');
    final table = t.runner.table;
    final hj = seatOf(table, 'hj');
    expect(t.runner.caption, contains('HJ bets 5 BB into 8 BB'));
    expect(hj.currentBetLabel, '5 BB');
    expect(hj.isInHand, isTrue);
    expect(hj.isFolded, isFalse);
    expect(hj.cardsVisibleMode, Act0CardsVisibleModeV1.faceDown);
    final ledger = act0TableLedgerForV1(table);
    expect(ledger.problems, isEmpty);
    expect(ledger.liveSeatIds, {'hj', 'btn', 'bb'});
    expect(ledger.nextActorSeatId, 'btn');
    expect(ledger.heroPriceBb, 5);
    expect(ledger.potBb, 13);
    expect(table.highlightedSeatIds, ['hj', 'btn']);
    expect(t.runner.options.where((o) => o.isCorrect).map((o) => o.id), [
      'call_in_position',
    ]);
  });

  test('F2: Check is legal because no bet faces Hero', () {
    for (final id in ['actions_check_drill', 'actions_legal_context']) {
      final t = task(id);
      final ledger = act0TableLedgerForV1(t.runner.table);
      expect(ledger.problems, isEmpty, reason: id);
      expect(ledger.potBb, 3, reason: id);
      expect(ledger.heroPriceBb, 0, reason: id);
      expect(ledger.nextActorSeatId, 'btn', reason: id);
      expect(ledger.liveSeatIds, {'btn', 'sb', 'bb'}, reason: id);
      expect(t.runner.options.where((o) => o.isCorrect).map((o) => o.id), [
        'check',
      ], reason: id);
    }
  });

  test('F3: Hero faces HJ\'s live 1 BB bet; a 4 BB raise stays legal', () {
    final t = task('actions_call_drill');
    final table = t.runner.table;
    final ledger = act0TableLedgerForV1(table);
    expect(ledger.problems, isEmpty);
    expect(ledger.potBb, 5);
    expect(ledger.heroPriceBb, 1);
    expect(ledger.nextActorSeatId, 'btn');
    expect(ledger.liveSeatIds, {'hj', 'btn', 'sb', 'bb'});
    expect(seatOf(table, 'hj').bet?.amountLabel, '1 BB');
    expect(table.highlightedSeatIds, ['hj']);
    final call = t.runner.options.singleWhere((o) => o.id == 'call');
    final raise = t.runner.options.singleWhere((o) => o.id == 'raise');
    expect(call.isCorrect, isTrue);
    expect(call.amountLabel, '1 BB');
    expect(raise.isCorrect, isFalse);
    // A raise must at least double a 1 BB bet; 4 BB is a legal raise.
    expect(raise.amountLabel, '4 BB');
  });

  test('F1: shared board frames are one heads-up CO vs Hero hand', () {
    final f1 = [
      'cards_ranks_suits_private_board',
      'what_poker_is_showdown_win',
      'hand_rankings_flush_drill',
      'showdown_tie_drill',
      'turn_river_changes_w5_turn_hits',
      'w6_value_range_action',
      'visible_card_combo_density_transfer_check',
      'w7_low_spr_commit',
      'w9_bubble_short_stack',
      'w12_checkpoint_process_line',
    ];
    for (final id in f1) {
      final ledger = act0TableLedgerForV1(task(id).runner.table);
      expect(ledger.problems, isEmpty, reason: id);
      expect(ledger.potBb, 6.5, reason: id);
      expect(ledger.liveSeatIds, {'co', 'btn'}, reason: id);
    }
    // A river showdown is checked through and both hands are on the table.
    final showdown = act0TableLedgerForV1(
      task('showdown_tie_drill').runner.table,
    );
    expect(showdown.nextActorSeatId, isNull);
    expect(showdown.streetLabel, 'River');
  });

  group('negative controls', () {
    Act0SeatStateV1 reseat(
      Act0SeatStateV1 s, {
      bool? folded,
      Act0SeatBetStateV1? bet,
      bool clearBet = false,
    }) => Act0SeatStateV1(
      seatId: s.seatId,
      seatLabel: s.seatLabel,
      displayName: s.displayName,
      isHero: s.isHero,
      isDealerButton: s.isDealerButton,
      isSmallBlind: s.isSmallBlind,
      isBigBlind: s.isBigBlind,
      blindAmountLabel: s.blindAmountLabel,
      isActive: s.isActive,
      isInHand: folded == null ? s.isInHand : !folded,
      isFolded: folded ?? s.isFolded,
      hasActed: s.hasActed,
      holeCards: s.holeCards,
      cardsVisibleMode: folded == true
          ? Act0CardsVisibleModeV1.none
          : s.cardsVisibleMode,
      currentBetLabel: clearBet
          ? null
          : (bet?.amountLabel ?? s.currentBetLabel),
      bet: clearBet ? null : (bet ?? s.bet),
    );
    Act0TableStateV1 mapSeat(
      Act0TableStateV1 table,
      String id,
      Act0SeatStateV1 Function(Act0SeatStateV1) change,
    ) => table.copyWith(
      seats: [for (final s in table.seats) s.seatId == id ? change(s) : s],
    );
    bool flags(Act0TableStateV1 table, String needle) =>
        act0TableLedgerForV1(table).problems.any((p) => p.contains(needle));

    test('rejects the original W11 folded current bettor', () {
      final table = task('w11_checkpoint_mixed_table_line').runner.table;
      final regressed = mapSeat(table, 'hj', (s) => reseat(s, folded: true));
      final ledger = act0TableLedgerForV1(regressed);
      expect(ledger.isCertified, isFalse);
      expect(flags(regressed, 'hj is live in the history but out'), isTrue);
      expect(flags(regressed, 'hj shows a 5 BB bet but is out'), isTrue);
    });

    test('does not certify an unexplained postflop pot', () {
      final table = task(
        'cards_ranks_suits_private_board',
      ).runner.table.copyWith(actionTrail: const <Act0ActionTrailItemV1>[]);
      expect(
        act0TableLedgerForV1(table).status,
        Act0TableLedgerStatusV1.unexplained,
      );
    });

    test('rejects an action by a player who already folded', () {
      final table = task('cards_ranks_suits_private_board').runner.table;
      final illegal = table.copyWith(
        actionTrail: [
          ...table.actionTrail,
          const Act0ActionTrailItemV1(label: 'Flop: UTG bets 2 BB'),
        ],
      );
      expect(flags(illegal, 'utg already folded'), isTrue);
    });

    test('rejects a visible bet that is not the bettor\'s wager', () {
      final table = task('w11_checkpoint_mixed_table_line').runner.table;
      final wrongAmount = mapSeat(
        table,
        'hj',
        (s) => reseat(
          s,
          bet: const Act0SeatBetStateV1(
            kind: Act0SeatBetKindV1.bet,
            label: 'HJ',
            amountLabel: '4 BB',
          ),
        ),
      );
      expect(flags(wrongAmount, 'hj shows 4 BB'), isTrue);
      final wrongOwner = mapSeat(
        mapSeat(table, 'hj', (s) => reseat(s, clearBet: true)),
        'bb',
        (s) => reseat(
          s,
          bet: const Act0SeatBetStateV1(
            kind: Act0SeatBetKindV1.bet,
            label: 'BB',
            amountLabel: '5 BB',
          ),
        ),
      );
      expect(flags(wrongOwner, 'bb shows 5 BB'), isTrue);
    });

    test('rejects a pot that the contributions do not explain', () {
      final table = task(
        'cards_ranks_suits_private_board',
      ).runner.table.copyWith(potLabel: 'Pot 5 BB');
      expect(flags(table, 'Pot 5 BB but contributions total 6.5 BB'), isTrue);
      final price = task(
        'actions_call_drill',
      ).runner.table.copyWith(toCallLabel: 'To call 2 BB');
      expect(flags(price, 'To call 2 BB but Hero owes 1 BB'), isTrue);
    });

    test('rejects a check facing a bet', () {
      final table = task('actions_call_drill').runner.table;
      final illegal = table.copyWith(
        actionTrail: [
          ...table.actionTrail.take(table.actionTrail.length - 1),
          const Act0ActionTrailItemV1(label: 'Flop: BTN checks'),
        ],
      );
      expect(flags(illegal, 'checks facing 1 BB'), isTrue);
    });

    test('rejects naming a winner while another live hand is hidden', () {
      final table = task('showdown_tie_drill').runner.table;
      final multiway = mapSeat(table, 'bb', (s) => reseat(s, folded: false));
      expect(flags(multiway, 'bb is live in the history but out'), isFalse);
      expect(flags(multiway, 'bb is out in the history but live'), isTrue);
    });

    // The independent PR343 review's five exact falsifiers.
    List<Act0ActionTrailItemV1> swap(
      Act0TableStateV1 t,
      Map<String, String> changes,
    ) => [
      for (final a in t.actionTrail)
        Act0ActionTrailItemV1(label: changes[a.label] ?? a.label),
    ];

    test('rejects a non-all-in opening bet below one big blind', () {
      final t = task('actions_call_drill').runner.table;
      final bad = mapSeat(
        t.copyWith(
          potLabel: 'Pot 4.5 BB',
          toCallLabel: 'To call 0.5 BB',
          actionTrail: swap(t, {'Flop: HJ bets 1 BB': 'Flop: HJ bets 0.5 BB'}),
        ),
        'hj',
        (s) => reseat(
          s,
          bet: const Act0SeatBetStateV1(
            kind: Act0SeatBetKindV1.bet,
            label: 'HJ',
            amountLabel: '0.5 BB',
          ),
        ),
      );
      expect(flags(bad, 'below the minimum 1 BB bet'), isTrue);
    });

    test('rejects a preflop raise to 1.5 BB over a 1 BB blind', () {
      final t = task('cards_ranks_suits_private_board').runner.table;
      final bad = t.copyWith(
        potLabel: 'Pot 4.5 BB',
        actionTrail: swap(t, {
          'CO opens 2.5 BB': 'CO opens 1.5 BB',
          'BTN calls 2.5 BB': 'BTN calls 1.5 BB',
        }),
      );
      expect(flags(bad, 'below the minimum raise to 2 BB'), isTrue);
    });

    test('rejects an explicit backward street prefix', () {
      final t = task('turn_river_changes_w5_turn_hits').runner.table;
      final bad = t.copyWith(
        actionTrail: [
          ...t.actionTrail,
          const Act0ActionTrailItemV1(label: 'Flop: BTN checks'),
        ],
      );
      expect(flags(bad, 'goes back to an earlier street'), isTrue);
    });

    test('rejects actions after the end-of-trail marker', () {
      final t = task('actions_call_drill').runner.table;
      final bad = t.copyWith(
        actionTrail: [
          ...t.actionTrail,
          const Act0ActionTrailItemV1(label: 'UTG bets 100 BB'),
        ],
      );
      expect(flags(bad, 'follows the end of the trail'), isTrue);
    });

    test('rejects a showdown hand face up without two real cards', () {
      final t = task('showdown_tie_drill').runner.table;
      final bad = mapSeat(
        t,
        'co',
        (s) => Act0SeatStateV1(
          seatId: s.seatId,
          seatLabel: s.seatLabel,
          displayName: s.displayName,
          hasActed: true,
          cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        ),
      );
      expect(flags(bad, 'co is face up without two real cards'), isTrue);
    });

    // Stack, shove, ante and scope counterexamples.
    test('rejects a shove without an authored all-in stack', () {
      final t = task('w9_bubble_table_risk_transfer').runner.table;
      final bad = t.copyWith(
        seats: [
          for (final s in t.seats)
            s.seatId == 'bb'
                ? Act0SeatStateV1(
                    seatId: s.seatId,
                    seatLabel: s.seatLabel,
                    displayName: s.displayName,
                    isBigBlind: true,
                    hasActed: true,
                    holeCards: s.holeCards,
                    stackLabel: '50 BB',
                    currentBetLabel: s.currentBetLabel,
                    bet: s.bet,
                  )
                : s,
        ],
      );
      expect(flags(bad, 'is not an all-in'), isTrue);
    });

    test('rejects a raise that reopens action after a short all-in', () {
      final t = task('w9_bubble_table_risk_transfer').runner.table;
      final bad = t.copyWith(
        actionTrail: [
          ...swap(t, {'BB shoves to 18 BB': 'BB shoves to 3 BB'}),
          const Act0ActionTrailItemV1(label: 'BTN raises to 8 BB'),
        ],
      );
      expect(flags(bad, 'raises after a short all-in'), isTrue);
    });

    test('rejects antes posted after the action starts', () {
      final t = task('w11_trigger_small_price_continue').runner.table;
      final bad = t.copyWith(
        actionTrail: [
          ...t.actionTrail.skip(1).take(1),
          t.actionTrail.first,
          ...t.actionTrail.skip(2),
        ],
      );
      expect(flags(bad, 'must come before any action'), isTrue);
    });

    test('notes are never executed; the same text as an action is', () {
      final t = task('w12_revenge_raise_trap').runner.table;
      expect(act0TableLedgerForV1(t).isCertified, isTrue);
      final asAction = t.copyWith(
        actionTrail: [
          for (final a in t.actionTrail) Act0ActionTrailItemV1(label: a.label),
        ],
      );
      expect(
        act0TableLedgerForV1(asAction).status,
        Act0TableLedgerStatusV1.narrative,
      );
    });

    test('rejects an orientation frame that shows an action', () {
      final t = task('what_poker_is_pot_stack').runner.table;
      expect(t.scope, Act0TableScopeV1.orientation);
      final bad = mapSeat(
        t.copyWith(
          actionTrail: [
            ...t.actionTrail,
            const Act0ActionTrailItemV1(label: 'UTG folds'),
          ],
        ),
        'utg',
        (s) => reseat(s, folded: true),
      );
      expect(flags(bad, 'shows only seats and posted blinds'), isTrue);
    });

    test('rejects a side pot that Hero could win or a wrong total', () {
      final t = task('what_poker_is_side_pot_intro').runner.table;
      final c = t.chipExplanation!;
      final heroInSide = t.copyWith(
        chipExplanation: Act0ChipExplanationV1(
          contributions: c.contributions,
          allInSeatIds: c.allInSeatIds,
          foldedSeatIds: c.foldedSeatIds,
          pots: [
            c.pots.first,
            const Act0PotClaimV1(
              amountBb: 60,
              eligibleSeatIds: {'btn', 'co', 'bb'},
            ),
          ],
        ),
      );
      expect(flags(heroInSide, 'pot 2 can be won by'), isTrue);
      final allIn = task('what_poker_is_all_in_meaning').runner.table;
      final wrongTotal = allIn.copyWith(potLabel: 'Pot 40 BB');
      expect(flags(wrongTotal, 'does not show the pots'), isTrue);
    });

    test('rejects a card shown twice', () {
      final t = task('showdown_tie_drill').runner.table;
      final bad = mapSeat(
        t,
        'co',
        (s) => Act0SeatStateV1(
          seatId: s.seatId,
          seatLabel: s.seatLabel,
          displayName: s.displayName,
          hasActed: true,
          holeCards: t.heroCards,
          cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        ),
      );
      expect(flags(bad, 'appears twice'), isTrue);
    });
  });
}
