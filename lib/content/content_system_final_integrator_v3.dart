class ContentSystemFinalIntegratorV3 {
  const ContentSystemFinalIntegratorV3();

  static Map<String, Object> build({
    required Map<String, Object> contentSystemSealV2,
    required Map<String, Object> contentSystemFinalV2,
    required Map<String, Object> contentRuntimeEnvelopeV2,
    required Map<String, Object> unifiedContentAPISurfaceV1,
    required Map<String, Object> trainingPackTemplateV2FinalExportEnvelopeV1,
  }) {
    return {
      "content_system_final_integrator_v3": {
        "content_system_seal_v2": contentSystemSealV2,
        "content_system_final_v2": contentSystemFinalV2,
        "content_runtime_envelope_v2": contentRuntimeEnvelopeV2,
        "unified_content_api_surface_v1": unifiedContentAPISurfaceV1,
        "training_pack_template_v2_final_export_envelope_v1":
            trainingPackTemplateV2FinalExportEnvelopeV1,
      },
    };
  }
}
