class ContentSystemFinalExportSurfaceV1 {
  static Map<String, Object> build({
    required Map contentSystemFinalAPIEnvelopeV1,
  }) {
    return <String, Object>{
      'content_system_final_export_surface_v1': <String, Object>{
        'content_system_final_api_envelope_v1': contentSystemFinalAPIEnvelopeV1,
      },
    };
  }
}
