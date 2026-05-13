class PersonaCoachingFinalV1 {
  const PersonaCoachingFinalV1();

  Map<String, Object> computeFinalCoachingPackage({
    required Map<String, Object> advice,
    required Map<String, Object> explanation,
    required Map<String, Object> heuristics,
    required Map<String, Object> hooks,
    required Map<String, Object> aggregatedSignals,
  }) {
    final adviceCore =
        advice['advice_core'] as Map<String, Object>? ??
        const <String, Object>{};
    final heuristicsCore =
        heuristics['heuristics'] as Map<String, Object>? ??
        const <String, Object>{};
    final hookList = hooks['hooks'] as List<Object>? ?? const <Object>[];
    final signals =
        aggregatedSignals['state_core'] as Map<String, Object>? ??
        const <String, Object>{};

    final core = <String, Object>{
      'mood': adviceCore['mood'] ?? 'neutral',
      'pressure': adviceCore['pressure'] ?? 'stable',
      'engagement': adviceCore['engagement'] ?? 0,
      'attention': adviceCore['attention'] ?? 'mid',
      'tone': adviceCore['tone'] ?? 'neutral',
      'pacing_hint': heuristicsCore['pacing_hint'] ?? 'normal',
      'risk_hint': heuristicsCore['risk_hint'] ?? 'normal',
      'focus_hint': heuristicsCore['focus_hint'] ?? 'maintain focus',
      'energy_hint': heuristicsCore['energy_hint'] ?? 'stable energy',
      'safety_hint': heuristicsCore['safety_hint'] ?? 'normal safety',
    };

    final explanations = _buildExplanations(adviceCore, heuristicsCore);

    final summary =
        'mood:${core['mood']} pressure:${core['pressure']} attention:${core['attention']} tone:${core['tone']} hooks:${hookList.length}';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'core': Map<String, Object>.unmodifiable(core),
      'hooks': List<Object>.unmodifiable(hookList),
      'signals': Map<String, Object>.unmodifiable(signals),
      'explanations': List<String>.unmodifiable(explanations),
      'summary': summary,
    });
  }

  List<String> _buildExplanations(
    Map<String, Object> adviceCore,
    Map<String, Object> heuristicsCore,
  ) {
    final mood = adviceCore['mood'] ?? 'neutral';
    final pressure = adviceCore['pressure'] ?? 'stable';
    final attention = adviceCore['attention'] ?? 'mid';
    final tone = adviceCore['tone'] ?? 'neutral';
    final pacing = heuristicsCore['pacing_hint'] ?? 'normal';
    final risk = heuristicsCore['risk_hint'] ?? 'normal';
    final focus = heuristicsCore['focus_hint'] ?? 'maintain focus';
    return <String>[
      'mood:$mood pressure:$pressure',
      'attention:$attention tone:$tone',
      'pacing:$pacing risk:$risk',
      'focus:$focus',
    ];
  }
}
