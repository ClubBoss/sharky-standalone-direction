class HighlightRendererV1 {
  const HighlightRendererV1();

  static Map<String, Object?> stage({
    required Map<String, Object?> highlightGroup,
  }) {
    return {
      "present": true,
      "stage": "highlight_renderer_v1",
      "highlight_ok": highlightGroup.isNotEmpty,
      "render_plan": {
        "active_spot": highlightGroup["active_spot"],
        "highlight_zones": highlightGroup["zones"],
        "motion": highlightGroup["motion"],
        "elevation": highlightGroup["elevation"],
      },
      "highlight_stage_ready": false,
    };
  }
}
