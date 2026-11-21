/// World 3 task identities and exact changes used by the historical census.
const w3NewChoiceContractV1 = <String, List<List<Object?>>>{
  "position_six_seats_position_order_reason": [
    ["cutoff_first", "CO, HJ, BTN", false, "wrong", "HJ, CO, BTN"],
    ["seat_order", "HJ, CO, BTN", true, "correct", "HJ, CO, BTN"],
    ["button_before_cutoff", "HJ, BTN, CO", false, "wrong", "HJ, CO, BTN"],
  ],
  "button_advantage_button_order_reason": [
    [
      "sees_first_action",
      "BTN sees UTG act first",
      true,
      "correct",
      "BTN sees UTG act first",
    ],
    [
      "smaller_price",
      "BTN pays less for the same bet",
      false,
      "wrong",
      "BTN sees UTG act first",
    ],
    [
      "owns_first_turn",
      "BTN takes the first flop turn",
      false,
      "wrong",
      "BTN sees UTG act first",
    ],
  ],
  "w3_play_from_blinds_intro": [],
  "w3_play_from_blinds_small_blind_fold": [
    ["call", "Call 2 BB", false, "wrong", "Fold"],
    ["fold", "Fold", true, "correct", "Fold"],
    ["raise", "Reraise to 10 BB", false, "wrong", "Fold"],
  ],
  "w3_play_from_blinds_small_blind_raise": [
    ["raise", "Reraise to 10 BB", true, "correct", "Reraise to 10 BB"],
    ["call", "Call 2 BB", false, "wrong", "Reraise to 10 BB"],
    ["fold", "Fold", false, "wrong", "Reraise to 10 BB"],
  ],
  "w3_play_from_blinds_big_blind_price": [
    ["two_five", "2.5 BB", false, "wrong", "1.5 BB"],
    ["one", "1 BB", false, "wrong", "1.5 BB"],
    ["one_five", "1.5 BB", true, "correct", "1.5 BB"],
  ],
  "w3_play_from_blinds_big_blind_defend": [
    [
      "fold",
      "The price is too high",
      false,
      "wrong",
      "The chance to win clears the price",
    ],
    [
      "call",
      "The chance to win clears the price",
      true,
      "correct",
      "The chance to win clears the price",
    ],
    [
      "posted_free",
      "The flop is free after posting BB",
      false,
      "wrong",
      "The chance to win clears the price",
    ],
  ],
};

const w3AppendedWrongChoicesV1 = <String, String>{
  "position_six_seats_positions_utg": "bb",
  "position_six_seats_hj_co_contrast": "utg",
  "position_six_seats_positions_cutoff": "btn",
  "position_six_seats_positions_button": "sb",
  "position_six_seats_sb_recognition": "btn",
  "position_six_seats_bb_recognition": "utg",
  "position_six_seats_position_repair_seat_id_btn": "bb",
  "position_six_seats_position_repair_seat_id_utg": "sb",
  "position_six_seats_positions_review": "blinds_and_button_only",
  "button_advantage_button_intro": "co",
  "button_advantage_find_button": "sb",
  "button_advantage_button_last": "bb",
  "button_advantage_button_vs_cutoff": "hj",
  "button_advantage_position_repair_btn_last_postflop": "bb",
  "early_vs_late_w2_position_intro": "hj",
  "early_vs_late_w2_late_position": "co",
  "early_vs_late_w2_early_position": "co",
  "early_vs_late_early_pressure_choice": "position_returns_chips",
  "early_vs_late_position_repair_utg_players_behind": "only_hj",
  "early_vs_late_late_info_choice": "smaller_blinds",
  "same_hand_different_seat_w3_same_hand_intro": "seat_and_action",
  "same_hand_different_seat_w3_same_hand_call": "opener_and_button",
  "same_hand_different_seat_same_hand_early_fold": "call",
  "same_hand_different_seat_same_hand_late_open": "fold",
  "same_hand_different_seat_w3_same_hand_recap": "seat_blind_only",
  "position_apply_intro": "co",
  "position_apply_late_open": "fold",
  "position_apply_early_fold": "call",
  "position_apply_hj_fold": "call",
  "position_checkpoint_position_checkpoint_intro": "hj",
  "position_checkpoint_position_checkpoint_late_open": "fold",
  "position_checkpoint_position_checkpoint_early_fold": "call",
  "position_checkpoint_position_checkpoint_btn_call": "raise",
  "position_checkpoint_position_checkpoint_review": "fold",
};

const w3CurrentReasonChoicesV1 = <String, List<List<Object?>>>{
  "position_apply_recap": [
    [
      "raise",
      "AJo can put the blinds to a decision",
      true,
      "correct",
      "AJo can put the blinds to a decision",
    ],
    [
      "call",
      "A limp puts the blinds under more pressure",
      false,
      "wrong",
      "AJo can put the blinds to a decision",
    ],
    [
      "off_chart",
      "AJo opens from HJ and CO alone",
      false,
      "wrong",
      "AJo can put the blinds to a decision",
    ],
  ],
};

const preW3ReasonChoicesV1 = <String, List<List<Object?>>>{
  "position_apply_recap": [
    ["raise", "Raise", true, "correct", "Raise"],
    ["call", "Call", false, "suboptimal", "Raise"],
  ],
};

// New distractors on familiar repair tasks have no independent repair target.
const w3AppendedRepairChoiceIdsV1 = <String>{
  'world_3/position_six_seats/position_six_seats_position_repair_seat_id_btn/bb',
  'world_3/position_six_seats/position_six_seats_position_repair_seat_id_utg/sb',
  'world_3/button_advantage/button_advantage_position_repair_btn_last_postflop/bb',
  'world_3/early_vs_late/early_vs_late_position_repair_utg_players_behind/only_hj',
};
