class HighlightEngineV1 {
  const HighlightEngineV1();

  static Map<String, Object?> compute({
    required double screenWidth,
    required double screenHeight,
    required bool isUserTurn,
    required bool potIsContested,
  }) {
    return {
      "present": true,
      "highlights": {
        "user_turn": {
          "active": isUserTurn,
          "pulse_strength": isUserTurn ? 0.9 : 0.0,
          "elevation": isUserTurn ? 2 : 0,
        },
        "pot_contested": {
          "active": potIsContested,
          "glow_strength": potIsContested ? 0.6 : 0.0,
          "elevation": potIsContested ? 1 : 0,
        },
      },
      "stage": 1,
    };
  }

  static Map<String, Object?> computeSurface({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "stage": "highlight_v2",
      "surface": {"width": screenWidth, "height": screenHeight},
      "signals": {"user_turn": false, "pot_contested": false},
    };
  }
}
