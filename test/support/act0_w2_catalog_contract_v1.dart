/// Explicit Q9 task IDs and the W2 changes to the historical choice census.
const w2Q9ChoiceContractV1 = <String, List<List<Object?>>>{
  "w2_narrow_three_bet_intro": [],
  "w2_narrow_three_bet_premium": [
    ["raise", "Reraise to 7.5 BB", true, "correct", "Reraise to 7.5 BB"],
    ["call", "Call 2.5 BB", false, "wrong", "Reraise to 7.5 BB"],
    ["fold", "Fold", false, "wrong", "Reraise to 7.5 BB"],
  ],
  "w2_narrow_three_bet_strong": [
    ["raise", "Reraise to 7.5 BB", false, "wrong", "Call 2.5 BB"],
    ["call", "Call 2.5 BB", true, "correct", "Call 2.5 BB"],
    ["fold", "Fold", false, "wrong", "Call 2.5 BB"],
  ],
  "w2_narrow_three_bet_medium": [
    [
      "premium",
      "QJs is in the top group",
      false,
      "wrong",
      "QJs is Medium and you act after CO",
    ],
    [
      "call",
      "QJs is Medium and you act after CO",
      true,
      "correct",
      "QJs is Medium and you act after CO",
    ],
    [
      "unopened",
      "Nobody has raised yet",
      false,
      "wrong",
      "QJs is Medium and you act after CO",
    ],
  ],
  "w2_narrow_three_bet_fold": [
    ["raise", "Reraise to 9 BB", false, "wrong", "Fold"],
    ["call", "Call 3 BB", false, "wrong", "Fold"],
    ["fold", "Fold", true, "correct", "Fold"],
  ],
};

const w2AppendedWrongChoicesV1 = <String, String>{
  "fold_discipline_early_fold": "call",
  "fold_discipline_discipline_stack_protect": "raise",
  "fold_discipline_fold_recap": "raise",
  "weak_ace_warning_w3_dominated_fold": "raise",
  "weak_ace_warning_w3_strong_continue": "raise",
  "weak_ace_warning_weak_ace_pressure_fold": "raise",
  "weak_ace_warning_weak_ace_kicker_compare": "ace_and_king_equal",
  "weak_ace_warning_w3_dominated_recap": "raise",
  "continue_or_let_go_premium_continue": "strong",
  "continue_or_let_go_weak_let_go": "raise",
  "continue_or_let_go_medium_call_or_fold": "raise",
  "continue_or_let_go_continue_recap": "raise",
  "apply_utg_fold": "call",
  "discipline_checkpoint_checkpoint_premium": "strong",
  "discipline_checkpoint_checkpoint_fold": "raise",
  "discipline_checkpoint_checkpoint_borderline_continue": "raise",
  "discipline_checkpoint_checkpoint_review": "fix_size",
};

const w2CurrentReasonChoicesV1 = <String, List<List<Object?>>>{
  "hand_discipline_buckets_recap": [
    [
      "suit_only",
      "The suits and your chip color",
      false,
      "wrong",
      "Your hand group and your seat",
    ],
    [
      "bucket_and_seat",
      "Your hand group and your seat",
      true,
      "correct",
      "Your hand group and your seat",
    ],
    [
      "blinds_only",
      "The blind amounts and dealer puck",
      false,
      "wrong",
      "Your hand group and your seat",
    ],
  ],
  "fold_discipline_facing_fold": [
    [
      "call",
      "Position makes this jack strong enough to call",
      false,
      "wrong",
      "CO already raised and J8o is weak",
    ],
    [
      "fold",
      "CO already raised and J8o is weak",
      true,
      "correct",
      "CO already raised and J8o is weak",
    ],
    [
      "raise_for_pot",
      "The existing pot makes a reraise safe",
      false,
      "wrong",
      "CO already raised and J8o is weak",
    ],
  ],
  "apply_recap": [
    [
      "fold",
      "A3o can lose to a higher ace when both pair",
      true,
      "correct",
      "A3o can lose to a higher ace when both pair",
    ],
    [
      "call",
      "The ace makes your kicker unimportant",
      false,
      "wrong",
      "A3o can lose to a higher ace when both pair",
    ],
    [
      "seat_guarantee",
      "Sitting in CO makes your kicker play higher",
      false,
      "wrong",
      "A3o can lose to a higher ace when both pair",
    ],
  ],
};

const preW2ReasonChoicesV1 = <String, List<List<Object?>>>{
  "hand_discipline_buckets_recap": [],
  "fold_discipline_facing_fold": [
    ["fold", "Fold", true, "correct", "Fold"],
    ["call", "Call", false, "wrong", "Fold"],
  ],
  "apply_recap": [
    ["fold", "Fold", true, "correct", "Fold"],
    ["call", "Call", false, "wrong", "Fold"],
  ],
};
