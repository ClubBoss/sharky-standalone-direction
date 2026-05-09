class ContentSystemGlobalAccessPointV1 {
  const ContentSystemGlobalAccessPointV1();

  static Map<String, Object> build({
    required Map<String, Object> contentRuntimeSealV3,
    required Map<String, Object> contentRuntimeEntryPointV3,
    required Map<String, Object> contentSystemFinalV2,
    required Map<String, Object> unifiedContentAPISurfaceV1,
    required Map<String, Object> trainingPackTemplateV2FinalExportEnvelopeV1,
  }) {
    return {
      "content_system_global_access_point_v1": {
        "content_runtime_seal_v3": contentRuntimeSealV3,
        "content_runtime_entry_point_v3": contentRuntimeEntryPointV3,
        "content_system_final_v2": contentSystemFinalV2,
        "unified_content_api_surface_v1": unifiedContentAPISurfaceV1,
        "training_pack_template_v2_final_export_envelope_v1":
            trainingPackTemplateV2FinalExportEnvelopeV1,
      },
    };
  }
}
