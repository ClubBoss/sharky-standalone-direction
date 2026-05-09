class ActionButtonsV1 {
  const ActionButtonsV1();

  static Map<String, Object?> build({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "buttons": {
        "fold": {
          "width": screenWidth * 0.28,
          "height": screenHeight * 0.08,
          "priority": 1,
        },
        "call": {
          "width": screenWidth * 0.28,
          "height": screenHeight * 0.08,
          "priority": 2,
        },
        "raise": {
          "width": screenWidth * 0.28,
          "height": screenHeight * 0.08,
          "priority": 3,
        },
      },
      "stage": 1,
    };
  }
}
