class PersonaLearningBookmarkV1 {
  const PersonaLearningBookmarkV1({
    this.personaContentRouterMap = const <String, Object>{},
    this.personaMicroScoreMap = const <String, Object>{},
    this.personaBiasMap = const <String, Object>{},
  });

  PersonaLearningBookmarkV1.fromInputs({
    Map<String, Object?>? personaContentRouterMap,
    Map<String, Object?>? personaMicroScoreMap,
    Map<String, Object?>? personaBiasMap,
  }) : this(
         personaContentRouterMap: _safe(personaContentRouterMap),
         personaMicroScoreMap: _safe(personaMicroScoreMap),
         personaBiasMap: _safe(personaBiasMap),
       );

  final Map<String, Object> personaContentRouterMap;
  final Map<String, Object> personaMicroScoreMap;
  final Map<String, Object> personaBiasMap;

  Map<String, Object> build() {
    final String route =
        (personaContentRouterMap['persona_content_router_v1']
                as Map<String, Object?>?)?['route']
            as String? ??
        'neutral';
    final double score =
        (personaMicroScoreMap['persona_micro_scoring_v1']
                as Map<String, Object?>?)?['score']
            as double? ??
        _toDouble(
          (personaMicroScoreMap['persona_micro_scoring_v1']
              as Map<String, Object?>?)?['score'],
        );
    final String tone =
        (personaBiasMap['persona_bias_map_v1']
                as Map<String, Object?>?)?['bias_tone']
            as String? ??
        'neutral';
    String bookmark = 'bookmark_neutral';
    if (route == 'c_series') {
      bookmark = 'bookmark_c';
    } else if (route == 'mtt') {
      bookmark = 'bookmark_m';
    }
    final String reason =
        'route_${_ascii(route)}_tone_${_ascii(tone.toLowerCase())}';
    return <String, Object>{
      'persona_learning_bookmark_v1': <String, Object>{
        'bookmark': _ascii(bookmark),
        'reason': reason,
        'ready': true,
      },
    };
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      target[entry.key] = entry.value ?? '';
    }
    return target;
  }

  static double _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
