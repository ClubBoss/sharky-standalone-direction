class PersonaAdaptiveLoadV1 {
  const PersonaAdaptiveLoadV1({
    this.personaGrowthProfileMap = const <String, Object>{},
    this.personaGrowthClustersMap = const <String, Object>{},
  });

  PersonaAdaptiveLoadV1.fromInputs({
    Map<String, Object?>? personaGrowthProfileMap,
    Map<String, Object?>? personaGrowthClustersMap,
  }) : this(
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
         personaGrowthClustersMap: _safe(personaGrowthClustersMap),
       );

  final Map<String, Object> personaGrowthProfileMap;
  final Map<String, Object> personaGrowthClustersMap;

  Map<String, Object> build() {
    final double profileScore = _extractDouble(
      personaGrowthProfileMap['persona_growth_profile_v1'],
      'profile_score',
    );
    final double clusterScore = _extractDouble(
      personaGrowthClustersMap['persona_growth_clusters_v1'],
      'cluster_score',
    );
    double loadScore = (profileScore * 0.6) + (clusterScore * 0.4);
    loadScore = loadScore.clamp(0.0, 1.0);
    String loadTag = 'load_min';
    if (loadScore >= 0.8) {
      loadTag = 'load_high';
    } else if (loadScore >= 0.6) {
      loadTag = 'load_med';
    } else if (loadScore >= 0.4) {
      loadTag = 'load_low';
    }
    return <String, Object>{
      'persona_adaptive_load_v1': <String, Object>{
        'load_score': loadScore,
        'load_tag': _ascii(loadTag),
        'ready': true,
      },
    };
  }

  static double _extractDouble(Object? candidate, String key) {
    if (candidate is Map<String, Object?>) {
      final Object? raw = candidate[key];
      if (raw is num) return raw.toDouble();
      if (raw is String) {
        final double? parsed = double.tryParse(raw);
        if (parsed != null) return parsed;
      }
    }
    return 0.0;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> result = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      result[entry.key] = entry.value ?? '';
    }
    return result;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
