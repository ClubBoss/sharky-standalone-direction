class ReleaseVisualQABridgeV1 {
  const ReleaseVisualQABridgeV1({
    this.qaMasterMap = const <String, Object>{},
    this.visualMap = const <String, Object>{},
    this.consistencyMap = const <String, Object>{},
    this.stabilityMap = const <String, Object>{},
    this.flagZeroingMap = const <String, Object>{},
    this.personaAlignmentMap = const <String, Object>{},
  });

  ReleaseVisualQABridgeV1.fromInputs({
    Map<String, Object?>? qaMasterMap,
    Map<String, Object?>? visualMap,
    Map<String, Object?>? consistencyMap,
    Map<String, Object?>? stabilityMap,
    Map<String, Object?>? flagZeroingMap,
    Map<String, Object?>? personaAlignmentMap,
  }) : this(
         qaMasterMap: _safe(qaMasterMap),
         visualMap: _safe(visualMap),
         consistencyMap: _safe(consistencyMap),
         stabilityMap: _safe(stabilityMap),
         flagZeroingMap: _safe(flagZeroingMap),
         personaAlignmentMap: _safe(personaAlignmentMap),
       );

  final Map<String, Object> qaMasterMap;
  final Map<String, Object> visualMap;
  final Map<String, Object> consistencyMap;
  final Map<String, Object> stabilityMap;
  final Map<String, Object> flagZeroingMap;
  final Map<String, Object> personaAlignmentMap;

  Map<String, Object> build() {
    final Map<String, Object?> body =
        qaMasterMap['qa_master_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final List<String> sectionsOk = _sortedKeys(body['sections']);
    final Map<String, bool> sectionsMap = <String, bool>{
      for (final key in sectionsOk)
        key: (body['sections'] as Map<String, Object?>?)?[key] == true,
    };
    final List<String> missingSections =
        sectionsMap.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final List<String> uniqueIssues = _normalizeList(body['unique_issues']);
    final bool visualOk = body['visual_ok'] == true || weightedScore(body) == 0;
    final int totalIssues = _readInt(body['total_issues']);
    final int weightedScoreValue = weightedScore(body);
    final Map<String, Object> bridge = <String, Object>{
      'visual_ok': visualOk,
      'visual_ready': false,
      'total_issues': totalIssues,
      'score': weightedScoreValue,
      'unique_issues': uniqueIssues,
      'sections': sectionsMap,
      'consistency_ok': _ready(consistencyMap),
      'stability_ok': _ready(stabilityMap),
      'flags_ok': _ready(flagZeroingMap),
      'alignment_ok': _ready(personaAlignmentMap),
    };
    return <String, Object>{
      'bridge': bridge,
      'ready': false,
      'sections_ok': sectionsMap,
      'missing_sections': missingSections,
      'issue_count': totalIssues,
      'score': weightedScoreValue,
    };
  }

  static int weightedScore(Map<String, Object?> body) {
    if (body['weighted_score'] is num) {
      return (body['weighted_score'] as num).toInt();
    }
    return 0;
  }

  static bool _ready(Map<String, Object> map) {
    final Object? ready = map['ready'];
    return ready is bool && ready;
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

  static List<String> _sortedKeys(Object? candidate) {
    if (candidate is Map) {
      return candidate.keys.whereType<String>().toList()..sort();
    }
    return <String>[];
  }
}
