class V4IntegrationNormalizer {
  const V4IntegrationNormalizer();

  static Map<String, Object?> normalize(Map<String, Object?> channel) {
    return {
      "readiness": channel["readiness"] ?? const {},
      "runtime": channel["runtime"] ?? const {},
      "global": channel["global"] ?? const {},
      "meta": {"keys": channel.keys.toList(), "timestamp": 0},
    };
  }
}
