class ReleaseFinalSurfaceV1 {
  const ReleaseFinalSurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object> harmonizationMap,
    required Map<String, Object> scoringMap,
    required Map<String, Object> flagZeroMap,
    required Map<String, Object> coldPathMap,
    required Map<String, Object> consistencyMap,
    required Map<String, Object> stabilityMap,
    required Map<String, Object> personaThemeMap,
    required Map<String, Object> fallbackMap,
    required Map<String, Object> preRCSweepMap,
    required Map<String, Object> rcPackagingMap,
    required Map<String, Object> rcFreezeMap,
    required Map<String, Object> visualQABridgeMap,
    required Map<String, Object> visualQANormalizerMap,
    required Map<String, Object> unifiedReadinessMap,
    required Map<String, Object> finalSignatureMap,
  }) {
    final bool harmonizationOk = _readyFlag(harmonizationMap);
    final bool scoringOk = _readyFlag(scoringMap);
    final bool flagZeroOk = _readyFlag(flagZeroMap);
    final bool coldPathOk = _readyFlag(coldPathMap);
    final bool consistencyOk = _readyFlag(consistencyMap);
    final bool stabilityOk = _readyFlag(stabilityMap);
    final bool personaThemeOk = _readyFlag(personaThemeMap);
    final bool fallbackOk = _readyFlag(fallbackMap);
    final bool preRCSweepOk = _readyFlag(preRCSweepMap);
    final bool rcPackagingOk = _readyFlag(rcPackagingMap);
    final bool rcFreezeOk = _readyFlag(rcFreezeMap);
    final bool visualQAOok = _readyFlag(visualQABridgeMap);
    final bool unifiedReadyOk = _readyFlag(unifiedReadinessMap);
    final bool finalSignatureOk =
        finalSignatureMap['ready'] == true || _readyFlag(finalSignatureMap);
    final Map<String, bool> sections = <String, bool>{
      'harmonization_ok': harmonizationOk,
      'scoring_ok': scoringOk,
      'flag_zero_ok': flagZeroOk,
      'cold_path_ok': coldPathOk,
      'consistency_ok': consistencyOk,
      'stability_ok': stabilityOk,
      'persona_theme_ok': personaThemeOk,
      'fallback_ok': fallbackOk,
      'pre_rc_sweep_ok': preRCSweepOk,
      'rc_packaging_ok': rcPackagingOk,
      'rc_freeze_ok': rcFreezeOk,
      'visual_qa_ok': visualQAOok,
      'unified_ready_ok': unifiedReadyOk,
      'final_signature_ok': finalSignatureOk,
    };
    final List<String> missingSections =
        sections.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final bool allOk = sections.values.every((value) => value);
    final Map<String, Object> signature = <String, Object>{
      'harmonization_keys': _sortedKeys(harmonizationMap),
      'scoring_keys': _sortedKeys(scoringMap),
      'flag_zero_keys': _sortedKeys(flagZeroMap),
      'cold_path_keys': _sortedKeys(coldPathMap),
      'consistency_keys': _sortedKeys(consistencyMap),
      'stability_keys': _sortedKeys(stabilityMap),
      'persona_theme_keys': _sortedKeys(personaThemeMap),
      'fallback_keys': _sortedKeys(fallbackMap),
      'pre_rc_sweep_keys': _sortedKeys(preRCSweepMap),
      'rc_packaging_keys': _sortedKeys(rcPackagingMap),
      'rc_freeze_keys': _sortedKeys(rcFreezeMap),
      'visual_qa_keys': _sortedKeys(visualQABridgeMap),
      'unified_ready_keys': _sortedKeys(unifiedReadinessMap),
      'final_signature_keys': _sortedKeys(finalSignatureMap),
    };
    return <String, Object>{
      'release_final_surface_v1': <String, Object>{
        'final_ready': allOk,
        'all_ok': allOk,
        'sections': sections,
        'missing_sections': missingSections,
        'signature': signature,
        'ready': false,
      },
    };
  }

  static bool _readyFlag(Map<String, Object> map) {
    final Object? ready = map['ready'];
    if (ready is bool) {
      return ready;
    }
    return false;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}
