class ReleaseV4ToV3FallbackTestV1 {
  const ReleaseV4ToV3FallbackTestV1({
    required this.v4ReadinessMap,
    required this.v4SurfaceMap,
    required this.v3SurfaceMap,
    required this.stabilityMap,
    required this.personaThemeAlignmentMap,
  });

  final Map<String, Object> v4ReadinessMap;
  final Map<String, Object> v4SurfaceMap;
  final Map<String, Object> v3SurfaceMap;
  final Map<String, Object> stabilityMap;
  final Map<String, Object> personaThemeAlignmentMap;

  Map<String, Object> asReadOnlyMap() {
    final bool v4Ready = _boolFlag(v4ReadinessMap, 'v4_ready');
    final List<String> v4Keys = _sortedKeys(v4SurfaceMap);
    final List<String> v3Keys = _sortedKeys(v3SurfaceMap);
    final List<String> missingInV3 = v4Keys
        .where((key) => !v3Keys.contains(key))
        .toList();
    final List<String> missingInV4 = v3Keys
        .where((key) => !v4Keys.contains(key))
        .toList();
    final bool fallbackRequired = !v4Ready;
    final bool fallbackOk =
        !fallbackRequired || (missingInV3.isEmpty && missingInV4.isEmpty);
    final bool stabilityReady = _boolFlag(stabilityMap, 'ready');
    final bool alignmentReady = _boolFlag(personaThemeAlignmentMap, 'ready');
    final bool ready =
        stabilityReady &&
        alignmentReady &&
        (fallbackRequired ? fallbackOk : true);
    missingInV3.sort();
    missingInV4.sort();
    return <String, Object>{
      'v4_to_v3_fallback_test_v1': <String, Object>{
        'fallback_required': fallbackRequired,
        'fallback_ok': fallbackOk,
        'v3_keys': v3Keys,
        'v4_keys': v4Keys,
        'missing_in_v3': missingInV3,
        'missing_in_v4': missingInV4,
        'ready': ready,
      },
      'ready': ready,
    };
  }

  static List<String> _sortedKeys(Map<String, Object> source) {
    final List<String> keys = source.keys.whereType<String>().toList();
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
