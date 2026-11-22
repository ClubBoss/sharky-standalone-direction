const y5dNewChoicesV1 = <String, List<List<Object?>>>{
  "w10_same_hand_river_overbluff": [
    ["fold", "Fold", false, "wrong", "Call"],
    ["call", "Call", true, "correct", "Call"],
  ],
  "w10_same_hand_river_underbluff": [
    ["fold", "Fold", true, "correct", "Fold"],
    ["call", "Call", false, "wrong", "Fold"],
  ],
  "w11_y5d_stop_after_three": [
    ["choice_0", "End the session", true, "correct", "End the session"],
    [
      "choice_1",
      "Play until one buy-in returns",
      false,
      "wrong",
      "End the session",
    ],
    ["choice_2", "Move up one limit", false, "wrong", "End the session"],
  ],
  "w11_y5d_stay_at_nl10": [
    ["choice_0", "Stay at NL10", true, "correct", "Stay at NL10"],
    ["choice_1", "Move up to NL25", false, "wrong", "Stay at NL10"],
    ["choice_2", "Move down to NL5", false, "wrong", "Stay at NL10"],
  ],
  "w11_y5d_top_up_to_100": [
    ["choice_0", "Add 27 BB", true, "correct", "Add 27 BB"],
    ["choice_1", "Add 73 BB", false, "wrong", "Add 27 BB"],
    ["choice_2", "Add nothing", false, "wrong", "Add 27 BB"],
  ],
  "w11_y5d_two_pot_call": [
    ["call", "Call", true, "correct", "Call"],
    ["fold", "Fold", false, "wrong", "Call"],
  ],
  "w11_y5d_guided_river_read": [
    [
      "choice_0",
      "Above the call price",
      true,
      "correct",
      "Above the call price",
    ],
    [
      "choice_1",
      "Below the call price",
      false,
      "wrong",
      "Above the call price",
    ],
  ],
  "w11_y5d_river_read_transfer": [
    ["call", "Call", false, "wrong", "Fold"],
    ["fold", "Fold", true, "correct", "Fold"],
  ],
  "w12_y5d_guided_range_read": [
    [
      "choice_0",
      "Above the call price",
      false,
      "wrong",
      "Below the call price",
    ],
    [
      "choice_1",
      "Below the call price",
      true,
      "correct",
      "Below the call price",
    ],
  ],
  "w12_y5d_range_read_transfer": [
    ["call", "Call", true, "correct", "Call"],
    ["fold", "Fold", false, "wrong", "Call"],
  ],
};

const y5dLessonByTaskV1 = <String, (String, String)>{
  "w10_same_hand_river_overbluff": ("world_10", "adjust_one_lever"),
  "w10_same_hand_river_underbluff": (
    "world_10",
    "player_adjustment_checkpoint",
  ),
  "w11_y5d_stop_after_three": ("world_11", "session_plan_basics"),
  "w11_y5d_stay_at_nl10": ("world_11", "session_plan_basics"),
  "w11_y5d_top_up_to_100": ("world_11", "session_plan_basics"),
  "w11_y5d_two_pot_call": ("world_11", "post_session_review_loop"),
  "w11_y5d_guided_river_read": ("world_11", "post_session_review_loop"),
  "w11_y5d_river_read_transfer": ("world_11", "post_session_review_loop"),
  "w12_y5d_guided_range_read": ("world_12", "confidence_river_discipline"),
  "w12_y5d_range_read_transfer": ("world_12", "confidence_river_discipline"),
};

const y5dHypotheticalTaskIdsV1 = {
  "w11_y5d_stop_after_three",
  "w11_y5d_stay_at_nl10",
  "w11_y5d_top_up_to_100",
};
