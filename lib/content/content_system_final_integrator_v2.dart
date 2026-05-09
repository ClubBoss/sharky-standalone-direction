class ContentSystemFinalIntegratorV2 {
  static Map<String, Object> build({
    required Map finalAccessPoint,
    required Map finalMasterEnvelope,
    required Map finalExportSurface,
    required Map finalApiEnvelope,
    required Map unifiedApiSurface,
  }) {
    return <String, Object>{
      'content_system_final_integrator_v2': <String, Object>{
        'final_access_point': finalAccessPoint,
        'final_master_envelope': finalMasterEnvelope,
        'final_export_surface': finalExportSurface,
        'final_api_envelope': finalApiEnvelope,
        'unified_api_surface': unifiedApiSurface,
      },
    };
  }
}
