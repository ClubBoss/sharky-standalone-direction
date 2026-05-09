class ContentSystemFinalAPIEnvelopeV1 {
  static Map<String, Object> build({required Map unifiedContentAPISurfaceV1}) {
    return <String, Object>{
      'content_system_final_api_envelope_v1': <String, Object>{
        'unified_content_api_surface_v1': unifiedContentAPISurfaceV1,
      },
    };
  }
}
