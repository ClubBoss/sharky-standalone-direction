class ReleaseConsistencyV3 {
  const ReleaseConsistencyV3({
    required this.harmonizationMap,
    required this.scoringMap,
    required this.flagZeroingMap,
    required this.coldPathValidatorMap,
    required this.v4ReadinessMap,
  });

  final Map<String, Object> harmonizationMap;
  final Map<String, Object> scoringMap;
  final Map<String, Object> flagZeroingMap;
  final Map<String, Object> coldPathValidatorMap;
  final Map<String, Object> v4ReadinessMap;

  Map<String, Object> asReadOnlyMap() {
    final List<String> missing = <String>[];
    final List<String> harmonizationKeys = _sortedKeys(harmonizationMap);
    final bool harmonizationReady = _boolFlag(harmonizationMap, 'compatible');
    if (harmonizationKeys.isEmpty) {
      missing.add('harmonization_keys_empty');
    }
    if (!harmonizationReady) {
      missing.add('harmonization_not_ready');
    }
    final List<String> scoringKeys = _sortedKeys(scoringMap);
    final bool scoringReady = _boolFlag(scoringMap, 'ready');
    if (scoringKeys.isEmpty) {
      missing.add('scoring_keys_empty');
    }
    if (!scoringReady) {
      missing.add('scoring_not_ready');
    }
    final List<String> flagKeys = _sortedKeys(flagZeroingMap);
    final bool flagsReady = _boolFlag(flagZeroingMap, 'release_ready');
    if (flagKeys.isEmpty) {
      missing.add('flags_keys_empty');
    }
    if (!flagsReady) {
      missing.add('flags_not_ready');
    }
    final List<String> coldKeys = _sortedKeys(coldPathValidatorMap);
    final bool coldReady = _boolFlag(coldPathValidatorMap, 'validator_ready');
    if (coldKeys.isEmpty) {
      missing.add('cold_path_keys_empty');
    }
    if (!coldReady) {
      missing.add('cold_path_not_ready');
    }
    final List<String> v4Keys = _sortedKeys(v4ReadinessMap);
    final bool v4Ready =
        _boolFlag(v4ReadinessMap, 'readiness') ||
        _boolFlag(v4ReadinessMap, 'v4_ready');
    if (v4Keys.isEmpty) {
      missing.add('v4_keys_empty');
    }
    if (!v4Ready) {
      missing.add('v4_not_ready');
    }
    missing.sort();
    final bool ready =
        harmonizationReady &&
        scoringReady &&
        flagsReady &&
        coldReady &&
        v4Ready;
    return <String, Object>{
      'release_consistency_v3': <String, Object>{
        'harmonization_ready': harmonizationReady,
        'scoring_ready': scoringReady,
        'flags_ready': flagsReady,
        'cold_path_ready': coldReady,
        'v4_ready': v4Ready,
        'harmonization_keys': harmonizationKeys,
        'scoring_keys': scoringKeys,
        'flags_keys': flagKeys,
        'cold_path_keys': coldKeys,
        'v4_keys': v4Keys,
        'missing': missing,
      },
      'ready': ready,
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
