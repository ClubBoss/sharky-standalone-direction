class PersonaGrowthConsolidatedV1 {
  const PersonaGrowthConsolidatedV1({
    this.personaGrowthProfileMap = const <String, Object>{},
    this.personaGrowthClustersMap = const <String, Object>{},
    this.personaAdaptiveLoadMap = const <String, Object>{},
    this.personaLongHorizonMap = const <String, Object>{},
  });

  PersonaGrowthConsolidatedV1.fromInputs({
    Map<String, Object?>? personaGrowthProfileMap,
    Map<String, Object?>? personaGrowthClustersMap,
    Map<String, Object?>? personaAdaptiveLoadMap,
    Map<String, Object?>? personaLongHorizonMap,
  }) : this(
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
         personaGrowthClustersMap: _safe(personaGrowthClustersMap),
         personaAdaptiveLoadMap: _safe(personaAdaptiveLoadMap),
         personaLongHorizonMap: _safe(personaLongHorizonMap),
       );

  final Map<String, Object> personaGrowthProfileMap;
  final Map<String, Object> personaGrowthClustersMap;
  final Map<String, Object> personaAdaptiveLoadMap;
  final Map<String, Object> personaLongHorizonMap;

  Map<String, Object> build() {
    final double profileScore = _extractScore(
      personaGrowthProfileMap['persona_growth_profile_v1']
          as Map<String, Object?>?,
      'profile_score',
    );
    final double clusterScore = _extractScore(
      personaGrowthClustersMap['persona_growth_clusters_v1']
          as Map<String, Object?>?,
      'cluster_score',
    );
    final double adaptiveScore = _extractScore(
      personaAdaptiveLoadMap['persona_adaptive_load_v1']
          as Map<String, Object?>?,
      'load_score',
    );
    final double longHorizonScore = _extractScore(
      personaLongHorizonMap['persona_long_horizon_map_v1']
          as Map<String, Object?>?,
      'future_score',
    );
    double masterScore =
        (profileScore + clusterScore + adaptiveScore + longHorizonScore) / 4.0;
    masterScore = masterScore.clamp(0.0, 1.0);
    String masterTag = 'growth_decline';
    if (masterScore >= 0.85) {
      masterTag = 'growth_excellent';
    } else if (masterScore >= 0.60) {
      masterTag = 'growth_stable';
    } else if (masterScore >= 0.40) {
      masterTag = 'growth_choppy';
    }
    return <String, Object>{
      'persona_growth_consolidated_v1': <String, Object>{
        'master_score': masterScore,
        'master_tag': _ascii(masterTag),
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
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      cleaned[entry.key] = entry.value ?? '';
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
