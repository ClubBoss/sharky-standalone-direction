class ContentFusionBridgeV2 {
  static Map<String, Object> build({
    required Map tierE,
    required Map tierD,
    required Map personalizationBridge,
    required Map moduleIndex,
    required Map packIndex,
    required Map tapToExplain,
    required Map conceptLinking,
    required Map personalizedHooks,
    required Map manifests,
    required Map sectionSchemas,
    required Map preflight,
    required Map consolidation,
    required Map mapper,
  }) {
    return <String, Object>{
      'fusion_v2': <String, Object>{
        'tier_e': tierE,
        'tier_d': tierD,
        'personalization_bridge': personalizationBridge,
        'module_index': moduleIndex,
        'pack_index': packIndex,
        'tap_to_explain': tapToExplain,
        'concept_linking': conceptLinking,
        'personalized_hooks': personalizedHooks,
        'manifests': manifests,
        'section_schemas': sectionSchemas,
        'preflight': preflight,
        'consolidation': consolidation,
        'mapper': mapper,
      },
    };
  }
}
