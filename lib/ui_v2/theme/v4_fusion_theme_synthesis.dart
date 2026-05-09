class V4FusionThemeSynthesis {
  const V4FusionThemeSynthesis();

  static Map<String, Object?> synthesize(
    Map<String, Object?>? fusionThemeMerge,
  ) {
    if (fusionThemeMerge == null || fusionThemeMerge["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "fusion_theme_synthesis_colors":
          fusionThemeMerge["fusion_theme_v5_colors"],
      "fusion_theme_synthesis_typography":
          fusionThemeMerge["fusion_theme_v5_typography"],
      "fusion_theme_synthesis_spacing":
          fusionThemeMerge["fusion_theme_v5_spacing"],
      "fusion_theme_synthesis_motion":
          fusionThemeMerge["fusion_theme_v5_motion"],
      "fusion_theme_synthesis_elevation":
          fusionThemeMerge["fusion_theme_v5_elevation"],
      "fusion_theme_synthesis_stage": 3,
    };
  }
}
