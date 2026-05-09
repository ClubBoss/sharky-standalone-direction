class AIPersonalizationTierEV1 {
  final Map<String, Object> data;

  AIPersonalizationTierEV1(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required Map<String, Object> tierA,
    required Map<String, Object> tierB,
    required Map<String, Object> tierC,
    required Map<String, Object> tierD,
    required Map<String, Object> activationBundle,
    required Map<String, Object> visualSnapshot,
  }) {
    return <String, Object>{
      'ai_personalization_tier_e_v1': <String, Object>{
        'tier_a': tierA,
        'tier_b': tierB,
        'tier_c': tierC,
        'tier_d': tierD,
        'activation_bundle': activationBundle,
        'visual_snapshot': visualSnapshot,
        'metadata': 'placeholder_tier_e_v1',
      },
    };
  }
}
