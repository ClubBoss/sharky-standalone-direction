class V4GlobalReadiness {
  const V4GlobalReadiness();

  static Map<String, Object?> export({
    required bool isV4Active,
    required Map<String, Object?> readinessBundle,
    required Map<String, Object?> runtimeReadyBundle,
  }) {
    return {
      "is_active": isV4Active,
      "readiness_keys": readinessBundle.keys.toList(),
      "runtime_keys": runtimeReadyBundle.keys.toList(),
    };
  }
}
