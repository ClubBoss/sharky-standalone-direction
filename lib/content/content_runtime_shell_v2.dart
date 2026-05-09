class ContentRuntimeShellV2 {
  static Map<String, Object> build({required Map runtimeLayerV2}) {
    return <String, Object>{
      'content_runtime_shell_v2': <String, Object>{
        'runtime_layer_v2': runtimeLayerV2,
      },
    };
  }
}
