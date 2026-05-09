class V4V3FallbackConsistencyV1 {
  const V4V3FallbackConsistencyV1();

  static Map<String, Object?> check({
    required Map<String, Object?> v4Context,
    required Map<String, Object?> v3Context,
  }) {
    return {
      "present": true,
      "stage": "v4_v3_fallback_consistency_v1",
      "v4_present": v4Context.isNotEmpty,
      "v3_present": v3Context.isNotEmpty,
      "fallback_consistent": v4Context.isNotEmpty && v3Context.isNotEmpty,
      "consistent": false,
    };
  }
}
