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

  test('every table is certified or an exact, listed residual', () {
    final uncertified = <String, Act0TableLedgerStatusV1>{};
    var tableCount = 0;
    for (final t in tasks) {
      final tables = tablesOf(t);
      for (var i = 0; i < tables.length; i++) {
        tableCount += 1;
        final ledger = act0TableLedgerForV1(tables[i]);
        if (!ledger.isCertified) {
          uncertified['${t.taskId}#$i'] = ledger.status;
        }
      }
    }
    expect(tasks.length, 367);
    expect(tableCount, 367);
    expect(
      uncertified.keys.toSet().difference(_kResidualsV1.keys.toSet()),
      isEmpty,
      reason: 'New tables must carry a legal history the ledger certifies.',
    );
    expect(
      _kResidualsV1.keys.toSet().difference(uncertified.keys.toSet()),
      isEmpty,
      reason: 'A residual now certifies: remove it from the list.',
    );
    for (final entry in _kResidualsV1.entries) {
      expect(uncertified[entry.key], entry.value.$2, reason: entry.key);
    }
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
  });
}

enum _ResidualFamilyV1 {
  // BTN raises, BB calls, 6 BB flop: the SB's dead 0.5 BB makes 6.5 BB unless
  // BTN raises to 2.75 BB; the sizing answers key to a 6 BB pot. Owner choice.
  w4BtnVsBbSixBb,
  // Turn price spots quote an entering pot (6-9 BB) with no history; the
  // pot-odds feedback depends on those numbers.
  w4PriceSpots,
  w5Transfers,
  w6Transfers,
  w8DepthAndSidePot,
  w9Pressure,
  w10Transfer,
  w11Transfers,
  w12Transfers,
  w1AllIn,
  w3SeatComparison,
}

// Residual tables, unchanged from #341/#342. Each keeps its pre-ledger frame
// (see _act0OpenTableResidualV1) until its family gets an authored history.
const _kResidualsV1 = <String, (_ResidualFamilyV1, Act0TableLedgerStatusV1)>{
  'w10_table_value_vs_caller_transfer#0': (
    _ResidualFamilyV1.w10Transfer,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w11_trigger_bad_price_fold#0': (
    _ResidualFamilyV1.w11Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w11_trigger_small_price_continue#0': (
    _ResidualFamilyV1.w11Transfers,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w12_checkpoint_full_loop_line#0': (
    _ResidualFamilyV1.w12Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w12_pretty_hand_bad_price_fold#0': (
    _ResidualFamilyV1.w12Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w12_revenge_raise_trap#0': (
    _ResidualFamilyV1.w12Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'what_poker_is_all_in_meaning#0': (
    _ResidualFamilyV1.w1AllIn,
    Act0TableLedgerStatusV1.narrative,
  ),
  'what_poker_is_matched_chips_transfer#0': (
    _ResidualFamilyV1.w1AllIn,
    Act0TableLedgerStatusV1.narrative,
  ),
  'same_hand_different_seat_position_repair_same_hand_different_seat#0': (
    _ResidualFamilyV1.w3SeatComparison,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w4_bad_bluff#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_bluff_intro#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_bluff_pressure#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_bluff_purpose#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_bluff_recap#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_checkpoint_intro#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_checkpoint_review#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_checkpoint_value#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_half_pot_bet#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_pot_bet#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_protection_bet#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_protection_check#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_protection_intro#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_protection_recap#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_purpose_intro#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_purpose_recap#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_sizing_intro#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_sizing_recap#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_small_bet#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_value_bet#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_value_intro#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_value_missed#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_value_purpose#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_value_recap#0': (
    _ResidualFamilyV1.w4BtnVsBbSixBb,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_bad_price_fold#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_big_price_marginal_fold#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_cheap_price_marginal_call#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_checkpoint_price#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_checkpoint_table_price#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_checkpoint_table_purpose_price#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_good_price_call#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_price_intro#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w4_price_recap#0': (
    _ResidualFamilyV1.w4PriceSpots,
    Act0TableLedgerStatusV1.conflict,
  ),
  'flush_draws_w5_flush_draw_recheck_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.unexplained,
  ),
  'flush_draws_w5_made_hand_vs_flush_draw_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.unexplained,
  ),
  'outs_improvement_w5_clean_vs_risky_out_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'outs_improvement_w5_table_outs_flush_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'outs_improvement_w5_table_outs_straight_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'straight_draws_w5_gutshot_contrast_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.unexplained,
  ),
  'turn_river_changes_w5_river_draw_story_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'turn_river_changes_w5_street_change_intro#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.unexplained,
  ),
  'turn_river_changes_w5_street_repair#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.unexplained,
  ),
  'turn_river_changes_w5_turn_texture_shift_transfer#0': (
    _ResidualFamilyV1.w5Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w6_board_pair_strength_compare#0': (
    _ResidualFamilyV1.w6Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w6_checkpoint_table_best_five#0': (
    _ResidualFamilyV1.w6Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w6_checkpoint_table_combo_weight#0': (
    _ResidualFamilyV1.w6Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w6_kicker_showdown_compare#0': (
    _ResidualFamilyV1.w6Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w6_table_value_line_transfer#0': (
    _ResidualFamilyV1.w6Transfers,
    Act0TableLedgerStatusV1.conflict,
  ),
  'w6_turn_pressure_shift_transfer#0': (
    _ResidualFamilyV1.w6Transfers,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w7_top_pair_spr2_transfer#0': (
    _ResidualFamilyV1.w8DepthAndSidePot,
    Act0TableLedgerStatusV1.unexplained,
  ),
  'w7_top_pair_spr8_transfer#0': (
    _ResidualFamilyV1.w8DepthAndSidePot,
    Act0TableLedgerStatusV1.unexplained,
  ),
  'what_poker_is_side_pot_intro#0': (
    _ResidualFamilyV1.w8DepthAndSidePot,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w9_bubble_table_risk_transfer#0': (
    _ResidualFamilyV1.w9Pressure,
    Act0TableLedgerStatusV1.narrative,
  ),
  'w9_m_ratio_table_window_transfer#0': (
    _ResidualFamilyV1.w9Pressure,
    Act0TableLedgerStatusV1.narrative,
  ),
};
