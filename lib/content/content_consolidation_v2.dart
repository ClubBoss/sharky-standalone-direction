class ContentConsolidationV2 {
  final Map<String, Object> data;

  const ContentConsolidationV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required Map<String, Object> analyzer,
    required Map<String, Object> moduleIndex,
    required Map<String, Object> packIndex,
    required List<Map<String, Object>> manifests,
  }) {
    return <String, Object>{
      'content_consolidation_v2': <String, Object>{
        'analyzer': analyzer,
        'module_index': moduleIndex,
        'pack_index': packIndex,
        'manifests': manifests,
        'metadata': 'placeholder_content_consolidation_v2',
      },
    };
  }
}
