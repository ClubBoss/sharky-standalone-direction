class V4RuntimeContext {
  const V4RuntimeContext({
    required this.readiness,
    required this.runtime,
    required this.global,
  });

  final Map<String, Object?> readiness;
  final Map<String, Object?> runtime;
  final Map<String, Object?> global;

  static V4RuntimeContext fromIntegrationChannel(Map<String, Object?> channel) {
    return V4RuntimeContext(
      readiness:
          (channel["readiness"] as Map?)?.cast<String, Object?>() ?? const {},
      runtime:
          (channel["runtime"] as Map?)?.cast<String, Object?>() ?? const {},
      global: (channel["global"] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }
}
