class PersonalizedContentHooksV2 {
  final Map<String, Object> data;

  PersonalizedContentHooksV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required Map<String, Object> tierD,
    required Map<String, Object> tapToExplain,
    required Map<String, Object> conceptLinking,
    required Map<String, Object> moduleIndex,
  }) {
    return <String, Object>{
      'personalized_content_hooks_v2': <String, Object>{
        'tier_d': tierD,
        'tap_to_explain': tapToExplain,
        'concept_linking': conceptLinking,
        'module_index': moduleIndex,
        'metadata': 'placeholder_personalized_content_hooks_v2',
      },
    };
  }
}
