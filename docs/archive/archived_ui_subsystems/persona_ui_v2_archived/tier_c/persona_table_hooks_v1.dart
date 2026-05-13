class PersonaTableHooksV1 {
  const PersonaTableHooksV1({
    this.personaAdaptiveRecommendationsMap = const <String, Object>{},
    this.personaBiasMap = const <String, Object>{},
    this.microSynergyMap = const <String, Object>{},
    this.tableStateMap = const <String, Object>{},
  });

  PersonaTableHooksV1.fromInputs({
    Map<String, Object?>? personaAdaptiveRecommendationsMap,
    Map<String, Object?>? personaBiasMap,
    Map<String, Object?>? microSynergyMap,
    Map<String, Object?>? tableStateMap,
  }) : this(
         personaAdaptiveRecommendationsMap: _safe(
           personaAdaptiveRecommendationsMap,
         ),
         personaBiasMap: _safe(personaBiasMap),
         microSynergyMap: _safe(microSynergyMap),
         tableStateMap: _safe(tableStateMap),
       );

  final Map<String, Object> personaAdaptiveRecommendationsMap;
  final Map<String, Object> personaBiasMap;
  final Map<String, Object> microSynergyMap;
  final Map<String, Object> tableStateMap;

  Map<String, Object> build() {
    final String recTag = _extractRecommendationTag();
    final String tone =
        (personaBiasMap['persona_bias_map_v1']
                as Map<String, Object?>?)?['bias_tone']
            as String? ??
        'neutral';
    final double moodStrength = _extractMoodStrength();
    final double synergyStrength = _extractSynergyStrength() ?? 0.0;
    String hook = 'neutral_baseline';
    if (recTag == 'aggressive_push' && moodStrength > 0.6) {
      hook = 'boost_attack';
    } else if (tone == 'soft' && moodStrength < 0.3) {
      hook = 'stabilize_passive';
    } else if (synergyStrength > 0.5) {
      hook = 'focus_edge';
    }
    return <String, Object>{
      'persona_table_hooks_v1': <String, Object>{
        'hook': _ascii(hook),
        'ready': true,
      },
    };
  }

  String _extractRecommendationTag() {
    final Map<String, Object?> recBody =
        personaAdaptiveRecommendationsMap['persona_adaptive_recommendations_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    return (recBody['tag'] as String? ?? 'neutral_standard').toLowerCase();
  }

  double _extractMoodStrength() {
    final Map<String, Object?> synergyBody =
        microSynergyMap['micro_synergy_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    return _toDouble(synergyBody['mood_strength']);
  }

  double? _extractSynergyStrength() {
    final Map<String, Object?> synergyBody =
        microSynergyMap['micro_synergy_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    return _toDouble(synergyBody['spacing_strength']);
  }

  static double _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      target[entry.key] = entry.value ?? '';
    }
    return target;
  }

  static String _ascii(String value) => String.fromCharCodes(
    value.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
