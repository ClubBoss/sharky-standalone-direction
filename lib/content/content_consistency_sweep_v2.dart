class ContentConsistencySweepV2 {
  static Map<String, Object> build({
    required Map masterFrameV2,
    required Map moduleIndexV2,
    required Map contentMapperV2,
  }) {
    return <String, Object>{
      'content_consistency_sweep_v2': <String, Object>{
        'master_frame_v2': masterFrameV2,
        'module_index_v2': moduleIndexV2,
        'content_mapper_v2': contentMapperV2,
      },
    };
  }
}
