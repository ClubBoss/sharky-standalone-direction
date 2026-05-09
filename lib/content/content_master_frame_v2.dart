class ContentMasterFrameV2 {
  static Map<String, Object> build({
    required Map metaFrameV2,
    required Map fusionV2,
    required Map personalizationTierE,
    required Map personalizationTierD,
    required Map contentPersonalizationBridge,
    required Map personalizedHooksV2,
    required Map moduleIndexV2,
    required Map packIndexV2,
    required Map manifestV2,
    required Map sectionSchemaV2,
    required Map preflightV2,
    required Map consolidationV2,
    required Map mapperV2,
    required Map contentFlowFinalBridgeV2,
  }) {
    return <String, Object>{
      'content_master_frame_v2': <String, Object>{
        'meta': metaFrameV2,
        'fusion': fusionV2,
        'tier_e': personalizationTierE,
        'tier_d': personalizationTierD,
        'content_personalization_bridge': contentPersonalizationBridge,
        'personalized_hooks_v2': personalizedHooksV2,
        'module_index_v2': moduleIndexV2,
        'pack_index_v2': packIndexV2,
        'manifest_v2': manifestV2,
        'section_schema_v2': sectionSchemaV2,
        'preflight_v2': preflightV2,
        'consolidation_v2': consolidationV2,
        'mapper_v2': mapperV2,
        'flow_bridge_v2': contentFlowFinalBridgeV2,
      },
    };
  }
}
