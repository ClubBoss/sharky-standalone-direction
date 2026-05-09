class V4FusionThemePreflight {
  const V4FusionThemePreflight();

  static Map<String, Object?> preflight(Map<String, Object?>? fusionSynthesis) {
    if (fusionSynthesis == null || fusionSynthesis["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "fusion_theme_ready_colors":
          fusionSynthesis["fusion_synthesis_colors"] != null,
      "fusion_theme_ready_typography":
          fusionSynthesis["fusion_synthesis_typography"] != null,
      "fusion_theme_ready_spacing":
          fusionSynthesis["fusion_synthesis_spacing"] != null,
      "fusion_theme_ready_motion":
          fusionSynthesis["fusion_synthesis_motion"] != null,
      "fusion_theme_ready_elevation":
          fusionSynthesis["fusion_synthesis_elevation"] != null,
      "fusion_theme_preflight_stage": 1,
    };
  }
}
