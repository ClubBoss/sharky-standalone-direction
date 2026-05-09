class ModuleIndexV2 {
  final Map<String, Object> data;

  const ModuleIndexV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required List<Map<String, Object>> manifests,
  }) {
    return <String, Object>{
      'module_index_v2': <String, Object>{
        'manifests': manifests,
        'metadata': 'placeholder_module_index_v2',
      },
    };
  }
}
