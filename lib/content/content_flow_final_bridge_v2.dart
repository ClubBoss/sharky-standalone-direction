class ContentFlowFinalBridgeV2 {
  final Map<String, Object> data;

  ContentFlowFinalBridgeV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required Map<String, Object> reviewPath,
    required Map<String, Object> personalizedHooks,
    required Map<String, Object> conceptLinking,
    required Map<String, Object> tapToExplain,
    required Map<String, Object> mapper,
    required Map<String, Object> consolidation,
    required Map<String, Object> moduleIndex,
    required List<Map<String, Object>> sectionSchemas,
    required List<Map<String, Object>> manifests,
    required Map<String, Object> preflight,
  }) {
    return <String, Object>{
      'content_flow_final_bridge_v2': <String, Object>{
        'review_path': reviewPath,
        'personalized_hooks': personalizedHooks,
        'concept_linking': conceptLinking,
        'tap_to_explain': tapToExplain,
        'mapper': mapper,
        'consolidation': consolidation,
        'module_index': moduleIndex,
        'section_schemas': sectionSchemas,
        'manifests': manifests,
        'preflight': preflight,
        'metadata': 'placeholder_content_flow_final_bridge_v2',
      },
    };
  }
}
