class PersonaDrivenSignalsV1 {
  const PersonaDrivenSignalsV1();

  Map<String, Object> computeSignals({
    required Map<String, Object> tierA,
    required Map<String, Object> esm,
    required Map<String, Object> attentionTone,
    required Map<String, Object> fusedBehavior,
    required Map<String, Object> dynamics,
    required Map<String, Object> personaProfile,
  }) {
    final attStable =
        attentionTone['attention_stable'] as Map<String, Object>? ??
        const <String, Object>{};
    final attentionLevel = (attStable['attention_level'] ?? 'medium')
        .toString();
    final toneStable = (attentionTone['tone_stable'] ?? 'neutral').toString();

    final dynamicsDrivers =
        dynamics['drivers'] as Map<String, Object>? ?? const <String, Object>{};
    final fusedDrivers =
        fusedBehavior['drivers'] as Map<String, Object>? ??
        const <String, Object>{};

    final momentum = (dynamics['momentum'] ?? 'stable').toString();
    final pressure = (fusedBehavior['pressure_state'] ?? 'neutral').toString();
    final engagement = (fusedBehavior['engagement'] ?? 'mid').toString();
    final toneBias = toneStable;
    final personaBias = (fusedBehavior['persona_bias'] ?? 'neutral').toString();

    final focusSignal = _focusSignal(attentionLevel);
    final pressureSignal = _pressureSignal(momentum, pressure);
    final engagementSignal = _engagementSignal(engagement, dynamics);
    final toneBiasSignal = _toneBiasSignal(toneBias, esm);
    final personaAlignmentSignal = _personaAlignmentSignal(
      personaBias,
      toneBias,
    );

    final drivers = <String>[
      'momentum:$momentum',
      'pressure:$pressure',
      'engagement:$engagement',
      'tone:$toneStable',
      'persona_bias:$personaBias',
    ];
    drivers.addAll(_flatDrivers(fusedDrivers));
    drivers.addAll(_flatDrivers(dynamicsDrivers));

    return Map<String, Object>.unmodifiable(<String, Object>{
      'focus_signal': focusSignal,
      'pressure_signal': pressureSignal,
      'engagement_signal': engagementSignal,
      'tone_bias_signal': toneBiasSignal,
      'persona_alignment_signal': personaAlignmentSignal,
      'drivers': List<String>.unmodifiable(drivers),
    });
  }

  String _focusSignal(String attention) {
    switch (attention) {
      case 'high':
        return 'high';
      case 'low':
        return 'low';
      default:
        return 'mid';
    }
  }

  String _pressureSignal(String momentum, String pressure) {
    if (momentum == 'rising' || pressure == 'high') return 'rising';
    if (momentum == 'falling') return 'dropping';
    return 'stable';
  }

  String _engagementSignal(String engagement, Map<String, Object> dynamics) {
    final delta = (dynamics['engagement_delta'] as num?)?.toInt() ?? 0;
    if (engagement == 'high' || delta > 0) return 'strong';
    if (engagement == 'low' || delta < 0) return 'weak';
    return 'normal';
  }

  String _toneBiasSignal(String tone, Map<String, Object> esm) {
    final confidence = (esm['confidence'] as num?)?.toDouble() ?? 0.0;
    if (tone == 'directive' && confidence > 50) return 'positive';
    if (tone == 'encouraging') return 'neutral';
    return 'negative';
  }

  String _personaAlignmentSignal(String personaBias, String toneBias) {
    if (personaBias == 'neutral') return 'aligned';
    if (personaBias == toneBias) return 'aligned';
    if (personaBias == 'directive' && toneBias != 'directive')
      return 'drifting';
    return 'misaligned';
  }

  Iterable<String> _flatDrivers(Map<String, Object> drivers) sync* {
    for (final entry in drivers.entries) {
      yield '${entry.key}:${entry.value}';
    }
  }
}
