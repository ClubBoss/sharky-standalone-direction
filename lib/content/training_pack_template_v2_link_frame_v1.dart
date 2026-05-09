class TrainingPackTemplateV2LinkFrameV1 {
  static Map<String, Object> build({
    required Map contentMasterFrameV2,
    required Map finalBridgeV2,
  }) {
    return <String, Object>{
      'training_pack_template_v2_link_frame_v1': <String, Object>{
        'content_master_frame_v2': contentMasterFrameV2,
        'final_bridge_v2': finalBridgeV2,
      },
    };
  }
}
