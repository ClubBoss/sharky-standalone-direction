class ContentRuntimeWindowV2 {
  static Map<String, Object> build({required Map runtimeAccessLayerV2}) {
    return <String, Object>{
      'content_runtime_window_v2': <String, Object>{
        'runtime_access_layer_v2': runtimeAccessLayerV2,
      },
    };
  }
}
