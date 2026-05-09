class V4FusionThemeMerge {
  const V4FusionThemeMerge();

  static Map<String, Object?> merge(Map<String, Object?>? fusionSynthesis) {
    if (fusionSynthesis == null || fusionSynthesis["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "fusion_theme_v5_colors": fusionSynthesis["fusion_synthesis_colors"],
      "fusion_theme_v5_typography":
          fusionSynthesis["fusion_synthesis_typography"],
      "fusion_theme_v5_spacing": fusionSynthesis["fusion_synthesis_spacing"],
      "fusion_theme_v5_motion": fusionSynthesis["fusion_synthesis_motion"],
      "fusion_theme_v5_elevation":
          fusionSynthesis["fusion_synthesis_elevation"],
      "fusion_theme_merge_stage": 2,
    };
  }
}
