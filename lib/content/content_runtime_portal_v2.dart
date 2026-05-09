class ContentRuntimePortalV2 {
  static Map<String, Object> build({required Map runtimeGatewayV2}) {
    return <String, Object>{
      'content_runtime_portal_v2': <String, Object>{
        'runtime_gateway_v2': runtimeGatewayV2,
      },
    };
  }
}
