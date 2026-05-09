class UnifiedValidationGateV2 {
  const UnifiedValidationGateV2({
    this.v3SurfaceMap = const <String, Object>{},
    this.v4SurfaceMap = const <String, Object>{},
    this.cSeriesRuntimeEntryMap = const <String, Object>{},
    this.fusionFinalStabilizationMap = const <String, Object>{},
    this.releaseFinalAssemblyMap = const <String, Object>{},
  });

  UnifiedValidationGateV2.fromInputs({
    Map<String, Object?>? v3SurfaceMap,
    Map<String, Object?>? v4SurfaceMap,
    Map<String, Object?>? cSeriesRuntimeEntryMap,
    Map<String, Object?>? fusionFinalStabilizationMap,
    Map<String, Object?>? releaseFinalAssemblyMap,
  }) : this(
         v3SurfaceMap: _safe(v3SurfaceMap),
         v4SurfaceMap: _safe(v4SurfaceMap),
         cSeriesRuntimeEntryMap: _safe(cSeriesRuntimeEntryMap),
         fusionFinalStabilizationMap: _safe(fusionFinalStabilizationMap),
         releaseFinalAssemblyMap: _safe(releaseFinalAssemblyMap),
       );

  final Map<String, Object> v3SurfaceMap;
  final Map<String, Object> v4SurfaceMap;
  final Map<String, Object> cSeriesRuntimeEntryMap;
  final Map<String, Object> fusionFinalStabilizationMap;
  final Map<String, Object> releaseFinalAssemblyMap;

  Map<String, Object> build() => buildUnifiedValidationGateV2(
    v3SurfaceMap: v3SurfaceMap,
    v4SurfaceMap: v4SurfaceMap,
    cSeriesRuntimeEntryMap: cSeriesRuntimeEntryMap,
    fusionFinalStabilizationMap: fusionFinalStabilizationMap,
    releaseFinalAssemblyMap: releaseFinalAssemblyMap,
  );

  static Map<String, Object> buildUnifiedValidationGateV2({
    required Map<String, Object> v3SurfaceMap,
    required Map<String, Object> v4SurfaceMap,
    required Map<String, Object> cSeriesRuntimeEntryMap,
    required Map<String, Object> fusionFinalStabilizationMap,
    required Map<String, Object> releaseFinalAssemblyMap,
  }) {
    final List<String> v3Keys = _sortedKeys(v3SurfaceMap);
    final List<String> v4Keys = _sortedKeys(v4SurfaceMap);
    final List<String> cSeriesKeys = _sortedKeys(cSeriesRuntimeEntryMap);
    final List<String> fusionKeys = _sortedKeys(fusionFinalStabilizationMap);
    final List<String> releaseKeys = _sortedKeys(releaseFinalAssemblyMap);
    final Set<String> allKeys = <String>{
      ...v3Keys,
      ...v4Keys,
      ...cSeriesKeys,
      ...fusionKeys,
      ...releaseKeys,
    };
    final Map<String, Map<String, Object>> sectionsKeys =
        <String, Map<String, Object>>{
          'v3': v3SurfaceMap,
          'v4': v4SurfaceMap,
          'c_series': cSeriesRuntimeEntryMap,
          'fusion': fusionFinalStabilizationMap,
          'release': releaseFinalAssemblyMap,
        };
    final Map<String, bool> sectionsOk = <String, bool>{};
    final Map<String, List<String>> missing = <String, List<String>>{};
    for (final MapEntry<String, Map<String, Object>> entry
        in sectionsKeys.entries) {
      final Map<String, Object> map = entry.value;
      final bool ready = _ready(map);
      sectionsOk[entry.key] = ready;
      final List<String> missingKeys =
          allKeys.where((key) => !map.containsKey(key)).toList()..sort();
      missing[entry.key] = missingKeys;
    }
    final Map<String, List<String>> missingIn = <String, List<String>>{
      'missing_in_v3': missing['v3']!,
      'missing_in_v4': missing['v4']!,
      'missing_in_c_series': missing['c_series']!,
      'missing_in_fusion': missing['fusion']!,
      'missing_in_release': missing['release']!,
    };
    final bool allOk = sectionsOk.values.every((value) => value);
    return <String, Object>{
      'unified_validation_gate_v2': <String, Object>{
        'v3_keys': v3Keys,
        'v4_keys': v4Keys,
        'c_series_keys': cSeriesKeys,
        'fusion_keys': fusionKeys,
        'release_keys': releaseKeys,
        ...missingIn,
        'sections_ok': sectionsOk,
        'all_ok': allOk,
        'ready': false,
      },
    };
  }

  static bool _ready(Map<String, Object> map) {
    final Object? value = map['ready'];
    return value is bool && value;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().map(_ascii).toList()
      ..sort();
    return keys;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      final String key = _ascii(entry.key);
      final Object value = entry.value is String
          ? _ascii(entry.value as String)
          : entry.value ?? '';
      target[key] = value;
    }
    return target;
  }

  static String _ascii(String input) =>
      String.fromCharCodes(input.codeUnits.where((c) => c >= 0 && c < 128));
}
