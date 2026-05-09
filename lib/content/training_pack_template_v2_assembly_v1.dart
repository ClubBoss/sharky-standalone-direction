class TrainingPackTemplateV2AssemblyV1 {
  final Map<String, Object> data;

  TrainingPackTemplateV2AssemblyV1(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required Map<String, Object> mapper,
    required Map<String, Object> consolidation,
    required List<Map<String, Object>> sectionSchemas,
    required List<Map<String, Object>> manifests,
    required Map<String, Object> moduleIndex,
    required Map<String, Object> packIndex,
    required Map<String, Object> preflight,
  }) {
    return <String, Object>{
      'training_pack_template_v2_assembly_v1': <String, Object>{
        'mapper': mapper,
        'consolidation': consolidation,
        'section_schemas': sectionSchemas,
        'manifests': manifests,
        'module_index': moduleIndex,
        'pack_index': packIndex,
        'preflight': preflight,
        'metadata': 'placeholder_training_pack_template_v2_assembly_v1',
      },
    };
  }
}
