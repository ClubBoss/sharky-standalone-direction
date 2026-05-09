class V4RoutingMergeV3 {
  const V4RoutingMergeV3();

  static Map<String, Object?> merge(Map<String, Object?>? synthesisV2) {
    if (synthesisV2 == null || synthesisV2["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "merged_v3_colors": synthesisV2["synthesis_v2_colors"],
      "merged_v3_typography": synthesisV2["synthesis_v2_typography"],
      "merged_v3_spacing": synthesisV2["synthesis_v2_spacing"],
      "merged_v3_motion": synthesisV2["synthesis_v2_motion"],
      "merged_v3_elevation": synthesisV2["synthesis_v2_elevation"],
      "routing_merge_v3_stage": 3,
    };
  }
}
