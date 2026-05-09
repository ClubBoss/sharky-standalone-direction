class V4FusionIntegrationPreflight {
  const V4FusionIntegrationPreflight();

  static Map<String, Object?> preflight(
    Map<String, Object?>? routingFusion,
    Map<String, Object?>? themeFusion,
  ) {
    final routingOk = routingFusion != null && routingFusion["present"] == true;
    final themeOk = themeFusion != null && themeFusion["present"] == true;

    if (!routingOk || !themeOk) {
      return const {"present": false};
    }

    return {
      "present": true,
      "integration_ready_routing": routingOk,
      "integration_ready_theme": themeOk,
      "fusion_integration_preflight_stage": 1,
    };
  }
}
