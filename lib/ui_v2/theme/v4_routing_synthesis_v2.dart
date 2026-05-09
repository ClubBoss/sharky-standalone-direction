class V4RoutingSynthesisV2 {
  const V4RoutingSynthesisV2();

  static Map<String, Object?> synthesize(Map<String, Object?>? merged) {
    if (merged == null || merged["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "synthesis_v2_colors": merged["merged_v2_colors"],
      "synthesis_v2_typography": merged["merged_v2_typography"],
      "synthesis_v2_spacing": merged["merged_v2_spacing"],
      "synthesis_v2_motion": merged["merged_v2_motion"],
      "synthesis_v2_elevation": merged["merged_v2_elevation"],
      "synthesis_v2_stage": 2,
    };
  }
}
