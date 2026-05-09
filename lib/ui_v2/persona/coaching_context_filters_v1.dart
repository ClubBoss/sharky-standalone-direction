class CoachingContextFiltersV1 {
  const CoachingContextFiltersV1();

  Map<String, Object> buildFilters({
    required Map<String, Object> style,
    required Map<String, Object> directives,
    required Map<String, Object> aggregatedSignals,
  }) {
    final meta =
        directives['meta'] as Map<String, Object>? ?? const <String, Object>{};
    final riskLevel = (meta['risk_level'] ?? 'low').toString();
    final aggCore =
        aggregatedSignals['state_core'] as Map<String, Object>? ??
        const <String, Object>{};
    final focusLevel = (aggCore['focus_level'] ?? aggCore['focus'] ?? 'medium')
        .toString();
    final pressureRaw = (aggCore['pressure'] as num?)?.toDouble() ?? 0.0;
    final stress = (aggCore['stress'] ?? 'low').toString();

    final riskFilter = _riskFilter(riskLevel, stress);
    final pressureFilter = _pressureFilter(pressureRaw);
    final toneFilter = _toneFilter(style['tone']?.toString() ?? 'neutral');
    final focusFilter = _focusFilter(focusLevel);

    final drivers = <String>[
      'risk:$riskLevel',
      'stress:$stress',
      'pressure:$pressureRaw',
      'tone:${style['tone']}',
      'focus:$focusLevel',
    ]..sort();

    return Map<String, Object>.unmodifiable(<String, Object>{
      'filters': Map<String, String>.unmodifiable(<String, String>{
        'risk_filter': riskFilter,
        'pressure_filter': pressureFilter,
        'tone_filter': toneFilter,
        'focus_filter': focusFilter,
      }),
      'drivers': List<String>.unmodifiable(drivers),
    });
  }

  String _riskFilter(String riskLevel, String stress) {
    if (riskLevel == 'high') return 'high';
    if (stress == 'medium') return 'medium';
    return 'low';
  }

  String _pressureFilter(double pressure) {
    if (pressure > 0.6) return 'strong';
    if (pressure > 0.3) return 'light';
    return 'off';
  }

  String _toneFilter(String tone) {
    if (tone == 'warm') return 'supportive';
    if (tone == 'firm') return 'direct';
    return 'neutral';
  }

  String _focusFilter(String focusLevel) {
    if (focusLevel == 'low') return 'broad';
    if (focusLevel == 'high') return 'narrow';
    return 'balanced';
  }
}
