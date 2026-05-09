class ContentRuntimeOverseerV2 {
  static Map<String, Object> build({required Map runtimeGuardianV2}) {
    return <String, Object>{
      'content_runtime_overseer_v2': <String, Object>{
        'runtime_guardian_v2': runtimeGuardianV2,
      },
    };
  }
}
