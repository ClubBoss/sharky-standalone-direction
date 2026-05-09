class ContentRuntimeGuardianV2 {
  static Map<String, Object> build({required Map runtimeSentinelV2}) {
    return <String, Object>{
      'content_runtime_guardian_v2': <String, Object>{
        'runtime_sentinel_v2': runtimeSentinelV2,
      },
    };
  }
}
