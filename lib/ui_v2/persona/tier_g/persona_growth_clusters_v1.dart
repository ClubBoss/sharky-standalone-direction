class PersonaGrowthClustersV1 {
  const PersonaGrowthClustersV1({
    this.personaGrowthProfileMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
    this.personaGrowthDirectionMap = const <String, Object>{},
  });

  PersonaGrowthClustersV1.fromInputs({
    Map<String, Object?>? personaGrowthProfileMap,
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaGrowthDirectionMap,
  }) : this(
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaGrowthDirectionMap: _safe(personaGrowthDirectionMap),
       );

  final Map<String, Object> personaGrowthProfileMap;
  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaGrowthDirectionMap;

  Map<String, Object> build() {
    final double p = _extractDouble(
      personaGrowthProfileMap['persona_growth_profile_v1']
          as Map<String, Object?>?,
      'profile_score',
    );
    final double r = _extractDouble(
      personaReinforcementMap['persona_reinforcement_map_v1']
          as Map<String, Object?>?,
      'reinforcement_score',
    );
    final double g = _extractDouble(
      personaGrowthDirectionMap['persona_growth_direction_v1']
          as Map<String, Object?>?,
      'score',
    );
    double clusterScore = (p * 0.5) + (r * 0.3) + (g * 0.2);
    clusterScore = clusterScore.clamp(0.0, 1.0);
    String clusterTag = 'cluster_foundation';
    if (clusterScore >= 0.8) {
      clusterTag = 'cluster_elite';
    } else if (clusterScore >= 0.6) {
      clusterTag = 'cluster_strong';
    } else if (clusterScore >= 0.4) {
      clusterTag = 'cluster_developing';
    }
    return <String, Object>{
      'persona_growth_clusters_v1': <String, Object>{
        'cluster_tag': _ascii(clusterTag),
        'cluster_score': clusterScore,
        'ready': true,
      },
    };
  }

  static double _extractDouble(Map<String, Object?>? body, String key) {
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

  static String _ascii(String value) => String.fromCharCodes(
    value.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
