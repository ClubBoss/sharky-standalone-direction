class ContentAnalyzerV2 {
  final Map<String, Object> data;

  const ContentAnalyzerV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required List<Map<String, Object>> manifests,
    required List<Map<String, Object>> sectionSchemas,
    required Map<String, Object> moduleIndex,
    required Map<String, Object> preflight,
  }) {
    return <String, Object>{
      'content_analyzer_v2': <String, Object>{
        'manifests': manifests,
        'section_schemas': sectionSchemas,
        'module_index': moduleIndex,
        'preflight': preflight,
        'metadata': 'placeholder_content_analyzer_v2',
      },
    };
  }
}
