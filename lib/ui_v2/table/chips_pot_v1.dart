class ChipsPotV1 {
  const ChipsPotV1();

  static Map<String, Object?> build({
    required double screenWidth,
    required double screenHeight,
    required int potAmount,
    required Map<String, int> playerStacks,
  }) {
    return {
      "present": true,
      "pot": {
        "amount": potAmount,
        "center_x": screenWidth * 0.50,
        "center_y": screenHeight * 0.40,
      },
      "stacks": playerStacks.map(
        (pid, amt) => MapEntry(pid, {
          "amount": amt,
          "pos_x": screenWidth * 0.10,
          "pos_y": screenHeight * 0.80,
        }),
      ),
      "stage": 1,
    };
  }

  static Map<String, Object?> compute({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "stage": "chips_pot_v2",
      "surface": {"width": screenWidth, "height": screenHeight},
      "pot_anchor": {"x": screenWidth * 0.50, "y": screenHeight * 0.40},
      "stacks_anchor": {"x": screenWidth * 0.10, "y": screenHeight * 0.80},
    };
  }
}
