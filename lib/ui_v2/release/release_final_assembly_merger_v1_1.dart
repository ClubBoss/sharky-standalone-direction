class ReleaseFinalAssemblyMergerV1_1 {
  const ReleaseFinalAssemblyMergerV1_1({
    this.finalSurfaceMap = const <String, Object>{},
    this.finalSignatureMap = const <String, Object>{},
    this.unifiedReadinessMap = const <String, Object>{},
    this.visualQABridgeMap = const <String, Object>{},
    this.visualQANormalizerMap = const <String, Object>{},
    this.rcPackagingMap = const <String, Object>{},
    this.rcFreezeMap = const <String, Object>{},
    this.releaseNotesMap = const <String, Object>{},
  });

  ReleaseFinalAssemblyMergerV1_1.fromInputs({
    Map<String, Object?>? finalSurfaceMap,
    Map<String, Object?>? finalSignatureMap,
    Map<String, Object?>? unifiedReadinessMap,
    Map<String, Object?>? visualQABridgeMap,
    Map<String, Object?>? visualQANormalizerMap,
    Map<String, Object?>? rcPackagingMap,
    Map<String, Object?>? rcFreezeMap,
    Map<String, Object?>? releaseNotesMap,
  }) : this(
         finalSurfaceMap: _safe(finalSurfaceMap),
         finalSignatureMap: _safe(finalSignatureMap),
         unifiedReadinessMap: _safe(unifiedReadinessMap),
         visualQABridgeMap: _safe(visualQABridgeMap),
         visualQANormalizerMap: _safe(visualQANormalizerMap),
         rcPackagingMap: _safe(rcPackagingMap),
         rcFreezeMap: _safe(rcFreezeMap),
         releaseNotesMap: _safe(releaseNotesMap),
       );

  final Map<String, Object> finalSurfaceMap;
  final Map<String, Object> finalSignatureMap;
  final Map<String, Object> unifiedReadinessMap;
  final Map<String, Object> visualQABridgeMap;
  final Map<String, Object> visualQANormalizerMap;
  final Map<String, Object> rcPackagingMap;
  final Map<String, Object> rcFreezeMap;
  final Map<String, Object> releaseNotesMap;

  Map<String, Object> build() {
    final List<MapEntry<String, Map<String, Object>>> sections =
        <MapEntry<String, Map<String, Object>>>[
          MapEntry('final_surface_v1', finalSurfaceMap),
          MapEntry('final_signature_v1', finalSignatureMap),
          MapEntry('unified_readiness_v1', unifiedReadinessMap),
          MapEntry('visual_qa_bridge_v1', visualQABridgeMap),
          MapEntry('visual_qa_normalizer_v1', visualQANormalizerMap),
          MapEntry('rc_packaging_v1', rcPackagingMap),
          MapEntry('rc_freeze_v1', rcFreezeMap),
          MapEntry('release_notes_v1', releaseNotesMap),
        ];

    final List<String> sectionsOk =
        sections
            .where((entry) => _ready(entry.value))
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final List<String> missingSections =
        sections
            .where((entry) => !_ready(entry.value))
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final List<String> signature = _sortedKeys(<String, Object>{
      ...finalSurfaceMap,
      ...finalSignatureMap,
      ...unifiedReadinessMap,
      ...visualQABridgeMap,
      ...visualQANormalizerMap,
      ...rcPackagingMap,
      ...rcFreezeMap,
      ...releaseNotesMap,
    });
    final int totalIssues = _collectTotalIssues();
    return <String, Object>{
      'release_final_assembly_v1_1': <String, Object>{
        'sections_ok': sectionsOk,
        'missing_sections': missingSections,
        'signature': signature,
        'total_issues': totalIssues,
        'ready': false,
      },
    };
  }

  int _collectTotalIssues() {
    final List<String> finalSignatureIssues = _normalizeList(
      _extractBody(finalSignatureMap, 'final_signature_v1')['unique_issues'],
    );
    final List<String> readinessIssues = _normalizeList(
      _extractBody(
        unifiedReadinessMap,
        'release_unified_readiness_v1',
      )['unique_issues'],
    );
    final List<String> visualNormalizerIssues = _normalizeList(
      _extractBody(
        visualQANormalizerMap,
        'release_visual_qa_normalizer_v1',
      )['unique_issues'],
    );
    final List<String> bridgeIssues = _normalizeList(
      _extractBody(visualQABridgeMap, 'bridge')['unique_issues'],
    );
    final Set<String> uniqueIssues = <String>{
      ...finalSignatureIssues,
      ...readinessIssues,
      ...visualNormalizerIssues,
      ...bridgeIssues,
    };
    return uniqueIssues.length;
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

  static bool _ready(Map<String, Object> map) {
    final Object? readyValue = map['ready'];
    if (readyValue is bool) {
      return readyValue;
    }
    for (final Object value in map.values) {
      if (value is Map) {
        final Object? nestedReady = value['ready'];
        if (nestedReady is bool && nestedReady) {
          return true;
        }
      }
    }
    return false;
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
