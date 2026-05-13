class PersonaSignalAggregatorV1 {
  const PersonaSignalAggregatorV1();

  Map<String, Object> aggregate({
    required Map<String, Object> tierA,
    required Map<String, Object> esm,
    required Map<String, Object> attentionTone,
    required Map<String, Object> fusedBehavior,
    required Map<String, Object> dynamics,
    required Map<String, Object> personaSignals,
    required Map<String, Object> personaProfile,
  }) {
    final core = <String, Object>{
      'tierA': _subset(tierA, ['passive', 'active', 'stability']),
      'esm': _subset(esm, [
        'primary_state',
        'secondary_modifiers',
        'confidence',
      ]),
      'attention': _subset(attentionTone, ['attention', 'attention_stable']),
      'tone': _subset(attentionTone, ['tone_level', 'tone_stable']),
    };

    final behavior = <String, Object>{
      'mood': fusedBehavior['mood'] ?? 'steady',
      'engagement': fusedBehavior['engagement'] ?? 'mid',
      'pressure_state': fusedBehavior['pressure_state'] ?? 'neutral',
      'persona_bias': fusedBehavior['persona_bias'] ?? 'neutral',
    };

    final dyn = <String, Object>{
      'momentum': dynamics['momentum'] ?? 'stable',
      'tempo_shift': dynamics['tempo_shift'] ?? 'steady',
      'tone_trend': dynamics['tone_trend'] ?? 'flat',
      'stability_hint': dynamics['stability_hint'] ?? 'steady',
    };

    final alignment = _computeAlignment(
      personaSignals,
      fusedBehavior,
      dynamics,
    );

    final summary = _buildSummary(behavior, dyn, alignment);

    return Map<String, Object>.unmodifiable(<String, Object>{
      'state_core': Map<String, Object>.unmodifiable(core),
      'behavior': Map<String, Object>.unmodifiable(behavior),
      'dynamics': Map<String, Object>.unmodifiable(dyn),
      'persona_signals': Map<String, Object>.unmodifiable(personaSignals),
      'alignment': Map<String, Object>.unmodifiable(alignment),
      'summary': summary,
    });
  }

  Map<String, Object> _subset(Map<String, Object> source, List<String> keys) {
    final out = <String, Object>{};
    for (final key in keys) {
      if (source.containsKey(key)) {
        out[key] = source[key]!;
      }
    }
    return Map<String, Object>.unmodifiable(out);
  }

  Map<String, Object> _computeAlignment(
    Map<String, Object> personaSignals,
    Map<String, Object> fusedBehavior,
    Map<String, Object> dynamics,
  ) {
    final personaAlign =
        personaSignals['persona_alignment_signal'] ?? 'aligned';
    final toneBias = personaSignals['tone_bias_signal'] ?? 'neutral';
    final pressure =
        personaSignals['pressure_signal'] ?? dynamics['momentum'] ?? 'stable';
    return <String, Object>{
      'persona_profile_alignment': personaAlign,
      'tone_alignment': toneBias,
      'pressure_alignment': pressure,
    };
  }

  String _buildSummary(
    Map<String, Object> behavior,
    Map<String, Object> dyn,
    Map<String, Object> alignment,
  ) {
    final mood = behavior['mood'];
    final engagement = behavior['engagement'];
    final momentum = dyn['momentum'];
    final personaAlign = alignment['persona_profile_alignment'];
    return 'mood:$mood engagement:$engagement momentum:$momentum align:$personaAlign';
  }
}
