class ReleaseNotesGeneratorV1 {
  const ReleaseNotesGeneratorV1({
    required this.harmonizationMap,
    required this.scoringMap,
    required this.flagZeroingMap,
    required this.coldPathMap,
    required this.consistencyMap,
    required this.stabilityMap,
    required this.personaThemeAlignmentMap,
    required this.fallbackMap,
    required this.preRCSweepMap,
    required this.rcBundleMap,
    required this.rcFreezeMap,
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
  final Map<String, Object> rcBundleMap;
  final Map<String, Object> rcFreezeMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> rcCandidate = _mapFromKey(
      rcBundleMap,
      'release_candidate_v1',
    );
    final Map<String, Object> rcFrozen = _mapFromKey(
      rcFreezeMap,
      'rc_freeze_v1',
    );
    final bool rcReady = _boolFlag(rcCandidate, 'rc_ready');
    final bool freezeOk = _boolFlag(rcFrozen, 'freeze_ok');
    final List<String> sections = <String>[
      _section('Harmonization', harmonizationMap, 'compatible'),
      _section('Scoring', scoringMap, 'ready'),
      _section('Flags', flagZeroingMap, 'release_ready'),
      _section('ColdPath', coldPathMap, 'validator_ready'),
      _section('Consistency', consistencyMap, 'ready'),
      _section('Stability', stabilityMap, 'ready'),
      _section('PersonaTheme', personaThemeAlignmentMap, 'ready'),
      _section('Fallback', fallbackMap, 'ready'),
      _section('PreRCSweep', preRCSweepMap, 'ready'),
      'RCPackaging: rc_ready=$rcReady',
      'RCFreeze: freeze_ok=$freezeOk',
    ];
    sections.sort();
    final bool ready = rcReady && freezeOk;
    return <String, Object>{
      'release_notes_v1': <String, Object>{
        'sections': sections,
        'ready': ready,
      },
    };
  }

  static String _section(
    String label,
    Map<String, Object> map,
    String flagKey,
  ) {
    final bool value = _boolFlag(map, flagKey);
    final String keys = _sortedKeys(map).join(',');
    final String extra = value && map.containsKey('score_v')
        ? ', version=${map['score_v']}'
        : '';
    return '$label: ready=$value, keys=[$keys]$extra';
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList();
    keys.sort();
    return keys;
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
