class TrainingPackTemplateV2AssemblyV2 {
  final Map<String, Object> data;

  TrainingPackTemplateV2AssemblyV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({required Map<String, Object> assemblyV1}) {
    return <String, Object>{
      'training_pack_template_v2_assembly_v2': <String, Object>{
        'assembly_v1': assemblyV1,
        'seed_metadata': 'placeholder_seed_v2',
        'assembly_lineage': 'placeholder_assembly_lineage_v2',
        'pack_lineage': 'placeholder_pack_lineage_v2',
        'module_lineage': 'placeholder_module_lineage_v2',
        'generation_context': <String, Object>{
          'notes': 'placeholder_generation_context_v2',
        },
        'metadata': 'placeholder_training_pack_template_v2_assembly_v2',
      },
    };
  }
}
