class TableAnimationV1 {
  const TableAnimationV1();

  static Map<String, Object?> plan({
    required bool userTurn,
    required bool potContested,
  }) {
    return {
      "present": true,
      "animations": {
        "user_turn_pulse": {
          "enabled": userTurn,
          "frequency_hz": userTurn ? 1.2 : 0.0,
          "amplitude": userTurn ? 0.8 : 0.0,
        },
        "pot_glow": {
          "enabled": potContested,
          "intensity": potContested ? 0.6 : 0.0,
          "decay_ms": potContested ? 240 : 0,
        },
      },
      "animation_rules": {
        "chip_move": {
          "duration_ms": 160,
          "curve": "ease_out",
          "overshoot": 0.04,
        },
        "card_flip": {
          "duration_ms": 190,
          "curve": "ease_in_out",
          "perspective": 0.015,
        },
        "highlight_pulse": {
          "duration_ms": 750,
          "amplitude": 0.12,
          "curve": "linear",
        },
      },
      "timings": {"entry_delay_ms": 40, "stagger_step_ms": 30},
      "stage": 2,
    };
  }

  static Map<String, Object?> compute({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "stage": "table_animation_v2",
      "surface": {"width": screenWidth, "height": screenHeight},
    };
  }
}
