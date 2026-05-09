class ContentConsolidatedFinalExportV2 {
  static Map<String, Object> build({
    required Map contentMasterFrameV2,
    required Map finalExportEnvelopeV1,
  }) {
    return <String, Object>{
      'content_consolidated_final_export_v2': <String, Object>{
        'content_master_frame_v2': contentMasterFrameV2,
        'final_export_envelope_v1': finalExportEnvelopeV1,
      },
    };
  }
}
