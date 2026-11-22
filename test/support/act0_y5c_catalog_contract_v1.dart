const y5cNewChoicesV1 = <String, List<List<Object?>>>{
  "w7_read_visible_card_guided": [
    ["choice_0", "T♣8♣", false, "wrong", "2♠2♦"],
    ["choice_1", "2♠2♦", true, "correct", "2♠2♦"],
    ["choice_2", "9♥9♦", false, "wrong", "2♠2♦"],
  ],
  "w7_read_visible_card_call": [
    ["fold", "Fold", false, "wrong", "Call"],
    ["call", "Call", true, "correct", "Call"],
  ],
  "short_stack_spots_intro": [],
  "short_stack_spots_draw_deep": [
    ["fold", "Fold", false, "wrong", "Call"],
    ["call", "Call", true, "correct", "Call"],
  ],
  "short_stack_spots_draw_shallow": [
    ["call", "Call", false, "wrong", "Fold"],
    [
      "choice_1",
      "Raise to 7 BB (puts the bettor all-in)",
      false,
      "wrong",
      "Fold",
    ],
    ["fold", "Fold", true, "correct", "Fold"],
  ],
  "short_stack_spots_set_mine": [
    ["fold", "Fold", true, "correct", "Fold"],
    ["call", "Call", false, "wrong", "Fold"],
  ],
  "short_stack_spots_value_cap": [
    ["check", "Check", false, "wrong", "Bet 6 BB (puts BB all-in)"],
    ["choice_1", "Bet 3 BB", false, "suboptimal", "Bet 6 BB (puts BB all-in)"],
    [
      "choice_2",
      "Bet 6 BB (puts BB all-in)",
      true,
      "correct",
      "Bet 6 BB (puts BB all-in)",
    ],
  ],
  "short_stack_spots_all_in_price": [
    ["call", "Call", true, "correct", "Call"],
    ["fold", "Fold", false, "wrong", "Call"],
  ],
  "short_stack_spots_side_pot": [
    ["choice_0", "One pot of 70 BB", false, "wrong", "Main 30 BB, side 40 BB"],
    [
      "choice_1",
      "Main 30 BB, side 40 BB",
      true,
      "correct",
      "Main 30 BB, side 40 BB",
    ],
    [
      "choice_2",
      "Main 20 BB, side 50 BB",
      false,
      "wrong",
      "Main 30 BB, side 40 BB",
    ],
  ],
  "w8_big_hand_turn_fold": [
    ["call", "Call", false, "wrong", "Fold"],
    ["fold", "Fold", true, "correct", "Fold"],
  ],
  "w8_big_hand_river_fold": [
    ["fold", "Fold", true, "correct", "Fold"],
    ["call", "Call", false, "wrong", "Fold"],
  ],
  "w8_guided_short_read": [
    ["choice_0", "Missed straight draws", false, "wrong", "A pair of jacks"],
    ["choice_1", "Ace-high", false, "wrong", "A pair of jacks"],
    ["choice_2", "A pair of jacks", true, "correct", "A pair of jacks"],
  ],
  "w8_unguided_short_read": [
    ["choice_0", "Bet 2 BB", false, "wrong", "Bet 4 BB (puts BB all-in)"],
    ["check", "Check", false, "wrong", "Bet 4 BB (puts BB all-in)"],
    [
      "choice_2",
      "Bet 4 BB (puts BB all-in)",
      true,
      "correct",
      "Bet 4 BB (puts BB all-in)",
    ],
  ],
  "w9_bubble_read_guided": [
    [
      "choice_0",
      "Weaker aces",
      false,
      "wrong",
      "Tens or better and strong aces",
    ],
    [
      "choice_1",
      "Tens or better and strong aces",
      true,
      "correct",
      "Tens or better and strong aces",
    ],
    [
      "choice_2",
      "Sevens through nines",
      false,
      "wrong",
      "Tens or better and strong aces",
    ],
  ],
  "w9_bubble_read_decision": [
    ["call", "Call", false, "wrong", "Fold"],
    ["fold", "Fold", true, "correct", "Fold"],
  ],
};

const y5cLessonByTaskV1 = <String, (String, String)>{
  'w7_read_visible_card_guided': (
    'world_7',
    'w7_visible_cards_range_checkpoint',
  ),
  'w7_read_visible_card_call': ('world_7', 'w7_visible_cards_range_checkpoint'),
  'short_stack_spots_intro': ('world_8', 'short_stack_spots'),
  'short_stack_spots_draw_deep': ('world_8', 'short_stack_spots'),
  'short_stack_spots_draw_shallow': ('world_8', 'short_stack_spots'),
  'short_stack_spots_set_mine': ('world_8', 'short_stack_spots'),
  'short_stack_spots_value_cap': ('world_8', 'short_stack_spots'),
  'short_stack_spots_all_in_price': ('world_8', 'short_stack_spots'),
  'short_stack_spots_side_pot': ('world_8', 'short_stack_spots'),
  'w8_big_hand_turn_fold': ('world_8', 'effective_stack_basics'),
  'w8_big_hand_river_fold': ('world_8', 'same_hand_different_depth'),
  'w8_guided_short_read': ('world_8', 'format_pressure'),
  'w8_unguided_short_read': ('world_8', 'format_pressure'),
  'w9_bubble_read_guided': ('world_9', 'survival_pressure_basics'),
  'w9_bubble_read_decision': ('world_9', 'tournament_pressure_checkpoint'),
};

int y5cTasksInWorldV1(int world) =>
    y5cLessonByTaskV1.values.where((row) => row.$1 == 'world_$world').length;

final y5cDrillCountV1 = y5cNewChoicesV1.values
    .where((rows) => rows.isNotEmpty)
    .length;
