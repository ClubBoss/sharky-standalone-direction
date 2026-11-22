/// Newly authored choices in Y5b. Legacy identity checks keep their original
/// fingerprints and check these rows against their own authoring contract.
const y5bNewChoicesV1 = <String, List<List<Object?>>>{
  'w4_protection_guided_raise_read': [
    ['choice_0', 'Weaker kings', false, 'wrong', 'Sets'],
    ['choice_1', 'Sets', true, 'correct', 'Sets'],
    ['choice_2', 'Weak hands with no pair', false, 'wrong', 'Sets'],
  ],
  'w4_protection_short_shove_price': [
    ['fold', 'Fold', false, 'wrong', 'Call'],
    ['choice_1', 'Both earn the same', false, 'wrong', 'Call'],
    ['call', 'Call', true, 'correct', 'Call'],
  ],
  'w5_semi_bluff_intro': [],
  'w5_semi_bluff_flush_draw': [
    ["check", "Check", false, "wrong", "Bet 3 BB"],
    ["choice_1", "Bet 3 BB", true, "correct", "Bet 3 BB"],
    ["choice_2", "Bet 1 BB", false, "wrong", "Bet 3 BB"],
  ],
  'w5_semi_bluff_combo_draw': [
    ["choice_0", "Bet 1 BB", false, "wrong", "Check"],
    ["check", "Check", true, "correct", "Check"],
    ["choice_2", "Bet 3 BB", false, "wrong", "Check"],
  ],
  'w5_semi_bluff_short_draw': [
    ["check", "Check", true, "correct", "Check"],
    ["choice_1", "Bet 2 BB", false, "wrong", "Check"],
    ["choice_2", "Bet 1 BB", false, "wrong", "Check"],
  ],
  'connected_boards_w5_raise_read_guided': [
    ["choice_0", "One small pair", false, "wrong", "A made flush"],
    ["choice_1", "A made flush", true, "correct", "A made flush"],
    [
      "choice_2",
      "Unpaired cards without a spade",
      false,
      "wrong",
      "A made flush",
    ],
  ],
  'connected_boards_w5_raise_read_repeat': [
    ["call", "Call", false, "wrong", "Fold"],
    ["fold", "Fold", true, "correct", "Fold"],
    ["choice_2", "Raise to 18 BB", false, "wrong", "Fold"],
  ],
};
