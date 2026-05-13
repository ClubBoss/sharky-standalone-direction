class TalentSignalExtractorV1 {
  const TalentSignalExtractorV1({
    this.personaMicroScoringMap = const <String, Object>{},
    this.personaMicroSegmentsMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
    this.personaTablePersonaLiftMap = const <String, Object>{},
  });

  TalentSignalExtractorV1.fromInputs({
    Map<String, Object?>? personaMicroScoringMap,
    Map<String, Object?>? personaMicroSegmentsMap,
    Map<String, Object?>? personaDifficultyBiasMap,
    Map<String, Object?>? personaTablePersonaLiftMap,
  }) : this(
         personaMicroScoringMap: _safe(personaMicroScoringMap),
         personaMicroSegmentsMap: _safe(personaMicroSegmentsMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
         personaTablePersonaLiftMap: _safe(personaTablePersonaLiftMap),
       );

  final Map<String, Object> personaMicroScoringMap;
  final Map<String, Object> personaMicroSegmentsMap;
  final Map<String, Object> personaDifficultyBiasMap;
  final Map<String, Object> personaTablePersonaLiftMap;

  Map<String, Object> build() {
    final Map<String, Object?> scoringBody =
        personaMicroScoringMap['persona_micro_scoring_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> liftBody =
        personaTablePersonaLiftMap['persona_table_persona_lift_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final double scoreC = _toDouble(scoringBody['score']);
    final double diffE = _toDouble(difficultyBody['difficulty']);
    final double liftI = _toDouble(liftBody['intensity']);
    double talentScore = scoreC * 0.5 + diffE * 0.3 + liftI * 0.2;
    talentScore = talentScore.clamp(0.0, 1.0);
    final String segment =
        (personaMicroSegmentsMap['persona_micro_segments_v1']
                as Map<String, Object?>?)?['segment']
            as String? ??
        'neutral';
    final String tag = 'talent_${segment.toLowerCase()}';
    return <String, Object>{
      'talent_signal_extractor_v1': <String, Object>{
        'talent_score': talentScore,
        'talent_tag': _ascii(tag),
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
