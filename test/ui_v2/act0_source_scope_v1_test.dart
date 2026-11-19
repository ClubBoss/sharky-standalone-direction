import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

Act0LessonTaskV1 _task(String id) => [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons) ...lesson.taskList,
].singleWhere((task) => task.taskId == id);

const _newW01OrderContextIds = <String>{
  'blinds_first_actor',
  'blinds_last_actor',
  'blinds_postflop_button',
  'blinds_review',
  'positions_utg',
  'positions_late_seat',
  'positions_early_late',
  'positions_review',
};

const _asm05NewTaskIds = <String>{
  'asm05_new_known_holes_turn_call_10',
  'asm05_new_known_holes_turn_call_40',
};

Iterable<Act0LessonTaskV1> _world5To8Tasks() sync* {
  for (final world in Act0ShellStateV1.sample.worlds) {
    if (world.worldNumber < 5 || world.worldNumber > 8) continue;
    for (final lesson in world.lessons) {
      yield* lesson.taskList;
    }
  }
}

void main() {
  test('orientation cannot become a played replay from an active seat', () {
    // Real accepted-main negative: these posted blinds were consumerSafe even
    // though the authored job is identifying the first preflop seat.
    final table = _task('positions_button').runner.table.copyWith(
      activeSeatId: 'utg',
      actionTrail: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      ],
    );
    expect(table.scope, Act0TableScopeV1.orientation);
    expect(
      act0StreetReplayFromTableV1(table)?.isConsumerSafe ?? false,
      isFalse,
    );
  });

  test(
    'an explanation cannot become a played replay from action-like notes',
    () {
      // Explicitly synthetic mutation of a real explanation, not a legal hand.
      // Classification must survive text/actor changes instead of being inferred
      // from whether the parser happens to understand its labels.
      final table = _task('what_poker_is_all_in_meaning').runner.table.copyWith(
        activeSeatId: 'btn',
        actionTrail: const [
          Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
          Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        ],
      );
      expect(
        act0StreetReplayFromTableV1(table)?.isConsumerSafe ?? false,
        isFalse,
      );
    },
  );

  test('370 authored contexts preserve legacy scopes and two ASM05 snapshots', () {
    const orientationIds = <String>{
      'first_table_guide_shared_cards_repair',
      'what_poker_is_theory',
      'what_poker_is_find_hero',
      'what_poker_is_pot_stack',
      'what_poker_is_win_ways',
      'what_poker_is_live_win_transfer',
      'what_poker_is_review',
      'cards_ranks_suits_theory',
      'cards_ranks_suits_rank_drill',
      'cards_ranks_suits_suit_drill',
      'blinds_theory',
      'blinds_posts_drill',
      'blinds_first_actor',
      'blinds_last_actor',
      'blinds_button_moves',
      'blinds_review',
      'positions_theory',
      'positions_button',
      'positions_utg',
      'positions_cutoff',
      'positions_late_seat',
      'positions_early_late',
      'positions_review',
      'position_six_seats_positions_theory',
      'position_six_seats_positions_utg',
      'position_six_seats_hj_co_contrast',
      'position_six_seats_positions_cutoff',
      'position_six_seats_positions_button',
      'position_six_seats_sb_recognition',
      'position_six_seats_bb_recognition',
      'position_six_seats_position_repair_seat_id_btn',
      'position_six_seats_position_repair_seat_id_utg',
      'position_six_seats_positions_review',
      'button_advantage_button_intro',
      'button_advantage_find_button',
      'button_advantage_button_vs_cutoff',
      'button_advantage_button_recap',
      'early_vs_late_w2_position_intro',
      'early_vs_late_w2_late_position',
      'early_vs_late_w2_early_position',
      'early_vs_late_early_pressure_choice',
      'early_vs_late_position_repair_utg_players_behind',
      'early_vs_late_w2_position_recap',
      'same_hand_different_seat_w3_same_hand_intro',
      'same_hand_different_seat_w3_same_hand_recap',
      'position_apply_intro',
      'position_checkpoint_position_checkpoint_intro',
    };
    const explanationIds = <String>{
      'what_poker_is_all_in_meaning',
      'what_poker_is_matched_chips_transfer',
      'same_hand_different_seat_position_repair_same_hand_different_seat',
      'what_poker_is_side_pot_intro',
      'w12_bad_call_good_result',
    };
    const rangeSignals = <String, String>{
      'w6_turn_shift_bucket': 'range_bucket_shift',
      'w6_wet_board_repair': 'board_texture_change',
    };
    const conceptualSignals = <String, String>{
      'w12_bad_call_good_result': 'process_over_outcome',
    };
    const w4TurnPriceIds = <String>{
      'w4_price_intro',
      'w4_good_price_call',
      'w4_bad_price_fold',
      'w4_cheap_price_marginal_call',
      'w4_big_price_marginal_fold',
      'w4_price_recap',
      'w4_checkpoint_price',
      'w4_checkpoint_table_price',
    };
    const w4NumericHistoryIds = <String>{
      'w4_bad_bluff',
      'w4_bluff_intro',
      'w4_bluff_pressure',
      'w4_bluff_purpose',
      'w4_bluff_recap',
      'w4_checkpoint_intro',
      'w4_checkpoint_review',
      'w4_checkpoint_value',
      'w4_half_pot_bet',
      'w4_pot_bet',
      'w4_protection_bet',
      'w4_protection_check',
      'w4_protection_intro',
      'w4_protection_recap',
      'w4_purpose_intro',
      'w4_purpose_recap',
      'w4_sizing_intro',
      'w4_sizing_recap',
      'w4_small_bet',
      'w4_value_bet',
      'w4_value_intro',
      'w4_value_missed',
      'w4_value_purpose',
      'w4_value_recap',
    };
    // The reviewed W11 projection repair explicitly separates these authored
    // trails into preflop/flop/turn actions; no other history is newly admitted.
    const w11ExplicitStreetHistoryIds = <String>{
      'w11_trigger_small_price_continue',
      'w11_trigger_bad_price_fold',
    };
    const w12ExplicitFlopHistoryIds = <String>{
      'w12_revenge_raise_trap',
      'w12_checkpoint_full_loop_line',
    };
    final tasks = [
      for (final w in Act0ShellStateV1.sample.worlds)
        for (final l in w.lessons) ...l.taskList,
    ];
    expect(tasks, hasLength(370));
    expect(tasks.map((task) => task.taskId).toSet(), hasLength(370));
    final newTasks = tasks
        .where((task) => _asm05NewTaskIds.contains(task.taskId))
        .toList(growable: false);
    expect(newTasks.map((task) => task.taskId), _asm05NewTaskIds);
    expect(
      tasks.where((task) => !_asm05NewTaskIds.contains(task.taskId)),
      hasLength(368),
    );
    for (final task in newTasks) {
      expect(task.phase, Act0LessonPhaseV1.drill);
      expect(task.resolvedTaskFamily, Act0TaskFamilyV1.decision);
      expect(
        task.tablePresentation,
        Act0TaskTablePresentationV1.stablePractice,
      );
      expect(task.runner.lessonId, 'decision_over_outcome');
      final table = task.runner.table;
      expect(table.scope, Act0TableScopeV1.playedHand);
      expect(table.streetLabel, 'Turn');
      expect(table.activeSeatId, 'bb');
      expect(table.heroSeatId, 'bb');
      expect(table.actionTrail.first.label, 'Preflop: SB posts 0.5 BB');
      // The current replay and choreography parsers do not admit this
      // preflop-prefixed authored ledger. Test their real disposition rather
      // than excluding these played-hand contexts from consumer coverage.
      final replay = act0StreetReplayFromTableV1(table);
      expect(replay, isNotNull, reason: task.taskId);
      expect(replay!.currentStreet, Act0StreetReplayStreetV1.turn);
      expect(replay.completeness, Act0StreetReplayCompletenessV1.insufficient);
      expect(replay.steps, isEmpty);
      expect(replay.isConsumerSafe, isFalse);
      expect(act0TableChoreographyPlanForTableV1(table), isNull);
    }
    expect(orientationIds, hasLength(47));
    expect(explanationIds, hasLength(5));
    expect(conceptualSignals, hasLength(1));
    expect(explanationIds, containsAll(conceptualSignals.keys));
    var played = 0;
    var legacyPlayed = 0;
    final historyConsumers = <String>{};
    for (final task in tasks) {
      final table = task.runner.table;
      final expected = _newW01OrderContextIds.contains(task.taskId)
          ? Act0TableScopeV1.playedHand
          : orientationIds.contains(task.taskId)
          ? Act0TableScopeV1.orientation
          : explanationIds.contains(task.taskId)
          ? Act0TableScopeV1.explanation
          : Act0TableScopeV1.playedHand;
      expect(table.scope, expected, reason: task.taskId);
      expect(table.copyWith(centerLabel: 'A different cue').scope, expected);
      if (expected == Act0TableScopeV1.playedHand) {
        played++;
        if (!_asm05NewTaskIds.contains(task.taskId)) legacyPlayed++;
        final replay = act0StreetReplayFromTableV1(table);
        if (replay?.isConsumerSafe == true) historyConsumers.add(task.taskId);
        if (rangeSignals.containsKey(task.taskId)) {
          expect(task.runner.feedbackSignalId, rangeSignals[task.taskId]);
          expect(table.boardCards, hasLength(4));
          expect(replay?.isConsumerSafe, isTrue, reason: task.taskId);
        }
        if (task.taskId == 'w4_protection_check') {
          // The hand is a closed observational snapshot, not a current turn.
          expect(table.activeSeatId, anyOf(isNull, isEmpty));
          expect(
            table.seats.singleWhere((s) => s.seatId == 'bb').hasActed,
            isTrue,
          );
          expect(
            table.seats.singleWhere((s) => s.seatId == 'btn').hasActed,
            isTrue,
          );
          expect(table.potLabel, 'Pot 6 BB');
          expect(table.actionTrail.map((a) => a.label), [
            'SB blind 0.5 BB',
            'BB blind 1 BB',
            'UTG folds',
            'HJ folds',
            'CO folds',
            'BTN raises 2.75 BB',
            'SB folds',
            'BB calls 2.75 BB',
            'Flop: BB checks',
            'BTN checks',
          ]);
          expect(replay?.currentStreet, Act0StreetReplayStreetV1.flop);
          expect(replay?.currentDecisionActor, isEmpty);
          expect(
            replay?.completeness,
            Act0StreetReplayCompletenessV1.insufficient,
          );
          expect(replay?.steps, isEmpty);
          expect(replay?.isConsumerSafe, isFalse);
          expect(act0TableChoreographyPlanForTableV1(table), isNull);
        } else if (w12ExplicitFlopHistoryIds.contains(task.taskId)) {
          expect(replay?.isConsumerSafe, isTrue, reason: task.taskId);
          final latest = replay!.steps.last;
          expect(latest.street, Act0StreetReplayStreetV1.flop);
          expect(latest.actionSummary, 'CO bets 2 BB');
          expect(latest.potAtStreet, 'Pot 10 BB');
          expect(table.toCallLabel, 'To call 2 BB');
        } else if (w4TurnPriceIds.contains(task.taskId)) {
          expect(replay?.isConsumerSafe, isTrue, reason: task.taskId);
          expect(replay?.currentStreet, Act0StreetReplayStreetV1.turn);
          expect(table.activeSeatId, 'btn', reason: task.taskId);
          expect(replay?.currentDecisionActor, 'Hero', reason: task.taskId);
          expect(
            replay?.steps.last.potAtStreet,
            table.potLabel,
            reason: task.taskId,
          );
          final wager = table.seats.singleWhere((seat) => seat.bet != null);
          expect(
            wager.seatId,
            task.taskId == 'w4_checkpoint_table_price' ? 'bb' : 'hj',
          );
          expect(table.seats.where((seat) => seat.isInHand), hasLength(2));
          expect(table.seats.every((seat) => seat.isOccupied), isTrue);
        } else if (w4NumericHistoryIds.contains(task.taskId)) {
          expect(replay?.isConsumerSafe, isTrue, reason: task.taskId);
          expect(
            replay?.currentStreet,
            Act0StreetReplayStreetV1.flop,
            reason: task.taskId,
          );
          expect(
            replay?.steps.map((step) => step.actorLabel).toList(),
            <String>['SB', 'BB', 'UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB', 'BB'],
            reason: task.taskId,
          );
        }
      } else {
        expect(act0StreetReplayFromTableV1(table), isNull, reason: task.taskId);
        expect(
          act0TableChoreographyPlanForTableV1(table),
          isNull,
          reason: task.taskId,
        );
        if (expected == Act0TableScopeV1.explanation) {
          expect(
            table.actionTrail.every((item) => item.isNote),
            isTrue,
            reason: task.taskId,
          );
          final conceptualSignal = conceptualSignals[task.taskId];
          if (conceptualSignal != null) {
            expect(
              task.runner.feedbackSignalId,
              conceptualSignal,
              reason: task.taskId,
            );
            expect(table.heroCards, isEmpty, reason: task.taskId);
            expect(table.boardCards, isEmpty, reason: task.taskId);
            expect(table.actionTrail, isEmpty, reason: task.taskId);
            expect(
              table.activeSeatId,
              anyOf(isNull, isEmpty),
              reason: task.taskId,
            );
            expect(table.streetLabel, isEmpty, reason: task.taskId);
            expect(table.potLabel, isEmpty, reason: task.taskId);
            expect(table.toCallLabel, isEmpty, reason: task.taskId);
            expect(table.seats.where((seat) => seat.isActive), isEmpty);
          }
        } else {
          if (task.taskId == 'first_table_guide_shared_cards_repair') {
            expect(table.boardCards, hasLength(3));
            expect(table.heroCards, hasLength(2));
            expect(table.potLabel, isEmpty);
            expect(table.actionTrail, isEmpty);
          } else if (task.taskId == 'button_advantage_button_recap') {
            expect(table.streetLabel, 'Flop');
            expect(table.boardCards, hasLength(3));
            expect(table.potLabel, 'Pot 6 BB');
            expect(table.actionTrail, isEmpty);
            expect(table.seats.where((seat) => seat.bet != null), isEmpty);
          } else {
            expect(table.boardCards, isEmpty, reason: task.taskId);
          }
          expect(
            table.actionTrail.every(
              (item) =>
                  RegExp(r'^(SB|BB) blind (0.5|1) BB$').hasMatch(item.label),
            ),
            isTrue,
            reason: task.taskId,
          );
        }
      }
    }
    expect(w4NumericHistoryIds, hasLength(24));
    expect(
      w4NumericHistoryIds.where((id) => id != 'w4_protection_check'),
      hasLength(23),
    );
    expect(_newW01OrderContextIds.intersection(orientationIds), hasLength(7));
    expect(legacyPlayed, 323);
    expect(played, 325); // Authored contexts, not certified replay histories.
    final expectedHistories = <String>{
      ..._newW01OrderContextIds,
      ...w4TurnPriceIds,
      ...w4NumericHistoryIds.where((id) => id != 'w4_protection_check'),
      ...w11ExplicitStreetHistoryIds,
      ...w12ExplicitFlopHistoryIds,
      // The newly authored Call frame now supplies its full blind prefix,
      // folds, street actions and positive remaining stacks.
      'actions_call_drill',
      // Explicit new zero-price Check histories, still six-player roles.
      'actions_legal_context',
      'actions_check_drill',
      // New complete folded-to-BTN frames; mechanical history only.
      'actions_theory',
      'actions_raise_drill',
      'actions_review',
      // New five-way limped-pot Fold context; no strategy certification.
      'actions_fold_drill',
      'fold_discipline_discipline_intro',
      'apply_hj_decision',
      // Existing approved first-hand and no-ante bubble source histories.
      'your_first_hand_flop',
      'your_first_hand_turn',
      'your_first_hand_river',
      'your_first_hand_action_trail',
      'w9_bubble_table_risk_transfer',
      for (final task in _world5To8Tasks())
        if (task.runner.table.scope == Act0TableScopeV1.playedHand &&
            (task.runner.table.activeSeatId ?? '').isNotEmpty)
          task.taskId,
    };
    expect(
      historyConsumers.difference(expectedHistories),
      isEmpty,
      reason: 'Only the explicit source histories should be consumer-safe.',
    );
    expect(
      expectedHistories.difference(historyConsumers),
      isEmpty,
      reason:
          'only explicitly enumerated source histories are consumer-safe; no whole-pot certification',
    );
  });

  test('W5–W8 banks and prices follow the recorded contributions', () {
    final snapshots = <String>{};
    final action = RegExp(
      r'^(?:(Flop|Turn|River): )?([A-Z0-9+]+) '
      r'(blind|raises|opens|calls|bets|checks|folds)(?: ([0-9.]+) BB)?$',
    );
    for (final task in _world5To8Tasks()) {
      final table = task.runner.table;
      if (table.scope != Act0TableScopeV1.playedHand) continue;
      final proof = act0BettingRoundOrderProofForTableV1(table);
      expect(
        proof.truth,
        Act0BettingRoundOrderTruthV1.consistent,
        reason: '${task.taskId}: ${proof.reason}',
      );
      final liveAmounts = <String, double>{};
      var collected = 0.0;
      for (final item in table.actionTrail.where((item) => !item.isNote)) {
        final match = action.firstMatch(item.label);
        expect(match, isNotNull, reason: '${task.taskId}: ${item.label}');
        if (match![1] != null) {
          collected += liveAmounts.values.fold(0.0, (sum, bb) => sum + bb);
          liveAmounts.clear();
        }
        if (match[4] case final amount?) {
          // An amount is the player's total commitment on that street.
          liveAmounts[match[2]!] = double.parse(amount);
        }
      }
      final livePot = liveAmounts.values.fold(0.0, (sum, bb) => sum + bb);
      final shownPot = double.parse(table.potLabel.split(' ')[1]);
      expect(shownPot, collected + livePot, reason: task.taskId);
      if (table.activeSeatId case final actor? when actor.isNotEmpty) {
        final highest = liveAmounts.values.fold(0.0, (a, b) => a > b ? a : b);
        final actorLabel = table.seats
            .singleWhere((s) => s.seatId == actor)
            .seatLabel;
        final price = highest - (liveAmounts[actorLabel] ?? 0);
        final shownPrice = table.toCallLabel.isEmpty
            ? 0.0
            : double.parse(table.toCallLabel.split(' ')[2]);
        expect(shownPrice, price, reason: task.taskId);
      }
      final snapshot = [
        table.tableFormat.name,
        for (final card in [...table.heroCards, ...table.boardCards])
          card.label,
        table.potLabel,
        for (final seat in table.seats) seat.stackLabel,
      ].join('|');
      expect(snapshots.add(snapshot), isTrue, reason: task.taskId);
    }
  });

  test('folded-to-BTN replay preserves all three prior folds', () {
    for (final id in [
      'actions_theory',
      'actions_raise_drill',
      'actions_review',
    ]) {
      final replay = act0StreetReplayFromTableV1(_task(id).runner.table);
      expect(replay?.isConsumerSafe, isTrue, reason: id);
      expect(replay?.currentStreet, Act0StreetReplayStreetV1.preflop);
      expect(replay?.currentDecisionActor, 'Hero');
      expect(replay?.heroPosition, 'BTN');
      expect(replay?.steps.map((step) => step.actorLabel), [
        'SB',
        'BB',
        'UTG',
        'HJ',
        'CO',
      ]);
      expect(replay?.steps.skip(2).map((step) => step.actionTypeLabel), [
        'folds',
        'folds',
        'folds',
      ]);
    }
  });

  test(
    'unclassified and note-only records fail closed; source indexes survive notes',
    () {
      final table = _task('w4_bluff_pressure').runner.table;
      expect(
        act0StreetReplayFromTableV1(
          table.copyWith(scope: Act0TableScopeV1.unclassified),
        ),
        isNull,
      );
      expect(
        act0TableChoreographyPlanForTableV1(
          table.copyWith(scope: Act0TableScopeV1.unclassified),
        ),
        isNull,
      );
      final withNotes = table.copyWith(
        actionTrail: const [
          Act0ActionTrailItemV1.note(label: 'River: BB bets 999 BB'),
          Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
          Act0ActionTrailItemV1.note(label: 'BB folds'),
          Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
          Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        ],
      );
      final replay = act0StreetReplayFromTableV1(withNotes)!;
      expect(replay.isConsumerSafe, isTrue);
      expect(replay.steps.map((s) => s.order), [1, 3, 4]);
      expect(
        act0StreetReplayFromTableV1(
          table.copyWith(
            actionTrail: const [
              Act0ActionTrailItemV1.note(label: 'BTN bets 2 BB'),
            ],
          ),
        ),
        isNull,
      );
    },
  );
}
