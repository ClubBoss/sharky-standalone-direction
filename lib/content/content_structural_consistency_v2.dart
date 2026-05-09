class ContentStructuralConsistencyV2 {
  static List<String> _structure(Map<dynamic, dynamic> source) {
    final keys = source.keys.map((key) => key.toString()).toList();
    keys.sort();
    return keys;
  }

  static Map<String, Object> build({
    required Map masterFrameV2,
    required Map moduleIndexV2,
    required Map contentMapperV2,
  }) {
    return <String, Object>{
      'content_structural_consistency_v2': <String, Object>{
        'master_frame_structure': _structure(masterFrameV2),
        'module_index_structure': _structure(moduleIndexV2),
        'content_mapper_structure': _structure(contentMapperV2),
      },
    };
  }
}
