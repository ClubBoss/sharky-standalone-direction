class SectionSchemaV2 {
  final Map<String, Object> data;

  const SectionSchemaV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required List<String> theorySections,
    required List<String> drillBlocks,
    required List<String> recapSections,
    required List<String> quizSections,
  }) {
    return <String, Object>{
      'section_schema_v2': <String, Object>{
        'theory': theorySections,
        'drill_blocks': drillBlocks,
        'recap': recapSections,
        'quiz': quizSections,
        'metadata': 'placeholder_section_schema_v2',
      },
    };
  }
}
