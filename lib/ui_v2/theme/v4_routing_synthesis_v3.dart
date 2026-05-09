class V4RoutingSynthesisV3 {
  const V4RoutingSynthesisV3();

  static Map<String, Object?> synthesize(Map<String, Object?>? mergedV3) {
    if (mergedV3 == null || mergedV3["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "synthesis_v3_colors": mergedV3["merged_v3_colors"],
      "synthesis_v3_typography": mergedV3["merged_v3_typography"],
      "synthesis_v3_spacing": mergedV3["merged_v3_spacing"],
      "synthesis_v3_motion": mergedV3["merged_v3_motion"],
      "synthesis_v3_elevation": mergedV3["merged_v3_elevation"],
      "routing_synthesis_v3_stage": 3,
    };
  }
}
