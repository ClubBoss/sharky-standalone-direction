class CoachingLayerV1 {
  const CoachingLayerV1();

  Map<String, Object> computeCoachingDirectives({
    required Map<String, Object> finalPackage,
  }) {
    final core =
        finalPackage['core'] as Map<String, Object>? ??
        const <String, Object>{};
    final hooks = finalPackage['hooks'] as List<Object>? ?? const <Object>[];
    final signals =
        finalPackage['signals'] as Map<String, Object>? ??
        const <String, Object>{};
    final explanations =
        finalPackage['explanations'] as List<Object>? ?? const <Object>[];

    final mood = (core['mood'] ?? 'neutral').toString();
    final pressure = (core['pressure'] ?? 'stable').toString();
    final attention = (core['attention'] ?? 'mid').toString();
    final tone = (core['tone'] ?? 'neutral').toString();

    final primary = _primaryDirective(mood, pressure, attention);
    final secondary = _secondaryDirective(hooks, explanations);

    final meta = <String, Object>{
      'risk_level': _riskLevel(pressure, tone),
      'focus': _focusLevel(attention),
      'tone': _toneLevel(tone),
      'drivers': List<String>.unmodifiable(
        signals.entries.map((e) => '${e.key}:${e.value}').toList()..sort(),
      ),
    };

    final summary =
        'do:$primary backup:$secondary risk:${meta['risk_level']} focus:${meta['focus']} tone:${meta['tone']}';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'directive_primary': primary,
      'directive_secondary': secondary,
      'meta': Map<String, Object>.unmodifiable(meta),
      'summary': summary,
    });
  }

  String _primaryDirective(String mood, String pressure, String attention) {
    if (pressure == 'rising') return 'stabilize decisions and pace';
    if (mood == 'momentum' && attention == 'high') return 'press clear edges';
    if (mood == 'struggle') return 'return to simple lines';
    return 'maintain steady plan';
  }

  String _secondaryDirective(List<Object> hooks, List<Object> explanations) {
    if (hooks.isNotEmpty) {
      final first = hooks.first;
      if (first is Map && first['suggestion'] != null) {
        return first['suggestion'].toString();
      }
    }
    if (explanations.isNotEmpty) {
      return explanations.first.toString();
    }
    return 'keep focus and observe';
  }

  String _riskLevel(String pressure, String tone) {
    if (pressure == 'rising' || tone == 'negative') return 'high';
    if (pressure == 'dropping' && tone == 'directive') return 'low';
    return 'medium';
  }

  String _focusLevel(String attention) {
    if (attention == 'high') return 'high';
    if (attention == 'low') return 'low';
    return 'medium';
  }

  String _toneLevel(String tone) {
    if (tone == 'directive') return 'firm';
    if (tone == 'encouraging') return 'warm';
    return 'neutral';
  }
}
