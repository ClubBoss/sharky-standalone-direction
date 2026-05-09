class ContentMapperV2 {
  final Map<String, Object> data;

  const ContentMapperV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required Map<String, Object> consolidation,
    required Map<String, Object> moduleIndex,
    required List<Map<String, Object>> sectionSchemas,
    required List<Map<String, Object>> manifests,
  }) {
    return <String, Object>{
      'content_mapper_v2': <String, Object>{
        'consolidation': consolidation,
        'module_index': moduleIndex,
        'section_schemas': sectionSchemas,
        'manifests': manifests,
        'metadata': 'placeholder_content_mapper_v2',
      },
    };
  }
}
