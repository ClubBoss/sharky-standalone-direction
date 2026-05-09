class ReleaseStabilityPassV3 {
  const ReleaseStabilityPassV3({
    required this.harmonizationMap,
    required this.scoringMap,
    required this.flagZeroingMap,
    required this.coldPathValidatorMap,
    required this.consistencyMap,
    required this.v4ReadinessMap,
  });

  final Map<String, Object> harmonizationMap;
  final Map<String, Object> scoringMap;
  final Map<String, Object> flagZeroingMap;
  final Map<String, Object> coldPathValidatorMap;
  final Map<String, Object> consistencyMap;
  final Map<String, Object> v4ReadinessMap;

  Map<String, Object> asReadOnlyMap() {
    final List<String> missing = <String>[];
    final Map<String, List<String>> keySets = <String, List<String>>{
      'harmonization': _sortedKeys(harmonizationMap),
      'scoring': _sortedKeys(scoringMap),
      'flags': _sortedKeys(flagZeroingMap),
      'cold_path': _sortedKeys(coldPathValidatorMap),
      'consistency': _sortedKeys(consistencyMap),
      'v4': _sortedKeys(v4ReadinessMap),
    };
    final bool harmonizationReady = _boolFlag(harmonizationMap, 'compatible');
    final bool scoringReady = _boolFlag(scoringMap, 'ready');
    final bool flagsReady = _boolFlag(flagZeroingMap, 'release_ready');
    final bool coldReady = _boolFlag(coldPathValidatorMap, 'validator_ready');
    final bool consistencyReady = _boolFlag(consistencyMap, 'ready');
    final bool v4Ready =
        _boolFlag(v4ReadinessMap, 'ready') ||
        _boolFlag(v4ReadinessMap, 'v4_ready');
    for (final MapEntry<String, List<String>> entry in keySets.entries) {
      if (entry.value.isEmpty) {
        missing.add('${entry.key}_keys_empty');
      }
    }
    if (!harmonizationReady) missing.add('harmonization_not_ready');
    if (!scoringReady) missing.add('scoring_not_ready');
    if (!flagsReady) missing.add('flags_not_ready');
    if (!coldReady) missing.add('cold_path_not_ready');
    if (!consistencyReady) missing.add('consistency_not_ready');
    if (!v4Ready) missing.add('v4_not_ready');
    final Set<String> allKeys = <String>{};
    for (final List<String> keys in keySets.values) {
      allKeys.addAll(keys);
    }
    final List<String> structuralMismatch = <String>[];
    for (final String key in allKeys.toList()..sort()) {
      for (final String mapName in keySets.keys.toList()..sort()) {
        if (!keySets[mapName]!.contains(key)) {
          structuralMismatch.add('${mapName}_missing_$key');
        }
      }
    }
    structuralMismatch.sort();
    missing.addAll(structuralMismatch);
    missing.sort();
    final bool ready =
        harmonizationReady &&
        scoringReady &&
        flagsReady &&
        coldReady &&
        consistencyReady &&
        v4Ready &&
        structuralMismatch.isEmpty;
    return <String, Object>{
      'release_stability_v3': <String, Object>{
        'harmonization_ready': harmonizationReady,
        'scoring_ready': scoringReady,
        'flags_ready': flagsReady,
        'cold_path_ready': coldReady,
        'consistency_ready': consistencyReady,
        'v4_ready': v4Ready,
        'structural_mismatch': structuralMismatch,
      },
      'ready': ready,
      'missing': missing,
    };
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList();
    keys.sort();
    return keys;
  }

  static bool _boolFlag(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
