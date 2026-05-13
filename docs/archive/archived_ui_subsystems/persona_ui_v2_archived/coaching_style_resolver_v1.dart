class CoachingStyleResolverV1 {
  const CoachingStyleResolverV1();

  Map<String, Object> resolveStyle({
    required Map<String, Object> directives,
    required Map<String, Object> aggregatedSignals,
  }) {
    final meta =
        directives['meta'] as Map<String, Object>? ?? const <String, Object>{};
    final riskLevel = (meta['risk_level'] ?? 'medium').toString();
    final tone = (meta['tone'] ?? 'neutral').toString();

    final signals =
        aggregatedSignals['state_core'] as Map<String, Object>? ??
        const <String, Object>{};
    final focusLevel = (signals['focus_level'] ?? signals['focus'] ?? 'medium')
        .toString();

    String style = 'balanced';
    if (riskLevel == 'high') {
      style = 'direct';
    } else if (focusLevel == 'low') {
      style = 'supportive';
    }

    final drivers = <String>[
      'risk:$riskLevel',
      'tone:$tone',
      'focus:$focusLevel',
    ]..sort();

    return Map<String, Object>.unmodifiable(<String, Object>{
      'style': style,
      'tone': tone,
      'focus_level': focusLevel,
      'drivers': List<String>.unmodifiable(drivers),
    });
  }
}
