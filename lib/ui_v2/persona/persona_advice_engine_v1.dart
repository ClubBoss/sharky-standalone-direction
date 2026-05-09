class PersonaAdviceEngineV1 {
  const PersonaAdviceEngineV1();

  Map<String, Object> computeAdvice(Map<String, Object> agg) {
    final behavior =
        agg['behavior'] as Map<String, Object>? ?? const <String, Object>{};
    final alignment =
        agg['alignment'] as Map<String, Object>? ?? const <String, Object>{};
    final dynamics =
        agg['dynamics'] as Map<String, Object>? ?? const <String, Object>{};
    final stateCore =
        agg['state_core'] as Map<String, Object>? ?? const <String, Object>{};
    final attentionCore =
        stateCore['attention'] as Map<String, Object>? ??
        const <String, Object>{};
    final toneCore =
        stateCore['tone'] as Map<String, Object>? ?? const <String, Object>{};
    final personaSignals =
        agg['persona_signals'] as Map<String, Object>? ??
        const <String, Object>{};
    final personaDrivers =
        personaSignals['drivers'] as List<Object>? ?? const <Object>[];

    final mood = (behavior['mood'] ?? 'steady').toString();
    final pressure = (alignment['pressure_alignment'] ?? 'stable').toString();
    final engagementDelta =
        (dynamics['engagement_delta'] as num?)?.toInt() ?? 0;
    final engagement = engagementDelta > 0
        ? 'high'
        : engagementDelta < 0
        ? 'low'
        : 'mid';
    final attentionLevel =
        (attentionCore['attention_stable'] as Map<String, Object>? ??
                const <String, Object>{})['attention_level']
            ?.toString() ??
        'medium';
    final attention = _mapAttention(attentionLevel);
    final tone = (toneCore['tone_stable'] ?? 'neutral').toString();

    final adviceCore = <String, Object>{
      'mood': mood,
      'pressure': pressure,
      'engagement': engagementDelta,
      'attention': attention,
      'tone': tone,
    };

    final recommendations = <String, String>{
      'pacing': _pacing(pressure, engagement),
      'difficulty': _difficulty(attention, pressure),
      'focus': _focus(attention, tone),
      'next_action': _nextAction(mood, pressure, engagement),
    };

    final summary =
        'mood:$mood pressure:$pressure engagement:$engagement attention:$attention tone:$tone';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'advice_core': Map<String, Object>.unmodifiable(adviceCore),
      'recommendations': Map<String, String>.unmodifiable(recommendations),
      'drivers': List<String>.unmodifiable(
        personaDrivers.map((e) => e.toString()),
      ),
      'summary': summary,
    });
  }

  String _mapAttention(String level) {
    switch (level) {
      case 'high':
        return 'high';
      case 'low':
        return 'low';
      default:
        return 'mid';
    }
  }

  String _pacing(String pressure, String engagement) {
    if (pressure == 'rising' || engagement == 'high') return 'short and tight';
    if (pressure == 'dropping' && engagement == 'high') return 'sustain pace';
    return 'steady blocks';
  }

  String _difficulty(String attention, String pressure) {
    if (attention == 'high' && pressure != 'rising') return 'increase';
    if (pressure == 'rising') return 'reduce';
    return 'maintain';
  }

  String _focus(String attention, String tone) {
    if (tone == 'directive' || attention == 'high') return 'precision';
    if (tone == 'encouraging') return 'confidence';
    return 'balance';
  }

  String _nextAction(String mood, String pressure, String engagement) {
    if (pressure == 'rising') return 'stabilize';
    if (mood == 'momentum' && engagement == 'high') return 'press edge';
    if (mood == 'struggle') return 'reset basics';
    return 'continue plan';
  }
}
