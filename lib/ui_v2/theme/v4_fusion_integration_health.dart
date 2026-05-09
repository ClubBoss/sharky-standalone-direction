class V4FusionIntegrationHealth {
  const V4FusionIntegrationHealth();

  static Map<String, Object?> check(
    Map<String, Object?>? integrationSynthesis,
    Map<String, Object?>? integrationStabilization,
  ) {
    if (integrationSynthesis == null ||
        integrationStabilization == null ||
        integrationStabilization["present"] != true) {
      return const {"present": false};
    }

    final routingOk = integrationStabilization["stable_routing"] == true;
    final themeOk = integrationStabilization["stable_theme"] == true;

    return {
      "present": true,
      "routing_health": routingOk,
      "theme_health": themeOk,
      "fusion_integration_health_stage": 1,
    };
  }
}
