class PreflightV2 {
  final Map<String, Object> data;

  const PreflightV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required List<Map<String, Object>> manifests,
    required List<Map<String, Object>> sectionSchemas,
  }) {
    return <String, Object>{
      'preflight_v2': <String, Object>{
        'manifests': manifests,
        'section_schemas': sectionSchemas,
        'metadata': 'placeholder_preflight_v2',
      },
    };
  }
}
