import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

Act0LessonTaskV1 _task(String id) => [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons) ...lesson.taskList,
].singleWhere((task) => task.taskId == id);

void main() {
  test('orientation cannot become a played replay from an active seat', () {
    // Real accepted-main negative: these posted blinds were consumerSafe even
    // though the authored job is identifying the first preflop seat.
    final table = _task('blinds_first_actor').runner.table;
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

  test('367 authored contexts keep the exact source-owned scope partition', () {
    const orientationIds = <String>{
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
    };
    final tasks = [
      for (final w in Act0ShellStateV1.sample.worlds)
        for (final l in w.lessons) ...l.taskList,
    ];
    expect(tasks, hasLength(367));
    expect(orientationIds, hasLength(46));
    expect(explanationIds, hasLength(4));
    var played = 0;
    var historyConsumers = 0;
    for (final task in tasks) {
      final table = task.runner.table;
      final expected = orientationIds.contains(task.taskId)
          ? Act0TableScopeV1.orientation
          : explanationIds.contains(task.taskId)
          ? Act0TableScopeV1.explanation
          : Act0TableScopeV1.playedHand;
      expect(table.scope, expected, reason: task.taskId);
      expect(table.copyWith(centerLabel: 'A different cue').scope, expected);
      if (expected == Act0TableScopeV1.playedHand) {
        played++;
        if (act0StreetReplayFromTableV1(table)?.isConsumerSafe == true)
          historyConsumers++;
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
        } else {
          expect(table.boardCards, isEmpty, reason: task.taskId);
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
    expect(played, 317); // Authored hand contexts, NOT 317 certified histories.
    expect(historyConsumers, 2); // Prior 22 minus 20 misclassified seat maps.
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
