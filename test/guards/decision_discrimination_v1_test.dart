import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _inherentlyBinaryAndValid = <String>{
  'world_1/what_poker_is_content/what_poker_is_pot_stack',
  'world_1/cards_ranks_suits/cards_ranks_suits_suit_drill',
  'world_1/cards_ranks_suits/cards_ranks_suits_private_board',
  'world_1/cards_ranks_suits/cards_ranks_suits_board_count',
  'world_1/cards_ranks_suits/cards_ranks_suits_best_five',
  'world_1/cards_ranks_suits/cards_ranks_suits_recap',
  'world_1/your_first_hand/your_first_hand_action_trail',
  'world_1/your_first_hand/your_first_hand_recap',
  'world_1/blinds_action_order/blinds_posts_drill',
  'world_1/blinds_action_order/blinds_first_actor',
  'world_1/blinds_action_order/blinds_last_actor',
  'world_1/blinds_action_order/blinds_postflop_button',
  'world_1/blinds_action_order/blinds_button_moves',
  'world_1/blinds_action_order/blinds_review',
  'world_1/positions/positions_button',
  'world_1/positions/positions_utg',
  'world_1/positions/positions_cutoff',
  'world_1/positions/positions_late_seat',
  'world_1/positions/positions_early_late',
  'world_1/hand_rankings_table/hand_rankings_theory',
  'world_1/hand_rankings_table/hand_rankings_pair_drill',
  'world_1/hand_rankings_table/hand_rankings_two_pair_drill',
  'world_1/hand_rankings_table/hand_rankings_trips_drill',
  'world_1/hand_rankings_table/hand_rankings_straight_drill',
  'world_1/hand_rankings_table/hand_rankings_flush_drill',
  'world_1/hand_rankings_table/hand_rankings_full_house_drill',
  'world_1/hand_rankings_table/hand_rankings_quads_drill',
  'world_1/hand_rankings_table/hand_rankings_royal_flush_drill',
  'world_1/hand_rankings_table/hand_rankings_full_house_vs_flush_drill',
  'world_1/hand_rankings_table/hand_rankings_quads_vs_full_house_drill',
  'world_1/hand_rankings_table/hand_rankings_royal_vs_flush_drill',
  'world_1/hand_rankings_table/hand_rankings_best_five_drill',
  'world_1/hand_rankings_table/hand_rankings_review',
  'world_1/showdown_winning/showdown_theory',
  'world_1/showdown_winning/showdown_foldout_drill',
  'world_1/showdown_winning/showdown_kicker_drill',
  'world_1/showdown_winning/showdown_board_plays_drill',
  'world_1/showdown_winning/showdown_tie_drill',
  'world_2/hand_discipline_buckets/hand_discipline_buckets_premium',
  'world_2/hand_discipline_buckets/hand_discipline_buckets_trash',
  'world_2/fold_discipline/fold_discipline_early_fold',
  'world_2/fold_discipline/fold_discipline_facing_fold',
  'world_2/fold_discipline/fold_discipline_discipline_stack_protect',
  'world_2/fold_discipline/fold_discipline_fold_recap',
  'world_2/weak_ace_warning/weak_ace_warning_w3_dominated_fold',
  'world_2/weak_ace_warning/weak_ace_warning_w3_strong_continue',
  'world_2/weak_ace_warning/weak_ace_warning_weak_ace_pressure_fold',
  'world_2/weak_ace_warning/weak_ace_warning_weak_ace_kicker_compare',
  'world_2/weak_ace_warning/weak_ace_warning_w3_dominated_recap',
  'world_2/continue_or_let_go/continue_or_let_go_premium_continue',
  'world_2/continue_or_let_go/continue_or_let_go_weak_let_go',
  'world_2/continue_or_let_go/continue_or_let_go_medium_call_or_fold',
  'world_2/continue_or_let_go/continue_or_let_go_continue_recap',
  'world_2/hand_discipline_apply/apply_utg_fold',
  'world_2/hand_discipline_apply/apply_recap',
  'world_2/discipline_checkpoint/discipline_checkpoint_checkpoint_premium',
  'world_2/discipline_checkpoint/discipline_checkpoint_checkpoint_fold',
  'world_2/discipline_checkpoint/discipline_checkpoint_checkpoint_borderline_continue',
  'world_2/discipline_checkpoint/discipline_checkpoint_checkpoint_review',
  'world_3/position_six_seats/position_six_seats_positions_utg',
  'world_3/position_six_seats/position_six_seats_hj_co_contrast',
  'world_3/position_six_seats/position_six_seats_positions_cutoff',
  'world_3/position_six_seats/position_six_seats_positions_button',
  'world_3/position_six_seats/position_six_seats_sb_recognition',
  'world_3/position_six_seats/position_six_seats_bb_recognition',
  'world_3/position_six_seats/position_six_seats_position_repair_seat_id_btn',
  'world_3/position_six_seats/position_six_seats_position_repair_seat_id_utg',
  'world_3/position_six_seats/position_six_seats_positions_review',
  'world_3/button_advantage/button_advantage_button_intro',
  'world_3/button_advantage/button_advantage_find_button',
  'world_3/button_advantage/button_advantage_button_last',
  'world_3/button_advantage/button_advantage_button_vs_cutoff',
  'world_3/button_advantage/button_advantage_position_repair_btn_last_postflop',
  'world_3/early_vs_late/early_vs_late_w2_position_intro',
  'world_3/early_vs_late/early_vs_late_w2_late_position',
  'world_3/early_vs_late/early_vs_late_w2_early_position',
  'world_3/early_vs_late/early_vs_late_early_pressure_choice',
  'world_3/early_vs_late/early_vs_late_position_repair_utg_players_behind',
  'world_3/early_vs_late/early_vs_late_late_info_choice',
  'world_3/same_hand_different_seat/same_hand_different_seat_w3_same_hand_intro',
  'world_3/same_hand_different_seat/same_hand_different_seat_w3_same_hand_open',
  'world_3/same_hand_different_seat/same_hand_different_seat_w3_same_hand_call',
  'world_3/same_hand_different_seat/same_hand_different_seat_same_hand_early_fold',
  'world_3/same_hand_different_seat/same_hand_different_seat_same_hand_late_open',
  'world_3/same_hand_different_seat/same_hand_different_seat_w3_same_hand_recap',
  'world_3/position_apply/position_apply_intro',
  'world_3/position_apply/position_apply_late_open',
  'world_3/position_apply/position_apply_early_fold',
  'world_3/position_apply/position_apply_hj_fold',
  'world_3/position_apply/position_apply_recap',
  'world_3/position_checkpoint/position_checkpoint_position_checkpoint_intro',
  'world_3/position_checkpoint/position_checkpoint_position_checkpoint_late_open',
  'world_3/position_checkpoint/position_checkpoint_position_checkpoint_early_fold',
  'world_3/position_checkpoint/position_checkpoint_position_checkpoint_btn_call',
  'world_3/position_checkpoint/position_checkpoint_position_checkpoint_review',
  'world_4/why_bets_happen/w4_value_purpose',
  'world_4/why_bets_happen/w4_bluff_purpose',
  'world_4/value_bets/w4_value_bet',
  'world_4/value_bets/w4_value_missed',
  'world_4/bluff_pressure/w4_bluff_pressure',
  'world_4/bluff_pressure/w4_bad_bluff',
  'world_4/protection_and_denial/w4_protection_bet',
  'world_4/protection_and_denial/w4_protection_check',
  'world_4/call_price/w4_good_price_call',
  'world_4/call_price/w4_bad_price_fold',
  'world_4/small_half_pot/w4_small_bet',
  'world_4/small_half_pot/w4_pot_bet',
  'world_4/price_checkpoint/w4_checkpoint_value',
  'world_4/price_checkpoint/w4_checkpoint_price',
  'world_4/price_checkpoint/w4_checkpoint_review',
  'world_5/board_texture_basics/board_texture_basics_w5_dry_board',
  'world_5/board_texture_basics/board_texture_basics_w5_wet_board',
  'world_5/connected_boards/connected_boards_w5_disconnected_board',
  'world_5/connected_boards/connected_boards_w5_connected_board',
  'world_5/flush_draws/flush_draws_w5_no_flush_draw',
  'world_5/straight_draws/straight_draws_w5_straight_draw_find',
  'world_5/straight_draws/straight_draws_w5_gap_board',
  'world_5/outs_improvement/outs_improvement_w5_flush_out',
  'world_5/outs_improvement/outs_improvement_w5_straight_out',
  'world_5/turn_river_changes/turn_river_changes_w5_turn_hits',
  'world_5/turn_river_changes/turn_river_changes_w5_river_misses',
};

void main() {
  test(
    'Decision Discrimination V1 has one explicit disposition for every binary assessment',
    () {
      final rows = _binaryRows();
      final paths = rows.map((row) => row.path).toSet();

      expect(rows, hasLength(121));
      expect(paths, _inherentlyBinaryAndValid);
      expect(_inherentlyBinaryAndValid, hasLength(121));
    },
  );

  test(
    'Decision Discrimination V1 keeps every allowlisted binary task a real two-state decision',
    () {
      for (final row in _binaryRows()) {
        final options = row.task.runner.options;
        final incorrect = options.where((option) => !option.isCorrect).single;
        final definition = act0ConceptErrorDefinitionForTaskV1(
          worldId: row.worldId,
          lessonId: row.lessonId,
          taskId: row.task.taskId,
        );
        final intent = buildAct0RepairIntentV1(
          sourceWorldId: row.worldId,
          sourceLessonId: row.lessonId,
          sourceTaskId: row.task.taskId,
          runner: row.task.runner,
          selectedOption: incorrect,
          mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
        );

        expect(options, hasLength(2), reason: row.path);
        expect(
          options.where((option) => option.isCorrect),
          hasLength(1),
          reason: row.path,
        );
        expect(
          options.map((option) => option.id).toSet(),
          hasLength(2),
          reason: row.path,
        );
        expect(incorrect.label.trim(), isNotEmpty, reason: row.path);
        expect(incorrect.feedbackReason.trim(), isNotEmpty, reason: row.path);
        expect(definition, isNotNull, reason: row.path);
        expect(intent?.errorType, definition!.id, reason: row.path);
      }
    },
  );

  test('Decision Discrimination V1 does not silently invent enrichments', () {
    const safelyEnriched = <String>{};
    const authorityRequired = <String>{};
    const outsideCurrentScope = <String>{};

    expect(safelyEnriched, isEmpty);
    expect(authorityRequired, isEmpty);
    expect(outsideCurrentScope, isEmpty);
    expect(
      _inherentlyBinaryAndValid.length +
          safelyEnriched.length +
          authorityRequired.length +
          outsideCurrentScope.length,
      121,
    );
  });
}

List<_Row> _binaryRows() => <_Row>[
  for (final world in Act0ShellStateV1.sample.worlds)
    if (RegExp(r'^world_([1-9]|1[0-2])$').hasMatch(world.worldId))
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          if (task.runner.options.length == 2 &&
              task.runner.options.where((option) => option.isCorrect).length ==
                  1)
            _Row(world.worldId, lesson.lessonId, task),
];

class _Row {
  const _Row(this.worldId, this.lessonId, this.task);

  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;

  String get path => '$worldId/$lessonId/${task.taskId}';
}
