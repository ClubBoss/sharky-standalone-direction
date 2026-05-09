class ContentKeyConsistencyV2 {
  static Map<String, Object> build({
    required Map masterFrameV2,
    required Map moduleIndexV2,
    required Map contentMapperV2,
  }) {
    return <String, Object>{
      'content_key_consistency_v2': <String, Object>{
        'master_frame_keys': masterFrameV2.keys.toList(),
        'module_index_keys': moduleIndexV2.keys.toList(),
        'content_mapper_keys': contentMapperV2.keys.toList(),
      },
    };
  }
}
