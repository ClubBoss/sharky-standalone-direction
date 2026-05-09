class ContentSystemFinalV2 {
  const ContentSystemFinalV2();

  static Map<String, Object> build({
    required Map<String, Object> runtimeEnvelopeV2,
    required Map<String, Object> systemAssemblyV2,
    required Map<String, Object> runtimeFinalSynthesisV2,
    required Map<String, Object> auditApexFinaleV2,
    required Map<String, Object> tptV2FinalExportEnvelope,
  }) {
    return {
      "content_system_final_v2": {
        "runtime_envelope_v2": runtimeEnvelopeV2,
        "system_assembly_v2": systemAssemblyV2,
        "runtime_final_synthesis_v2": runtimeFinalSynthesisV2,
        "audit_apex_finale_v2": auditApexFinaleV2,
        "tpt_v2_final_export_envelope_v1": tptV2FinalExportEnvelope,
      },
    };
  }
}
