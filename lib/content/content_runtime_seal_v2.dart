class ContentRuntimeSealV2 {
  static Map<String, Object> build({required Map runtimeFinalizerV2}) {
    return <String, Object>{
      'content_runtime_seal_v2': <String, Object>{
        'runtime_finalizer_v2': runtimeFinalizerV2,
      },
    };
  }
}
