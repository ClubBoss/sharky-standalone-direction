class ReleaseVisualQANormalizerV1 {
  const ReleaseVisualQANormalizerV1({
    this.qaBridgeMap = const <String, Object>{},
    this.stabilityMap = const <String, Object>{},
    this.consistencyMap = const <String, Object>{},
    this.flagZeroingMap = const <String, Object>{},
    this.personaAlignmentMap = const <String, Object>{},
  });

  ReleaseVisualQANormalizerV1.fromInputs({
    Map<String, Object?>? qaBridgeMap,
    Map<String, Object?>? stabilityMap,
    Map<String, Object?>? consistencyMap,
    Map<String, Object?>? flagZeroingMap,
    Map<String, Object?>? personaAlignmentMap,
  }) : this(
         qaBridgeMap: _safe(qaBridgeMap),
         stabilityMap: _safe(stabilityMap),
         consistencyMap: _safe(consistencyMap),
         flagZeroingMap: _safe(flagZeroingMap),
         personaAlignmentMap: _safe(personaAlignmentMap),
       );

  final Map<String, Object> qaBridgeMap;
  final Map<String, Object> stabilityMap;
  final Map<String, Object> consistencyMap;
  final Map<String, Object> flagZeroingMap;
  final Map<String, Object> personaAlignmentMap;

  Map<String, Object> build() {
    final Map<String, Object?> body =
        qaBridgeMap['release_visual_qa_bridge_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final bool visualOk = body['visual_ok'] == true;
    final List<String> sectionsOkKeys = _sortedKeys(body['sections']);
    final int totalIssues = _readInt(body['total_issues']);
    final int weightedScore = _readInt(body['weighted_score']);
    final List<String> uniqueIssues = _normalizeList(body['unique_issues']);
    final Map<String, bool> sections = <String, bool>{
      for (final key in sectionsOkKeys)
        key: (body['sections'] as Map<String, Object?>?)?[key] == true,
    };
    final List<String> missingSections =
        sections.entries.where((e) => !e.value).map((e) => e.key).toList()
          ..sort();
    final Map<String, Object> normalized = <String, Object>{
      'visual_ok': visualOk,
      'visual_ready': false,
      'total_issues': totalIssues,
      'weighted_score': weightedScore,
      'unique_issues': uniqueIssues,
      'sections': sections,
      'consistency_ok': _ready(consistencyMap),
      'stability_ok': _ready(stabilityMap),
      'flags_ok': _ready(flagZeroingMap),
      'alignment_ok': _ready(personaAlignmentMap),
    };
    return <String, Object>{
      'normalized': normalized,
      'ready': false,
      'issues_sorted': uniqueIssues.toList(),
      'sections_ok': sections,
      'missing_sections': missingSections,
    };
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

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static List<String> _normalizeList(Object? value) {
    if (value is Iterable) {
      final List<String> result = value
          .where((v) => v is String)
          .cast<String>()
          .toList();
      result.sort();
      return result;
    }
    return <String>[];
  }

  static List<String> _sortedKeys(Object? maybeMap) {
    if (maybeMap is Map) {
      final List<String> keys = maybeMap.keys.whereType<String>().toList()
        ..sort();
      return keys;
    }
    return <String>[];
  }
}
