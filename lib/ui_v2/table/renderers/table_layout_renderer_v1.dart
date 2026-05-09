class TableLayoutRendererV1 {
  const TableLayoutRendererV1();

  static Map<String, Object?> stage({
    required Map<String, Object?> layoutGroup,
  }) {
    final centerZone = (layoutGroup['table_center_zone'] as Map?)
        ?.cast<String, Object?>();
    return {
      "present": true,
      "stage": "table_layout_renderer_v1",
      "layout_ok": layoutGroup.isNotEmpty,
      "render_plan": {
        "width": centerZone?["width"],
        "height": centerZone?["height"],
        "top_zone": layoutGroup["table_top_zone"],
        "bottom_zone": layoutGroup["table_bottom_zone"],
      },
      "layout_stage_ready": false,
    };
  }
}
