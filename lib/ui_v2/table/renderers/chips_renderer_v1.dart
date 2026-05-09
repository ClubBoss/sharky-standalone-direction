class ChipsRendererV1 {
  const ChipsRendererV1();

  static Map<String, Object?> stage({
    required Map<String, Object?> chipsGroup,
  }) {
    return {
      "present": true,
      "stage": "chips_renderer_v1",
      "chips_ok": chipsGroup.isNotEmpty,
      "render_plan": {
        "chip_stack": chipsGroup["chip_stack"],
        "pot_value": chipsGroup["pot_value"],
        "geometry": chipsGroup["geometry"],
        "denominations": chipsGroup["denominations"],
      },
      "chips_stage_ready": false,
    };
  }
}
