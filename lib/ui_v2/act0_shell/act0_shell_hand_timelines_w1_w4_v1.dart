part of 'act0_shell_state_v1.dart';

typedef _AuthoredHistoryV1 = ({
  String? decisionSeat,
  List<(PokerStreet, String, Act0HandVerbV1, int, bool)> actions,
});

// B20 parser output from the canonical labels. Amounts are chips added in
// hundredths of a BB. The original trail retains learner-facing wording.
_AuthoredHistoryV1? _w1W4HistoryV1(String taskId) => switch (taskId) {
  'what_poker_is_theory' ||
  'what_poker_is_find_hero' ||
  'positions_theory' ||
  'positions_button' ||
  'positions_utg' ||
  'positions_cutoff' ||
  'blinds_missing_post_amount' ||
  'blinds_theory' ||
  'blinds_posts_drill' ||
  'blinds_first_actor' ||
  'blinds_button_moves' ||
  'blinds_review' ||
  'positions_early_late' ||
  'what_poker_is_pot_stack' ||
  'what_poker_is_win_ways' ||
  'what_poker_is_live_win_transfer' ||
  'what_poker_is_review' ||
  'apply_utg_fold' ||
  'position_six_seats_positions_theory' ||
  'position_six_seats_positions_utg' ||
  'position_six_seats_hj_co_contrast' ||
  'position_six_seats_positions_cutoff' ||
  'position_six_seats_position_order_reason' ||
  'position_six_seats_positions_button' ||
  'position_six_seats_sb_recognition' ||
  'position_six_seats_bb_recognition' ||
  'position_six_seats_position_repair_seat_id_btn' ||
  'position_six_seats_position_repair_seat_id_utg' ||
  'position_six_seats_positions_review' ||
  'button_advantage_button_intro' ||
  'button_advantage_find_button' ||
  'button_advantage_button_vs_cutoff' ||
  'early_vs_late_w2_position_intro' ||
  'early_vs_late_w2_late_position' ||
  'early_vs_late_w2_early_position' ||
  'early_vs_late_early_pressure_choice' ||
  'early_vs_late_position_repair_utg_players_behind' ||
  'early_vs_late_w2_position_recap' ||
  'same_hand_different_seat_w3_same_hand_intro' ||
  'same_hand_different_seat_w3_same_hand_recap' ||
  'position_apply_intro' ||
  'position_apply_early_fold' ||
  'position_checkpoint_position_checkpoint_intro' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
    ],
  ),
  'w1_chips_starting_pot' ||
  'blinds_pot_after_posts' ||
  'hand_discipline_buckets_premium' ||
  'continue_or_let_go_premium_continue' => const (
    decisionSeat: 'utg',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
    ],
  ),
  'w1_chips_matched_pot' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 250, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 150, false),
    ],
  ),
  'w1_chips_read_middle' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 325, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 225, false),
    ],
  ),
  'first_table_guide_first_decision' ||
  'fold_discipline_fold_recap' ||
  'weak_ace_warning_weak_ace_pressure_fold' ||
  'w2_narrow_three_bet_intro' ||
  'w2_narrow_three_bet_premium' ||
  'w2_narrow_three_bet_strong' ||
  'apply_recap' ||
  'same_hand_different_seat_w3_same_hand_call' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 250, false),
    ],
  ),
  'cards_ranks_suits_premium_decision' ||
  'fold_discipline_facing_fold' ||
  'weak_ace_warning_w3_dominated_fold' ||
  'weak_ace_warning_weak_ace_kicker_compare' ||
  'weak_ace_warning_w3_dominated_recap' ||
  'continue_or_let_go_weak_let_go' ||
  'continue_or_let_go_medium_call_or_fold' ||
  'continue_or_let_go_continue_recap' ||
  'w2_narrow_three_bet_medium' ||
  'discipline_checkpoint_checkpoint_borderline_continue' ||
  'discipline_checkpoint_checkpoint_review' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 250, false),
    ],
  ),
  'hand_rankings_find_the_match' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
    ],
  ),
  'hand_rankings_compare_ace_straights' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'co', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'blinds_last_actor' => const (
    decisionSeat: 'bb',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.call, 50, false),
    ],
  ),
  'blinds_postflop_button' ||
  'positions_late_seat' ||
  'positions_review' => const (
    decisionSeat: 'sb',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.call, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'positions_read_first_check' || 'w4_value_worse_call_seat' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'actions_theory' || 'actions_review' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'actions_legal_context' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 200, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 100, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'actions_check_drill' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.raise, 200, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 100, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'actions_call_chip_cost' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'bb', Act0HandVerbV1.bet, 200, false),
    ],
  ),
  'actions_fold_drill' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.call, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'sb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'utg', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.bet, 200, false),
    ],
  ),
  'actions_call_drill' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.call, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'sb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.bet, 100, false),
    ],
  ),
  'actions_raise_drill' || 'apply_btn_open' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'your_first_hand_preflop' ||
  'your_first_hand_private_cards_recheck' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 300, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 200, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'your_first_hand_flop' || 'your_first_hand_action_trail' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 300, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 200, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'your_first_hand_turn' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 300, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 200, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'your_first_hand_river' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 300, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 200, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.river, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'your_first_hand_showdown' || 'your_first_hand_recap' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 300, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 200, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.river, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.river, 'co', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'what_poker_is_all_in_meaning' ||
  'what_poker_is_matched_chips_transfer' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 2000, true),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.call, 2000, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'what_poker_is_side_pot_eligibility' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 1000, true),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 1000, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 900, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.bet, 500, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.call, 500, false),
    ],
  ),
  'showdown_best_hand_drill' || 'showdown_review' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 225, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.call, 225, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.river, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.river, 'co', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'hand_discipline_buckets_intro' ||
  'hand_discipline_buckets_medium' ||
  'hand_discipline_buckets_borderline' ||
  'hand_discipline_buckets_recap' ||
  'continue_or_let_go_continue_intro' ||
  'apply_intro' ||
  'discipline_checkpoint_checkpoint_intro' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'hand_discipline_buckets_strong' ||
  'discipline_checkpoint_checkpoint_premium' => const (
    decisionSeat: 'hj',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'fold_discipline_discipline_intro' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 100, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.call, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'sb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'utg', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.bet, 200, false),
    ],
  ),
  'fold_discipline_discipline_stack_protect' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 300, false),
    ],
  ),
  'weak_ace_warning_w3_strong_continue' ||
  'position_checkpoint_position_checkpoint_btn_call' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 250, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'w2_narrow_three_bet_fold' || 'w4_min_raise_preflop' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 300, false),
    ],
  ),
  'apply_hj_decision' || 'position_apply_hj_fold' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'discipline_checkpoint_checkpoint_fold' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 400, false),
    ],
  ),
  'same_hand_different_seat_position_repair_same_hand_different_seat' => const (
    decisionSeat: null,
    actions: [],
  ),
  'w3_play_from_blinds_intro' ||
  'w3_play_from_blinds_big_blind_price' ||
  'w3_play_from_blinds_big_blind_defend' => const (
    decisionSeat: 'bb',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.raise, 250, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'w3_play_from_blinds_small_blind_fold' ||
  'w3_play_from_blinds_small_blind_raise' ||
  'w3_play_from_blinds_small_blind_medium_raise' ||
  'w3_play_from_blinds_small_blind_medium_fold' => const (
    decisionSeat: 'sb',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.raise, 250, false),
    ],
  ),
  'w3_play_from_blinds_bvb_sb_open' => const (
    decisionSeat: 'sb',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
    ],
  ),
  'w3_play_from_blinds_bvb_bb_call' ||
  'w3_play_from_blinds_bvb_bb_repeat' => const (
    decisionSeat: 'bb',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.raise, 250, false),
    ],
  ),
  'w4_value_purpose' ||
  'w4_purpose_collect_value' ||
  'w4_purpose_recap' ||
  'w4_small_bet' ||
  'w4_pot_bet' ||
  'w4_value_intro' ||
  'w4_value_bet' ||
  'w4_value_recap' ||
  'w4_bluff_pressure' ||
  'w4_bluff_target_seat' ||
  'w4_protection_small_denial' ||
  'w4_protection_recap' ||
  'w4_checkpoint_review' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'w4_bluff_purpose' ||
  'w4_sizing_intro' ||
  'w4_half_pot_bet' ||
  'w4_sizing_recap' ||
  'w4_value_missed' ||
  'w4_bluff_intro' ||
  'w4_bluff_recap' ||
  'w4_checkpoint_intro' => const (
    decisionSeat: 'hj',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'w4_min_raise_postflop' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 300, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 200, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.bet, 400, false),
    ],
  ),
  'w4_price_intro' || 'w4_price_recap' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 225, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 225, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'hj', Act0HandVerbV1.bet, 200, false),
    ],
  ),
  'w4_good_price_call' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 275, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'hj', Act0HandVerbV1.bet, 100, false),
    ],
  ),
  'w4_bad_price_fold' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 275, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'hj', Act0HandVerbV1.bet, 700, false),
    ],
  ),
  'w4_price_find_bettor' => const (
    decisionSeat: 'bb',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.bet, 300, false),
    ],
  ),
  'w4_cheap_price_marginal_call' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 375, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 375, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'hj', Act0HandVerbV1.bet, 100, false),
    ],
  ),
  'w4_big_price_marginal_fold' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 275, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'hj', Act0HandVerbV1.bet, 600, false),
    ],
  ),
  'w4_protection_check' => const (
    decisionSeat: null,
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
    ],
  ),
  'w4_protection_guided_raise_read' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.bet, 300, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.raise, 900, false),
    ],
  ),
  'w4_protection_short_shove_price' => const (
    decisionSeat: 'co',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 175, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'co', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'bb', Act0HandVerbV1.bet, 600, true),
    ],
  ),
  'w4_checkpoint_price' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.raise, 275, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.call, 275, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.flop, 'hj', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'hj', Act0HandVerbV1.bet, 300, false),
    ],
  ),
  'w4_checkpoint_table_price' => const (
    decisionSeat: 'btn',
    actions: [
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.smallBlind, 50, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.bigBlind, 100, false),
      (PokerStreet.preflop, 'utg', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'hj', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'co', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'btn', Act0HandVerbV1.raise, 225, false),
      (PokerStreet.preflop, 'sb', Act0HandVerbV1.fold, 0, false),
      (PokerStreet.preflop, 'bb', Act0HandVerbV1.call, 125, false),
      (PokerStreet.flop, 'bb', Act0HandVerbV1.check, 0, false),
      (PokerStreet.flop, 'btn', Act0HandVerbV1.check, 0, false),
      (PokerStreet.turn, 'bb', Act0HandVerbV1.bet, 200, false),
    ],
  ),
  _ => null,
};
