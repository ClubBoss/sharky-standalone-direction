class ContentRuntimeAccessLayerV2 {
  static Map<String, Object> build({required Map runtimeGateV2}) {
    return <String, Object>{
      'content_runtime_access_layer_v2': <String, Object>{
        'runtime_gate_v2': runtimeGateV2,
      },
    };
  }
}
