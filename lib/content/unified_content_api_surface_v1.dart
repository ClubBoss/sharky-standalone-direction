class UnifiedContentAPISurfaceV1 {
  static Map<String, Object> build({
    required Map contentSystemExportEnvelopeV1,
  }) {
    return <String, Object>{
      'unified_content_api_surface_v1': <String, Object>{
        'content_system_export_envelope_v1': contentSystemExportEnvelopeV1,
      },
    };
  }
}
