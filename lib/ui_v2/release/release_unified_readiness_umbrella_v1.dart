class ReleaseUnifiedReadinessUmbrellaV1 {
  const ReleaseUnifiedReadinessUmbrellaV1({
    this.synthesisMap = const <String, Object>{},
    this.visualMap = const <String, Object>{},
    this.consistencyMap = const <String, Object>{},
    this.stabilityMap = const <String, Object>{},
    this.flagZeroingMap = const <String, Object>{},
    this.harmonizationMap = const <String, Object>{},
    this.scoringMap = const <String, Object>{},
    this.fallbackMap = const <String, Object>{},
    this.personaAlignmentMap = const <String, Object>{},
    this.rcPackagingMap = const <String, Object>{},
    this.rcFreezeMap = const <String, Object>{},
    this.notesMap = const <String, Object>{},
    this.coldPathMap = const <String, Object>{},
  });

  ReleaseUnifiedReadinessUmbrellaV1.fromInputs({
    Map<String, Object?>? synthesisMap,
    Map<String, Object?>? visualMap,
    Map<String, Object?>? consistencyMap,
    Map<String, Object?>? stabilityMap,
    Map<String, Object?>? flagZeroingMap,
    Map<String, Object?>? harmonizationMap,
    Map<String, Object?>? scoringMap,
    Map<String, Object?>? fallbackMap,
    Map<String, Object?>? personaAlignmentMap,
    Map<String, Object?>? rcPackagingMap,
    Map<String, Object?>? rcFreezeMap,
    Map<String, Object?>? notesMap,
    Map<String, Object?>? coldPathMap,
  }) : this(
         synthesisMap: _safe(synthesisMap),
         visualMap: _safe(visualMap),
         consistencyMap: _safe(consistencyMap),
         stabilityMap: _safe(stabilityMap),
         flagZeroingMap: _safe(flagZeroingMap),
         harmonizationMap: _safe(harmonizationMap),
         scoringMap: _safe(scoringMap),
         fallbackMap: _safe(fallbackMap),
         personaAlignmentMap: _safe(personaAlignmentMap),
         rcPackagingMap: _safe(rcPackagingMap),
         rcFreezeMap: _safe(rcFreezeMap),
         notesMap: _safe(notesMap),
         coldPathMap: _safe(coldPathMap),
       );

  final Map<String, Object> synthesisMap;
  final Map<String, Object> visualMap;
  final Map<String, Object> consistencyMap;
  final Map<String, Object> stabilityMap;
  final Map<String, Object> flagZeroingMap;
  final Map<String, Object> harmonizationMap;
  final Map<String, Object> scoringMap;
  final Map<String, Object> fallbackMap;
  final Map<String, Object> personaAlignmentMap;
  final Map<String, Object> rcPackagingMap;
  final Map<String, Object> rcFreezeMap;
  final Map<String, Object> notesMap;
  final Map<String, Object> coldPathMap;

  Map<String, Object> build() {
    final Map<String, bool> sectionsOk = <String, bool>{
      'synthesis': _ready(synthesisMap),
      'visual': _ready(visualMap),
      'consistency': _ready(consistencyMap),
      'stability': _ready(stabilityMap),
      'flags': _ready(flagZeroingMap),
      'harmonization': _ready(harmonizationMap),
      'scoring': _ready(scoringMap),
      'fallback': _ready(fallbackMap),
      'persona_alignment': _ready(personaAlignmentMap),
      'rc_packaging': _ready(rcPackagingMap),
      'rc_freeze': _ready(rcFreezeMap),
      'notes': _ready(notesMap),
      'cold_path': _ready(coldPathMap),
    };
    final List<String> missingSections =
        sectionsOk.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final Map<String, Object> signatures = <String, Object>{
      'synthesis_keys': _sortedKeys(synthesisMap),
      'visual_keys': _sortedKeys(visualMap),
      'consistency_keys': _sortedKeys(consistencyMap),
      'stability_keys': _sortedKeys(stabilityMap),
      'flags_keys': _sortedKeys(flagZeroingMap),
      'harmonization_keys': _sortedKeys(harmonizationMap),
      'scoring_keys': _sortedKeys(scoringMap),
      'fallback_keys': _sortedKeys(fallbackMap),
      'persona_alignment_keys': _sortedKeys(personaAlignmentMap),
      'rc_packaging_keys': _sortedKeys(rcPackagingMap),
      'rc_freeze_keys': _sortedKeys(rcFreezeMap),
      'notes_keys': _sortedKeys(notesMap),
      'cold_path_keys': _sortedKeys(coldPathMap),
    };
    final Map<String, Object> bundle = <String, Object>{
      'synthesis': _orderedMap(synthesisMap),
      'visual': _orderedMap(visualMap),
      'consistency': _orderedMap(consistencyMap),
      'stability': _orderedMap(stabilityMap),
      'flags': _orderedMap(flagZeroingMap),
      'harmonization': _orderedMap(harmonizationMap),
      'scoring': _orderedMap(scoringMap),
      'fallback': _orderedMap(fallbackMap),
      'persona_alignment': _orderedMap(personaAlignmentMap),
      'rc_packaging': _orderedMap(rcPackagingMap),
      'rc_freeze': _orderedMap(rcFreezeMap),
      'notes': _orderedMap(notesMap),
      'cold_path': _orderedMap(coldPathMap),
    };
    return <String, Object>{
      'bundle': bundle,
      'ready': false,
      'sections_ok': sectionsOk,
      'missing_sections': missingSections,
      'signatures': signatures,
    };
  }

  static Map<String, Object> _orderedMap(Map<String, Object> input) {
    final Map<String, Object> ordered = <String, Object>{};
    for (final key in _sortedKeys(input)) {
      ordered[key] = input[key] as Object;
    }
    return ordered;
  }

  static List<String> _sortedKeys(Map<String, Object?> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final entry in source.entries) {
      final String key = entry.key;
      final Object value = entry.value ?? '';
      target[key] = value;
    }
    return target;
  }

  static bool _ready(Map<String, Object> map) {
    final Object? ready = map['ready'];
    return ready is bool && ready;
  }
}
