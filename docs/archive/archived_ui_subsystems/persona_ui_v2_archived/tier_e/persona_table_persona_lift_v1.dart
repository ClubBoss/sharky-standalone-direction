class PersonaTablePersonaLiftV1 {
  const PersonaTablePersonaLiftV1({
    this.personaDifficultyBiasMap = const <String, Object>{},
    this.personaLearningBookmarkMap = const <String, Object>{},
    this.personaBiasMap = const <String, Object>{},
  });

  PersonaTablePersonaLiftV1.fromInputs({
    Map<String, Object?>? personaDifficultyBiasMap,
    Map<String, Object?>? personaLearningBookmarkMap,
    Map<String, Object?>? personaBiasMap,
  }) : this(
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
         personaLearningBookmarkMap: _safe(personaLearningBookmarkMap),
         personaBiasMap: _safe(personaBiasMap),
       );

  final Map<String, Object> personaDifficultyBiasMap;
  final Map<String, Object> personaLearningBookmarkMap;
  final Map<String, Object> personaBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> bookmarkBody =
        personaLearningBookmarkMap['persona_learning_bookmark_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> biasBody =
        personaBiasMap['persona_bias_map_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final double diff = _toDouble(difficultyBody['difficulty']);
    final String bookmark =
        (bookmarkBody['bookmark'] as String? ?? 'bookmark_neutral')
            .toLowerCase();
    final String tone = (biasBody['bias_tone'] as String? ?? 'neutral')
        .toLowerCase();
    double intensity = diff * 0.7 + (tone == 'aggressive' ? 0.2 : 0.0);
    intensity = intensity.clamp(0.0, 1.0);
    final String liftTag = 'persona_lift_${bookmark}_$tone';
    return <String, Object>{
      'persona_table_persona_lift_v1': <String, Object>{
        'lift_tag': _ascii(liftTag),
        'intensity': intensity,
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

  static String _ascii(String value) => String.fromCharCodes(
    value.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
