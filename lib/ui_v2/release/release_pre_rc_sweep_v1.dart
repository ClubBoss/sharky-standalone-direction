class ReleasePreRCSweepV1 {
  const ReleasePreRCSweepV1({
    required this.harmonizationMap,
    required this.scoringMap,
    required this.flagZeroingMap,
    required this.coldPathMap,
    required this.consistencyMap,
    required this.stabilityMap,
    required this.personaThemeAlignmentMap,
    required this.v4ToV3FallbackMap,
  });

  final Map<String, Object> harmonizationMap;
  final Map<String, Object> scoringMap;
  final Map<String, Object> flagZeroingMap;
  final Map<String, Object> coldPathMap;
  final Map<String, Object> consistencyMap;
  final Map<String, Object> stabilityMap;
  final Map<String, Object> personaThemeAlignmentMap;
  final Map<String, Object> v4ToV3FallbackMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, List<String>> signatures = <String, List<String>>{
      'harmonization': _sortedKeys(harmonizationMap),
      'scoring': _sortedKeys(scoringMap),
      'flag_zeroing': _sortedKeys(flagZeroingMap),
      'cold_path': _sortedKeys(coldPathMap),
      'consistency': _sortedKeys(consistencyMap),
      'stability': _sortedKeys(stabilityMap),
      'persona_theme': _sortedKeys(personaThemeAlignmentMap),
      'fallback': _sortedKeys(v4ToV3FallbackMap),
    };
    final Map<String, bool> readyFlags = <String, bool>{
      'harmonization': _boolFlagWithFallback(harmonizationMap, const <String>[
        'ready',
        'compatible',
      ]),
      'scoring': _boolFlagWithFallback(scoringMap, const <String>['ready']),
      'flag_zeroing': _boolFlagWithFallback(flagZeroingMap, const <String>[
        'release_ready',
      ]),
      'cold_path': _boolFlagWithFallback(coldPathMap, const <String>[
        'ready',
        'validator_ready',
      ]),
      'consistency': _boolFlagWithFallback(consistencyMap, const <String>[
        'ready',
      ]),
      'stability': _boolFlagWithFallback(stabilityMap, const <String>['ready']),
      'persona_theme': _boolFlagWithFallback(
        personaThemeAlignmentMap,
        const <String>['ready'],
      ),
      'fallback': _boolFlagWithFallback(v4ToV3FallbackMap, const <String>[
        'ready',
      ]),
    };
    final List<String> missing = <String>[];
    for (final MapEntry<String, List<String>> entry in signatures.entries) {
      if (entry.value.isEmpty) {
        missing.add('${entry.key}_keys_empty');
      }
      if (!readyFlags[entry.key]!) {
        missing.add('${entry.key}_not_ready');
      }
    }
    missing.sort();
    final bool ready = readyFlags.values.every((value) => value);
    return <String, Object>{
      'pre_rc_sweep_v1': <String, Object>{
        'ready': ready,
        'all_ready_flags': readyFlags,
        'missing': missing,
        'signatures': signatures,
      },
    };
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList();
    keys.sort();
    return keys;
  }

  static bool _boolFlagWithFallback(
    Map<String, Object> map,
    List<String> keys,
  ) {
    for (final String key in keys) {
      if (_boolFlag(map, key)) {
        return true;
      }
    }
    return false;
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
