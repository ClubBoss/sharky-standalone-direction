class V4RoutingFusionMerge {
  const V4RoutingFusionMerge();

  static Map<String, Object?> merge(Map<String, Object?>? synthesisV3) {
    if (synthesisV3 == null || synthesisV3["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "fusion_v4_colors": synthesisV3["synthesis_v3_colors"],
      "fusion_v4_typography": synthesisV3["synthesis_v3_typography"],
      "fusion_v4_spacing": synthesisV3["synthesis_v3_spacing"],
      "fusion_v4_motion": synthesisV3["synthesis_v3_motion"],
      "fusion_v4_elevation": synthesisV3["synthesis_v3_elevation"],
      "fusion_merge_stage": 2,
    };
  }
}
