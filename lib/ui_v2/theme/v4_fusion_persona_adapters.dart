class V4FusionPersonaAdapters {
  const V4FusionPersonaAdapters();

  static Map<String, Object?> adapt(Map<String, Object?>? globalFusionContext) {
    if (globalFusionContext == null || globalFusionContext["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "persona_routing": globalFusionContext["fusion_routing"],
      "persona_theme": globalFusionContext["fusion_theme"],
      "persona_adapter_stage": 1,
    };
  }
}
