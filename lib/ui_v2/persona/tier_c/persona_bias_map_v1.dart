class PersonaBiasMapV1 {
  const PersonaBiasMapV1({
    this.personaMicroScoreMap = const <String, Object>{},
    this.personaMicroSegmentsMap = const <String, Object>{},
  });

  PersonaBiasMapV1.fromInputs({
    Map<String, Object?>? personaMicroScoreMap,
    Map<String, Object?>? personaMicroSegmentsMap,
  }) : this(
         personaMicroScoreMap: _safe(personaMicroScoreMap),
         personaMicroSegmentsMap: _safe(personaMicroSegmentsMap),
       );

  final Map<String, Object> personaMicroScoreMap;
  final Map<String, Object> personaMicroSegmentsMap;

  Map<String, Object> build() {
    final double score = _extractScore();
    final String segment = _extractSegment();
    final String biasTone = _toneForSegment(segment);
    final double biasStrength = score * 0.75;
    return <String, Object>{
      'persona_bias_map_v1': <String, Object>{
        'bias_tone': biasTone,
        'bias_strength': biasStrength,
        'ready': true,
      },
    };
  }

  String _extractSegment() {
    final Map<String, Object?> segmentsBody =
        personaMicroSegmentsMap['persona_micro_segments_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    return (segmentsBody['segment'] as String? ?? 'neutral').toLowerCase();
  }

  double _extractScore() {
    final Map<String, Object?> scoreBody =
        personaMicroScoreMap['persona_micro_scoring_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    return _toDouble(scoreBody['score']);
  }

  static double _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static String _toneForSegment(String segment) {
    switch (segment) {
      case 'calm':
        return 'soft';
      case 'focused':
        return 'neutral';
      case 'aggressive':
        return 'sharp';
      case 'erratic':
        return 'unstable';
      default:
        return 'neutral';
    }
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
