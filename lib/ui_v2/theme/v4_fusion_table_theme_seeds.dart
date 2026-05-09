class V4FusionTableThemeSeeds {
  const V4FusionTableThemeSeeds();

  static Map<String, Object?> seed(
    Map<String, Object?>? fusionFinalStabilization,
  ) {
    if (fusionFinalStabilization == null ||
        fusionFinalStabilization["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "table_routing_seed": fusionFinalStabilization["routing_consistent"],
      "table_theme_seed": fusionFinalStabilization["theme_consistent"],
      "fusion_table_theme_seed_stage": 1,
    };
  }
}
