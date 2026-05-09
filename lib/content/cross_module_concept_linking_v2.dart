class CrossModuleConceptLinkingV2 {
  final Map<String, Object> data;

  CrossModuleConceptLinkingV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required List<String> concepts,
    required Map<String, Object> moduleIndex,
    required List<Map<String, Object>> manifests,
    required List<Map<String, Object>> sectionSchemas,
  }) {
    return <String, Object>{
      'cross_module_concept_linking_v2': <String, Object>{
        'concepts': concepts,
        'concept_to_modules': <String, String>{
          for (final c in concepts) c: 'placeholder_concept_to_modules_$c',
        },
        'concept_to_sections': <String, String>{
          for (final c in concepts) c: 'placeholder_concept_to_sections_$c',
        },
        'concept_to_manifests': <String, String>{
          for (final c in concepts) c: 'placeholder_concept_to_manifests_$c',
        },
        'metadata': 'placeholder_cross_module_concept_linking_v2',
      },
    };
  }
}
