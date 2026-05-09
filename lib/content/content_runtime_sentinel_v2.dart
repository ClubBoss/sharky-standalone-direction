class ContentRuntimeSentinelV2 {
  static Map<String, Object> build({required Map runtimeSealV2}) {
    return <String, Object>{
      'content_runtime_sentinel_v2': <String, Object>{
        'runtime_seal_v2': runtimeSealV2,
      },
    };
  }
}
