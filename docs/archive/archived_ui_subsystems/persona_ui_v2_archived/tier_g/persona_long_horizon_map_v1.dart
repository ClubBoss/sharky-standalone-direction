class PersonaLongHorizonMapV1 {
  const PersonaLongHorizonMapV1({
    this.personaAdaptiveLoadMap = const <String, Object>{},
    this.personaGrowthClustersMap = const <String, Object>{},
    this.personaGrowthProfileMap = const <String, Object>{},
  });

  PersonaLongHorizonMapV1.fromInputs({
    Map<String, Object?>? personaAdaptiveLoadMap,
    Map<String, Object?>? personaGrowthClustersMap,
    Map<String, Object?>? personaGrowthProfileMap,
  }) : this(
         personaAdaptiveLoadMap: _safe(personaAdaptiveLoadMap),
         personaGrowthClustersMap: _safe(personaGrowthClustersMap),
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
       );

  final Map<String, Object> personaAdaptiveLoadMap;
  final Map<String, Object> personaGrowthClustersMap;
  final Map<String, Object> personaGrowthProfileMap;

  Map<String, Object> build() {
    final double a = _extractScore(
      personaAdaptiveLoadMap['persona_adaptive_load_v1']
          as Map<String, Object?>?,
      'load_score',
    );
    final double c = _extractScore(
      personaGrowthClustersMap['persona_growth_clusters_v1']
          as Map<String, Object?>?,
      'cluster_score',
    );
    final double p = _extractScore(
      personaGrowthProfileMap['persona_growth_profile_v1']
          as Map<String, Object?>?,
      'profile_score',
    );
    double futureScore = (a * 0.5) + (c * 0.3) + (p * 0.2);
    futureScore = futureScore.clamp(0.0, 1.0);
    String futureTag = 'trajectory_down';
    if (futureScore >= 0.85) {
      futureTag = 'trajectory_up';
    } else if (futureScore >= 0.60) {
      futureTag = 'trajectory_flat';
    } else if (futureScore >= 0.35) {
      futureTag = 'trajectory_risk';
    }
    return <String, Object>{
      'persona_long_horizon_map_v1': <String, Object>{
        'future_score': futureScore,
        'future_tag': _ascii(futureTag),
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?>? body, String key) {
    if (body == null) return 0.0;
    final Object? raw = body[key];
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
