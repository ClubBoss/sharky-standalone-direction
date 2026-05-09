class TableStressTestSuiteV1 {
  const TableStressTestSuiteV1();

  static Map<String, Object?> run({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "stress_stage": 1,
      "metrics": {"render_cycles": 150, "max_layers": 12, "max_depth": 8},
      "scenarios": [
        {"id": "layout_pressure", "weight": 0.40},
        {"id": "chip_pressure", "weight": 0.25},
        {"id": "highlight_spike", "weight": 0.20},
        {"id": "animation_burst", "weight": 0.15},
      ],
    };
  }
}
