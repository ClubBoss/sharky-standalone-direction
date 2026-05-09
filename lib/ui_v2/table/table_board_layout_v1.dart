class TableBoardLayoutV1 {
  const TableBoardLayoutV1();

  static Map<String, Object?> layout({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "table_center_zone": {
        "width": screenWidth * 0.60,
        "height": screenHeight * 0.45,
      },
      "table_top_zone": {"width": screenWidth, "height": screenHeight * 0.15},
      "table_bottom_zone": {
        "width": screenWidth,
        "height": screenHeight * 0.15,
      },
      "table_layout_stage": 1,
    };
  }
}
