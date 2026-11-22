/// Exact W6 additions and historical choice contracts.
const w6NewChoiceContractV1 = <String, List<List<Object?>>>{
  "w6_continuation_bet_intro": [],
  "w6_continuation_bet_dry_size": [
    ["bet_two", "2 BB", true, "correct", "2 BB"],
    ["bet_six", "6 BB", false, "wrong", "2 BB"],
    ["bet_nine", "9 BB", false, "wrong", "2 BB"],
  ],
  "w6_continuation_bet_value_size": [
    ["bet_one_five", "1.5 BB", false, "suboptimal", "3 BB"],
    ["bet_six", "6 BB", false, "wrong", "3 BB"],
    ["bet_three", "3 BB", true, "correct", "3 BB"],
  ],
  "w6_continuation_bet_wet_check": [
    ["bet_small", "Bet 2 BB", false, "wrong", "Check"],
    ["check", "Check", true, "correct", "Check"],
    ["bet_large", "Bet 6 BB", false, "wrong", "Check"],
  ],
};

const w6CurrentChoiceContractV1 = <String, List<List<Object?>>>{
  "w6_value_dry_board": [
    ["value", "Bet for value", true, "correct", "Bet for value"],
    ["bluff", "Bet as a bluff", false, "wrong", "Bet for value"],
    ["missed", "Check because you missed", false, "wrong", "Bet for value"],
  ],
  "w6_turn_shift_bucket": [
    ["always_value", "Bet for value", false, "wrong", "Check behind"],
    ["never_changes", "Bet as another bluff", false, "wrong", "Check behind"],
    ["slide_missed", "Check behind", true, "correct", "Check behind"],
  ],
  "w6_suited_offsuit_weight_compare": [
    [
      "ak_suited",
      "12 suited, 4 offsuit",
      false,
      "wrong",
      "4 suited, 12 offsuit",
    ],
    [
      "ak_offsuit",
      "4 suited, 12 offsuit",
      true,
      "correct",
      "4 suited, 12 offsuit",
    ],
    [
      "same_weight",
      "8 suited, 8 offsuit",
      false,
      "wrong",
      "4 suited, 12 offsuit",
    ],
  ],
  "w6_checkpoint_table_combo_weight": [
    [
      "pair_nines",
      "6 AK offsuit, 12 pairs",
      false,
      "wrong",
      "12 AK offsuit, 6 pairs",
    ],
    [
      "ak_offsuit",
      "12 AK offsuit, 6 pairs",
      true,
      "correct",
      "12 AK offsuit, 6 pairs",
    ],
    [
      "same_weight",
      "9 AK offsuit, 9 pairs",
      false,
      "wrong",
      "12 AK offsuit, 6 pairs",
    ],
  ],
};

const preW6ChoiceContractV1 = <String, List<List<Object?>>>{
  "w6_value_dry_board": [
    ["value", "Value", true, "correct", "Value"],
    ["bluff", "Bluff candidate", false, "wrong", "Value"],
    ["missed", "Missed", false, "wrong", "Value"],
  ],
  "w6_turn_shift_bucket": [
    [
      "always_value",
      "It turns into value right away",
      false,
      "wrong",
      "It can slide toward missed",
    ],
    [
      "never_changes",
      "The bucket stays fixed after the flop",
      false,
      "wrong",
      "It can slide toward missed",
    ],
    [
      "slide_missed",
      "It can slide toward missed",
      true,
      "correct",
      "It can slide toward missed",
    ],
  ],
  "w6_suited_offsuit_weight_compare": [
    ["ak_suited", "A-K suited", false, "wrong", "A-K offsuit"],
    ["ak_offsuit", "A-K offsuit", true, "correct", "A-K offsuit"],
    [
      "same_weight",
      "They have the same combo count",
      false,
      "wrong",
      "A-K offsuit",
    ],
  ],
  "w6_checkpoint_table_combo_weight": [
    ["pair_nines", "Pocket nines", false, "wrong", "A-K offsuit"],
    ["ak_offsuit", "A-K offsuit", true, "correct", "A-K offsuit"],
    ["same_weight", "They have the same weight", false, "wrong", "A-K offsuit"],
  ],
};

const w6MovedToRangeReadingV1 = <String>{
  "range_checkpoint_intro",
  "range_checkpoint_value",
  "range_checkpoint_board_fit",
  "range_checkpoint_combos",
};
