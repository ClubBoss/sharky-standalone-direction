class ContentValueConsistencyV2 {
  static Map<String, Object> build({
    required Map masterFrameV2,
    required Map moduleIndexV2,
    required Map contentMapperV2,
  }) {
    return <String, Object>{
      'content_value_consistency_v2': <String, Object>{
        'master_frame_values': masterFrameV2.values.toList(),
        'module_index_values': moduleIndexV2.values.toList(),
        'content_mapper_values': contentMapperV2.values.toList(),
      },
    };
  }
}
