class ContentMetaFrameV2 {
  static Map<String, Object> build({
    required Map fusionV2,
    required Map personalizationTierE,
    required Map personalizationTierD,
    required Map contentPersonalizationBridge,
    required Map personalizedHooksV2,
  }) {
    return <String, Object>{
      'content_meta_frame_v2': <String, Object>{
        'fusion': fusionV2,
        'tier_e': personalizationTierE,
        'tier_d': personalizationTierD,
        'content_personalization_bridge': contentPersonalizationBridge,
        'personalized_hooks_v2': personalizedHooksV2,
      },
    };
  }
}
