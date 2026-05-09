class ContentSystemFinalMasterEnvelopeV1 {
  static Map<String, Object> build({
    required Map contentSystemFinalExportSurfaceV1,
  }) {
    return <String, Object>{
      'content_system_final_master_envelope_v1': <String, Object>{
        'content_system_final_export_surface_v1':
            contentSystemFinalExportSurfaceV1,
      },
    };
  }
}
