class V4FusionIntegrationExportSurface {
  const V4FusionIntegrationExportSurface();

  static Map<String, Object?> build(
    Map<String, Object?>? integrationSynthesis,
    Map<String, Object?>? integrationHealth,
  ) {
    if (integrationSynthesis == null ||
        integrationHealth == null ||
        integrationSynthesis["present"] != true ||
        integrationHealth["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "export_routing": integrationSynthesis["integration_synthesis_routing"],
      "export_theme": integrationSynthesis["integration_synthesis_theme"],
      "export_routing_health": integrationHealth["routing_health"],
      "export_theme_health": integrationHealth["theme_health"],
      "fusion_integration_export_stage": 1,
    };
  }
}
