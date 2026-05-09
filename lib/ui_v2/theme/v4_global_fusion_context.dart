class V4GlobalFusionContext {
  const V4GlobalFusionContext();

  static Map<String, Object?> build(
    Map<String, Object?>? integrationSynthesis,
    Map<String, Object?>? integrationHealth,
    Map<String, Object?>? integrationExportSurface,
  ) {
    if (integrationSynthesis == null ||
        integrationHealth == null ||
        integrationExportSurface == null ||
        integrationExportSurface["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "fusion_routing": integrationExportSurface["export_routing"],
      "fusion_theme": integrationExportSurface["export_theme"],
      "fusion_routing_health": integrationHealth["routing_health"],
      "fusion_theme_health": integrationHealth["theme_health"],
      "global_fusion_context_stage": 1,
    };
  }
}
