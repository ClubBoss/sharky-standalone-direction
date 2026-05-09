class V4FusionThemeHealthV9 {
  const V4FusionThemeHealthV9();

  static Map<String, Object?> check(
    Map<String, Object?>? fusionThemeSynthesis,
  ) {
    if (fusionThemeSynthesis == null ||
        fusionThemeSynthesis["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "fusion_theme_health_v9_colors":
          fusionThemeSynthesis["fusion_theme_synthesis_colors"] != null,
      "fusion_theme_health_v9_typography":
          fusionThemeSynthesis["fusion_theme_synthesis_typography"] != null,
      "fusion_theme_health_v9_spacing":
          fusionThemeSynthesis["fusion_theme_synthesis_spacing"] != null,
      "fusion_theme_health_v9_motion":
          fusionThemeSynthesis["fusion_theme_synthesis_motion"] != null,
      "fusion_theme_health_v9_elevation":
          fusionThemeSynthesis["fusion_theme_synthesis_elevation"] != null,
      "fusion_theme_health_stage": 9,
    };
  }
}
