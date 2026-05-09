class V4FusionIntegrationMerge {
  const V4FusionIntegrationMerge();

  static Map<String, Object?> merge(
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
      "integration_v5_routing": routingFusion,
      "integration_v5_theme": themeFusion,
      "fusion_integration_merge_stage": 2,
    };
  }
}
