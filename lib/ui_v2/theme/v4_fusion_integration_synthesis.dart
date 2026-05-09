class V4FusionIntegrationSynthesis {
  const V4FusionIntegrationSynthesis();

  static Map<String, Object?> synthesize(
    Map<String, Object?>? integrationMerge,
  ) {
    if (integrationMerge == null || integrationMerge["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "integration_synthesis_routing":
          integrationMerge["integration_v5_routing"],
      "integration_synthesis_theme": integrationMerge["integration_v5_theme"],
      "fusion_integration_synthesis_stage": 3,
    };
  }
}
