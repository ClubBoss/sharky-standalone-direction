class ReleaseRCFreezeV1 {
  const ReleaseRCFreezeV1({required this.rcBundleMap});

  final Map<String, Object> rcBundleMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> candidate = _mapFromKey(
      rcBundleMap,
      'release_candidate_v1',
    );
    final bool freezeOk = _boolFlag(candidate, 'rc_ready');
    final List<String> frozenKeys = candidate.keys.whereType<String>().toList()
      ..sort();
    return <String, Object>{
      'rc_freeze_v1': <String, Object>{
        'freeze_ok': freezeOk,
        'frozen_keys': frozenKeys,
        'release_candidate': candidate,
        'ready': freezeOk,
      },
    };
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
