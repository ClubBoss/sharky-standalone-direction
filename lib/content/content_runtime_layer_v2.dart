class ContentRuntimeLayerV2 {
  static Map<String, Object> build({required Map runtimeEntryV2}) {
    return <String, Object>{
      'content_runtime_layer_v2': <String, Object>{
        'runtime_entry_v2': runtimeEntryV2,
      },
    };
  }
}
