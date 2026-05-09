class ContentRuntimeGatewayV2 {
  static Map<String, Object> build({required Map runtimeCapsuleV2}) {
    return <String, Object>{
      'content_runtime_gateway_v2': <String, Object>{
        'runtime_capsule_v2': runtimeCapsuleV2,
      },
    };
  }
}
