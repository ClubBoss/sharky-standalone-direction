class TableInteractionV1 {
  const TableInteractionV1();

  static Map<String, Object?> compute({
    required double screenWidth,
    required double screenHeight,
    required Map<String, Object?> buttonsLayout,
    required bool userTurn,
  }) {
    return {
      "present": true,
      "tap_zones": {
        "fold": {
          "x1": 0,
          "y1": screenHeight * 0.72,
          "x2": screenWidth * 0.33,
          "y2": screenHeight * 0.80,
        },
        "call": {
          "x1": screenWidth * 0.33,
          "y1": screenHeight * 0.72,
          "x2": screenWidth * 0.66,
          "y2": screenHeight * 0.80,
        },
        "raise": {
          "x1": screenWidth * 0.66,
          "y1": screenHeight * 0.72,
          "x2": screenWidth * 1.00,
          "y2": screenHeight * 0.80,
        },
      },
      "interaction_zones": {
        "table_tap": {"radius_pct": 0.18, "cooldown_ms": 120},
        "action_button": {"hitbox_pct": 0.22, "cooldown_ms": 90},
        "card_focus": {"radius_pct": 0.14, "sensitivity": 0.75},
      },
      "gesture_rules": {
        "tap": {"min_interval_ms": 80, "max_interval_ms": 300},
        "long_press": {"duration_ms": 420},
        "swipe": {"min_velocity": 0.35, "angle_tolerance_deg": 22},
      },
      "hints": {
        "show_hint": userTurn,
        "preferred_action": userTurn ? "call" : null,
      },
      "stage": 2,
    };
  }
}
