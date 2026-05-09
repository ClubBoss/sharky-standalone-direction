class ContentRuntimeOmegaV2 {
  static Map<String, Object> build({required Map runtimeApexV2}) {
    return <String, Object>{
      'content_runtime_omega_v2': <String, Object>{
        'runtime_apex_v2': runtimeApexV2,
      },
    };
  }
}
