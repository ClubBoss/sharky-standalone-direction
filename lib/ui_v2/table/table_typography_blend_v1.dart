class TableTypographyBlendV1 {
  const TableTypographyBlendV1();

  static Map<String, Object?> blend({
    required bool userTurn,
    required bool importantActionAvailable,
  }) {
    return {
      "present": true,
      "typography": {
        "card_rank_scale": userTurn ? 1.10 : 1.00,
        "action_label_weight": importantActionAvailable ? "bold" : "regular",
        "hint_opacity": userTurn ? 1.0 : 0.5,
      },
      "stage": 1,
    };
  }

  static Map<String, Object?> compute({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "stage": "table_typography_v2",
      "surface": {"width": screenWidth, "height": screenHeight},
      "typography": {
        "card_rank_scale": 1.0,
        "action_label_weight": "regular",
        "hint_opacity": 1.0,
      },
    };
  }
}
