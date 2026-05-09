class PersonaDecisionHeuristicsV1 {
  const PersonaDecisionHeuristicsV1();

  Map<String, Object> computeHeuristics(
    Map<String, Object> advice,
    Map<String, Object> explanation,
  ) {
    final core =
        advice['advice_core'] as Map<String, Object>? ??
        const <String, Object>{};
    final mood = (core['mood'] ?? 'neutral').toString();
    final pressure = (core['pressure'] ?? 'stable').toString();
    final engagement =
        (core['engagement'] as num?)?.toInt() ?? 0; // delta value
    final attention = (core['attention'] ?? 'mid').toString();
    final tone = (core['tone'] ?? 'neutral').toString();

    final pacingHint = _pacing(mood, pressure);
    final riskHint = _risk(tone, pressure, mood);
    final focusHint = _focus(attention);
    final energyHint = _energy(mood, attention, engagement);
    final safetyHint = _safety(pressure, tone);

    final heuristics = <String, String>{
      'pacing_hint': pacingHint,
      'risk_hint': riskHint,
      'focus_hint': focusHint,
      'energy_hint': energyHint,
      'safety_hint': safetyHint,
    };

    final drivers = <String, String>{
      'from_mood': 'mood:$mood',
      'from_pressure': 'pressure:$pressure',
      'from_attention': 'attention:$attention',
      'from_tone': 'tone:$tone',
    };

    final summary =
        'pacing:$pacingHint risk:$riskHint focus:$focusHint energy:$energyHint safety:$safetyHint';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'heuristics': Map<String, String>.unmodifiable(heuristics),
      'drivers': Map<String, String>.unmodifiable(drivers),
      'summary': summary,
    });
  }

  String _pacing(String mood, String pressure) {
    if (mood == 'struggle' || pressure == 'rising') return 'slower';
    if (mood == 'momentum' && pressure != 'rising') return 'slightly faster';
    return 'normal';
  }

  String _risk(String tone, String pressure, String mood) {
    if (tone == 'negative' || pressure == 'rising') return 'lower';
    if (mood == 'momentum' && pressure == 'dropping') return 'slightly higher';
    return 'normal';
  }

  String _focus(String attention) {
    if (attention == 'low') return 'increase focus';
    if (attention == 'high') return 'optimize focus';
    return 'maintain focus';
  }

  String _energy(String mood, String attention, int engagement) {
    if (mood == 'struggle' || attention == 'low') return 'lower energy';
    if (engagement > 0 || mood == 'momentum') return 'higher energy';
    return 'stable energy';
  }

  String _safety(String pressure, String tone) {
    if (pressure == 'rising' || tone == 'negative') return 'boost safety';
    return 'normal safety';
  }
}
