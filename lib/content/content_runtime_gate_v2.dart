class ContentRuntimeGateV2 {
  static Map<String, Object> build({required Map runtimePortalV2}) {
    return <String, Object>{
      'content_runtime_gate_v2': <String, Object>{
        'runtime_portal_v2': runtimePortalV2,
      },
    };
  }
}
