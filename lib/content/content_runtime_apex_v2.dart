class ContentRuntimeApexV2 {
  static Map<String, Object> build({required Map runtimeMythosV2}) {
    return <String, Object>{
      'content_runtime_apex_v2': <String, Object>{
        'runtime_mythos_v2': runtimeMythosV2,
      },
    };
  }
}
