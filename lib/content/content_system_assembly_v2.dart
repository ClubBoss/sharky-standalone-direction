class ContentSystemAssemblyV2 {
  const ContentSystemAssemblyV2();

  static Map<String, Object> build({
    required Map<String, Object> contentMasterFrameV2,
    required Map<String, Object> contentRuntimeFinalSynthesisV2,
    required Map<String, Object> auditApexFinaleV2,
    required Map<String, Object> trainingPackTemplateV2FinalExportEnvelopeV1,
  }) {
    return {
      "content_system_assembly_v2": {
        "content_master_frame_v2": contentMasterFrameV2,
        "content_runtime_final_synthesis_v2": contentRuntimeFinalSynthesisV2,
        "audit_apex_finale_v2": auditApexFinaleV2,
        "training_pack_template_v2_final_export_envelope_v1":
            trainingPackTemplateV2FinalExportEnvelopeV1,
      },
    };
  }
}
