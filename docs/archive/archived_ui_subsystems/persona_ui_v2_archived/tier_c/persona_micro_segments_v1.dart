class PersonaMicroSegmentsV1 {
  const PersonaMicroSegmentsV1({
    this.tierAEmotionMap = const <String, Object>{},
    this.tierBPersonalizationMap = const <String, Object>{},
    this.personaMicroScoreMap = const <String, Object>{},
  });

  PersonaMicroSegmentsV1.fromInputs({
    Map<String, Object?>? tierAEmotionMap,
    Map<String, Object?>? tierBPersonalizationMap,
    Map<String, Object?>? personaMicroScoreMap,
  }) : this(
         tierAEmotionMap: _safe(tierAEmotionMap),
         tierBPersonalizationMap: _safe(tierBPersonalizationMap),
         personaMicroScoreMap: _safe(personaMicroScoreMap),
       );

  final Map<String, Object> tierAEmotionMap;
  final Map<String, Object> tierBPersonalizationMap;
  final Map<String, Object> personaMicroScoreMap;

  Map<String, Object> build() {
    final double score = _extractScore();
    final String segment = _segmentForScore(score);
    final String intensityHint = _ascii(
      (tierAEmotionMap['intensity'] ?? '').toString(),
    );
    return <String, Object>{
      'persona_micro_segments_v1': <String, Object>{
        'segment': segment,
        'intensity_hint': intensityHint,
        'ready': true,
      },
    };
  }

  double _extractScore() {
    final Map<String, Object?> scoreBody =
        personaMicroScoreMap['persona_micro_scoring_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    return _toDouble(scoreBody['score']);
  }

  String _segmentForScore(double score) {
    if (score < 0.25) return 'calm';
    if (score < 0.5) return 'focused';
    if (score < 0.75) return 'aggressive';
    return 'erratic';
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

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
