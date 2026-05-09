class ColdPathValidatorV1 {
  const ColdPathValidatorV1._({
    required this.v4SurfaceMap,
    required this.v3SurfaceMap,
    required this.cSeriesRuntimeSurfaceMap,
    required this.fusionMap,
    required this.contentRootMap,
  });

  factory ColdPathValidatorV1.fromInputs({
    Map<String, Object>? v4SurfaceMap,
    Map<String, Object>? v3SurfaceMap,
    Map<String, Object>? cSeriesRuntimeSurfaceMap,
    Map<String, Object>? fusionMap,
    Map<String, Object>? contentRootMap,
  }) => ColdPathValidatorV1._(
    v4SurfaceMap: _sanitize(v4SurfaceMap),
    v3SurfaceMap: _sanitize(v3SurfaceMap),
    cSeriesRuntimeSurfaceMap: _sanitize(cSeriesRuntimeSurfaceMap),
    fusionMap: _sanitize(fusionMap),
    contentRootMap: _sanitize(contentRootMap),
  );

  final Map<String, Object> v4SurfaceMap;
  final Map<String, Object> v3SurfaceMap;
  final Map<String, Object> cSeriesRuntimeSurfaceMap;
  final Map<String, Object> fusionMap;
  final Map<String, Object> contentRootMap;

  Map<String, Object> build() {
    final Set<String> mergedKeys = <String>{
      ...v4SurfaceMap.keys.whereType<String>(),
      ...v3SurfaceMap.keys.whereType<String>(),
      ...cSeriesRuntimeSurfaceMap.keys.whereType<String>(),
      ...fusionMap.keys.whereType<String>(),
      ...contentRootMap.keys.whereType<String>(),
    };
    final List<String> sortedKeys = mergedKeys.toList()..sort();

    final List<String> missingSections = _computeMissingSections();
    final bool ready = missingSections.isEmpty;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'cold_path_validator_v1':
          Map<String, Object>.unmodifiable(<String, Object>{
            'ready': ready,
            'sections_ok': ready,
            'merged_keys': sortedKeys,
            'missing_sections': missingSections,
          }),
    });
  }

  List<String> _computeMissingSections() {
    final Map<String, Map<String, Object>> sections =
        <String, Map<String, Object>>{
          'v3': v3SurfaceMap,
          'v4': v4SurfaceMap,
          'cseries': cSeriesRuntimeSurfaceMap,
          'fusion': fusionMap,
          'content': contentRootMap,
        };
    final List<String> missing = <String>[];
    for (final MapEntry<String, Map<String, Object>> entry
        in sections.entries) {
      if (!_isReady(entry.value)) {
        missing.add(entry.key);
      }
    }
    missing.sort();
    return missing;
  }

  static bool _isReady(Map<String, Object> map) {
    final Object? direct = map['ready'];
    if (direct is bool) return direct;
    return false;
  }

  static Map<String, Object> _sanitize(Map<String, Object>? map) {
    if (map == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object> entry in map.entries) {
      cleaned[_ascii(entry.key)] = entry.value;
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
