class V4RoutingFusionSynthesis {
  const V4RoutingFusionSynthesis();

  static Map<String, Object?> synthesize(Map<String, Object?>? fusionMerge) {
    if (fusionMerge == null || fusionMerge["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "fusion_synthesis_colors": fusionMerge["fusion_v4_colors"],
      "fusion_synthesis_typography": fusionMerge["fusion_v4_typography"],
      "fusion_synthesis_spacing": fusionMerge["fusion_v4_spacing"],
      "fusion_synthesis_motion": fusionMerge["fusion_v4_motion"],
      "fusion_synthesis_elevation": fusionMerge["fusion_v4_elevation"],
      "fusion_synthesis_stage": 3,
    };
  }
}
