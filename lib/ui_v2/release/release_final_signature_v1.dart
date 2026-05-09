class ReleaseFinalSignatureV1 {
  const ReleaseFinalSignatureV1({
    this.synthesisMap = const <String, Object>{},
    this.unifiedReadinessMap = const <String, Object>{},
    this.visualNormalizerMap = const <String, Object>{},
    this.rcPackagingMap = const <String, Object>{},
    this.rcFreezeMap = const <String, Object>{},
    this.notesMap = const <String, Object>{},
  });

  ReleaseFinalSignatureV1.fromInputs({
    Map<String, Object?>? synthesisMap,
    Map<String, Object?>? unifiedReadinessMap,
    Map<String, Object?>? visualNormalizerMap,
    Map<String, Object?>? rcPackagingMap,
    Map<String, Object?>? rcFreezeMap,
    Map<String, Object?>? notesMap,
  }) : this(
         synthesisMap: _safe(synthesisMap),
         unifiedReadinessMap: _safe(unifiedReadinessMap),
         visualNormalizerMap: _safe(visualNormalizerMap),
         rcPackagingMap: _safe(rcPackagingMap),
         rcFreezeMap: _safe(rcFreezeMap),
         notesMap: _safe(notesMap),
       );

  final Map<String, Object> synthesisMap;
  final Map<String, Object> unifiedReadinessMap;
  final Map<String, Object> visualNormalizerMap;
  final Map<String, Object> rcPackagingMap;
  final Map<String, Object> rcFreezeMap;
  final Map<String, Object> notesMap;

  Map<String, Object> build() {
    final Map<String, Object?> synthesisBody = _extractBody(
      synthesisMap,
      'release_synthesis_surface_v1',
    );
    final Map<String, Object?> readinessBody = _extractBody(
      unifiedReadinessMap,
      'release_unified_readiness_v1',
    );
    final Map<String, Object?> visualBody = _extractBody(
      visualNormalizerMap,
      'release_visual_qa_normalizer_v1',
    );
    final bool synthesisOk = synthesisBody['release_ok'] == true;
    final bool umbrellaOk = readinessBody['ready'] == true;
    final bool visualOk = visualBody['visual_ok'] == true;
    final bool packagingOk = rcPackagingMap['rc_ready'] == true;
    final bool freezeOk = _freezeOk(rcFreezeMap);
    final bool notesOk = _ready(notesMap['release_notes_v1']);
    final bool ready =
        synthesisOk &&
        umbrellaOk &&
        visualOk &&
        packagingOk &&
        freezeOk &&
        notesOk;
    final int score = _readInt(synthesisBody['weighted_score']);
    final Set<String> uniqueIssues = <String>{
      ..._normalizeList(synthesisBody['unique_issues']),
      ..._normalizeList(readinessBody['unique_issues']),
    };
    final List<String> sortedIssues = uniqueIssues.toList()..sort();
    final Map<String, bool> sectionsOk = <String, bool>{
      'synthesis_ok': synthesisOk,
      'umbrella_ok': umbrellaOk,
      'visual_ok': visualOk,
      'packaging_ok': packagingOk,
      'freeze_ok': freezeOk,
      'notes_ok': notesOk,
    };
    final List<String> missingSections =
        sectionsOk.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final List<String> signature = _sortedKeys(<String, Object>{
      ...synthesisMap,
      ...unifiedReadinessMap,
      ...visualNormalizerMap,
      ...rcPackagingMap,
      ...rcFreezeMap,
      ...notesMap,
    });
    return <String, Object>{
      'final_signature_v1': <String, Object>{
        'ready': ready,
        'score': score,
        'issue_count': sortedIssues.length,
        'unique_issues': sortedIssues,
        'sections': sectionsOk,
      },
      'ready': false,
      'sections_ok': sectionsOk,
      'missing_sections': missingSections,
      'signature': signature,
    };
  }

  static Map<String, Object?> _extractBody(
    Map<String, Object> map,
    String key,
  ) {
    final Object? candidate = map[key];
    if (candidate is Map<String, Object?>) {
      return candidate;
    }
    if (candidate is Map) {
      return candidate.cast<String, Object?>();
    }
    return <String, Object?>{};
  }

  static bool _ready(Object? candidate) {
    if (candidate is Map) {
      final Object? ready = candidate['ready'];
      return ready is bool && ready;
    }
    return false;
  }

  static bool _freezeOk(Map<String, Object> map) {
    final Object? candidate = map['rc_freeze_v1'];
    if (candidate is Map) {
      final Object? freezeOk = candidate['freeze_ok'];
      if (freezeOk is bool) {
        return freezeOk;
      }
      if (freezeOk is num) {
        return freezeOk != 0;
      }
      if (freezeOk is String) {
        final String normalized = freezeOk.toLowerCase();
        return normalized == 'true' || normalized == '1';
      }
    }
    return false;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static List<String> _normalizeList(Object? input) {
    if (input is Iterable) {
      final List<String> strings = input
          .whereType<String>()
          .map(_ascii)
          .toList();
      strings.sort();
      return strings;
    }
    return <String>[];
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
