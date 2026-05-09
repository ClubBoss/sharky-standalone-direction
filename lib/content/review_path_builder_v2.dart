class ReviewPathBuilderV2 {
  final Map<String, Object> data;

  ReviewPathBuilderV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required Map<String, Object> moduleIndex,
    required Map<String, Object> conceptLinking,
    required Map<String, Object> tapToExplain,
    required Map<String, Object> personalizedHooks,
  }) {
    return <String, Object>{
      'review_path_builder_v2': <String, Object>{
        'module_index': moduleIndex,
        'concept_linking': conceptLinking,
        'tap_to_explain': tapToExplain,
        'personalized_hooks': personalizedHooks,
        'review_route': 'placeholder_review_route_v2',
        'metadata': 'placeholder_review_path_builder_v2',
      },
    };
  }
}
