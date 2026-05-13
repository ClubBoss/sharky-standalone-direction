class BehavioralFusionV1 {
  const BehavioralFusionV1();

  Map<String, Object> fuseAll({
    required Map<String, Object> tierA,
    required Map<String, Object> esm,
    required Map<String, Object> attentionTone,
    required Map<String, Object> profile,
  }) {
    final esmPrimary = (esm['primary_state'] ?? 'steady').toString();
    final tierAActive =
        (tierA['active'] as Map<String, Object>?) ?? const <String, Object>{};
    final tierAActiveState = (tierAActive['active_state'] ?? 'neutral')
        .toString();
    final mood = esmPrimary.isNotEmpty ? esmPrimary : tierAActiveState;

    final attStable =
        (attentionTone['attention_stable'] as Map<String, Object>?) ??
        const <String, Object>{};
    final stableAttention = (attStable['attention_level'] ?? 'medium')
        .toString();
    String engagement = 'mid';
    if (stableAttention == 'high') engagement = 'high';
    if (stableAttention == 'low') engagement = 'low';

    final tierAStability =
        (tierA['stability'] as Map<String, Object>?) ??
        const <String, Object>{};
    final pressureState = (tierAStability['stable_state'] ?? 'neutral')
        .toString();

    final toneStable = (attentionTone['tone_stable'] ?? 'neutral').toString();

    final personaTitle = (profile['persona_title'] ?? profile['title'] ?? '')
        .toString();
    final personaBias = personaTitle.isNotEmpty ? personaTitle : 'neutral';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'mood': mood,
      'engagement': engagement,
      'pressure_state': pressureState,
      'attention': Map<String, Object>.unmodifiable(attStable),
      'tone': toneStable,
      'persona_bias': personaBias,
      'drivers': Map<String, Object>.unmodifiable(<String, Object>{
        'tierA': tierA,
        'esm': esm,
        'attention_tone': attentionTone,
        'profile': profile,
      }),
    });
  }
}
