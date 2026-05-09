class V4IntegrationChannel {
  const V4IntegrationChannel();

  static Map<String, Object?> build({
    required Map<String, Object?> readinessBundle,
    required Map<String, Object?> runtimeReadyBundle,
    required Map<String, Object?> globalReadyBundle,
  }) {
    return {
      "readiness": readinessBundle,
      "runtime": runtimeReadyBundle,
      "global": globalReadyBundle,
    };
  }
}
