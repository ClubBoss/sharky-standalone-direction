class ReleaseAssemblyHarmonizationV2 {
  const ReleaseAssemblyHarmonizationV2(this.v4SurfaceMap, this.v3SurfaceMap);

  final Map<String, dynamic> v4SurfaceMap;
  final Map<String, dynamic> v3SurfaceMap;

  Map<String, Object> asReadOnlyMap() {
    final List<String> v4Keys = _sortedKeys(v4SurfaceMap);
    final List<String> v3Keys = _sortedKeys(v3SurfaceMap);
    final List<String> missingInV3 = v4Keys
        .where((key) => !v3Keys.contains(key))
        .toList();
    final List<String> missingInV4 = v3Keys
        .where((key) => !v4Keys.contains(key))
        .toList();
    final bool compatible = missingInV3.isEmpty && missingInV4.isEmpty;
    return <String, Object>{
      'v4_keys': v4Keys,
      'v3_keys': v3Keys,
      'missing_in_v3': missingInV3,
      'missing_in_v4': missingInV4,
      'compatible': compatible,
    };
  }

  static List<String> _sortedKeys(Map<String, dynamic> map) {
    final List<String> keys = map.keys.whereType<String>().toList();
    keys.sort();
    return keys;
  }
}
