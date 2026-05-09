class PersonaMicroScoringV1 {
  const PersonaMicroScoringV1({
    this.tierAEmotionMap = const <String, Object>{},
    this.tierBPersonalizationMap = const <String, Object>{},
    this.microSynergyMap = const <String, Object>{},
  });

  PersonaMicroScoringV1.fromInputs({
    Map<String, Object?>? tierAEmotionMap,
    Map<String, Object?>? tierBPersonalizationMap,
    Map<String, Object?>? microSynergyMap,
  }) : this(
         tierAEmotionMap: _safe(tierAEmotionMap),
         tierBPersonalizationMap: _safe(tierBPersonalizationMap),
         microSynergyMap: _safe(microSynergyMap),
       );

  final Map<String, Object> tierAEmotionMap;
  final Map<String, Object> tierBPersonalizationMap;
  final Map<String, Object> microSynergyMap;

  Map<String, Object> build() {
    final double intensity = _toDouble(tierAEmotionMap['intensity']);
    final double consistency = _toDouble(
      tierBPersonalizationMap['consistency'],
    );
    final Map<String, Object?> synergyBody =
        microSynergyMap['micro_synergy_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final double moodStrength = _toDouble(synergyBody['mood_strength']);
    final double score =
        (intensity * 0.4) + (consistency * 0.4) + (moodStrength * 0.2);
    return <String, Object>{
      'persona_micro_scoring_v1': <String, Object>{
        'score': score,
        'ready': true,
      },
    };
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
}
