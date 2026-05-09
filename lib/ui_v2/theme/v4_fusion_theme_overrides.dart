class V4FusionThemeOverrides {
  const V4FusionThemeOverrides();

  static Map<String, Object?> apply(
    Map<String, Object?>? globalFusionContext,
    Map<String, Object?>? personaAdapters,
  ) {
    if (globalFusionContext == null ||
        personaAdapters == null ||
        globalFusionContext["present"] != true ||
        personaAdapters["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "override_routing": personaAdapters["persona_routing"],
      "override_theme": personaAdapters["persona_theme"],
      "fusion_theme_overrides_stage": 1,
    };
  }
}
