class ReleaseRCPackagingV1 {
  const ReleaseRCPackagingV1({
    required this.harmonizationMap,
    required this.scoringMap,
    required this.flagZeroingMap,
    required this.coldPathMap,
    required this.consistencyMap,
    required this.stabilityMap,
    required this.personaThemeAlignmentMap,
    required this.fallbackMap,
    required this.preRCSweepMap,
  });

  final Map<String, Object> harmonizationMap;
  final Map<String, Object> scoringMap;
  final Map<String, Object> flagZeroingMap;
  final Map<String, Object> coldPathMap;
  final Map<String, Object> consistencyMap;
  final Map<String, Object> stabilityMap;
  final Map<String, Object> personaThemeAlignmentMap;
  final Map<String, Object> fallbackMap;
  final Map<String, Object> preRCSweepMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> candidate = <String, Object>{
      'harmonization': harmonizationMap,
      'scoring': scoringMap,
      'flag_zeroing': flagZeroingMap,
      'cold_path': coldPathMap,
      'consistency': consistencyMap,
      'stability': stabilityMap,
      'persona_theme_alignment': personaThemeAlignmentMap,
      'fallback': fallbackMap,
      'pre_rc_sweep': preRCSweepMap,
    };
    final Map<String, Object> preSweep = _mapFromKey(
      preRCSweepMap,
      'pre_rc_sweep_v1',
    );
    final bool rcReady = _boolFlag(preSweep, 'ready');
    final Set<String> allKeys = <String>{};
    for (final MapEntry<String, Object> entry in candidate.entries) {
      final List<String> keys = _sortedKeys(entry.value);
      allKeys.addAll(keys);
    }
    final List<String> allKeyList = allKeys.toList()..sort();
    final List<String> missingGlobal = <String>[];
    final Object? missingRaw = preSweep['missing'];
    if (missingRaw is List) {
      for (final Object? entry in missingRaw) {
        if (entry is String && entry.isNotEmpty) {
          missingGlobal.add(entry);
        }
      }
    }
    missingGlobal.sort();
    return <String, Object>{
      'release_candidate_v1': <String, Object>{
        'rc_ready': rcReady,
        'harmonization': harmonizationMap,
        'scoring': scoringMap,
        'flag_zeroing': flagZeroingMap,
        'cold_path': coldPathMap,
        'consistency': consistencyMap,
        'stability': stabilityMap,
        'persona_theme_alignment': personaThemeAlignmentMap,
        'fallback': fallbackMap,
        'pre_rc_sweep': preRCSweepMap,
        'signatures': <String, Object>{
          'all_keys': allKeyList,
          'missing': missingGlobal,
        },
      },
    };
  }

  static List<String> _sortedKeys(Object data) {
    if (data is Map<String, Object>) {
      final List<String> keys = data.keys.toList();
      keys.sort();
      return keys;
    }
    return <String>[];
  }

  static Map<String, Object> _mapFromKey(
    Map<String, Object> source,
    String key,
  ) {
    final Object? value = source[key];
    if (value is Map<String, Object>) {
      return value;
    }
    return <String, Object>{};
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
