class LambdaReleaseDecisionHookV1 {
  LambdaReleaseDecisionHookV1._();

  static Map<String, Object> build({
    Map<String, Object?>? lambdaRuntimeBridgeMap,
    Map<String, Object?>? omegaFinalExportMap,
    Map<String, Object?>? omegaMasterBundleMap,
    Map<String, Object?>? personaGlobalV1Map,
  }) {
    final double bridgeValue = _extractNested(
      lambdaRuntimeBridgeMap,
      'lambda_runtime_bridge_v1',
      'bridge_value',
    );
    final double exportValue = _extractNested(
      omegaFinalExportMap,
      'omega_final_export_v1',
      'export_value',
    );
    final double masterValue = _extractNested(
      omegaMasterBundleMap,
      'omega_master_bundle_v1',
      'master_value',
    );
    final double globalValue = _extractNested(
      personaGlobalV1Map,
      'persona_global_v1',
      'global_score',
    );

    double decisionValue =
        (bridgeValue * 0.4) +
        (exportValue * 0.3) +
        (masterValue * 0.2) +
        (globalValue * 0.1);
    decisionValue = decisionValue.clamp(0.0, 1.0);

    String decisionTag = _extractNestedTag(
      lambdaRuntimeBridgeMap,
      'lambda_runtime_bridge_v1',
      'bridge_tag',
    );
    if (decisionTag.isEmpty) {
      decisionTag = _extractNestedTag(
        omegaFinalExportMap,
        'omega_final_export_v1',
        'export_tag',
      );
    }
    if (decisionTag.isEmpty) {
      decisionTag = _extractNestedTag(
        omegaMasterBundleMap,
        'omega_master_bundle_v1',
        'master_tag',
      );
    }
    if (decisionTag.isEmpty) {
      decisionTag = _extractNestedTag(
        personaGlobalV1Map,
        'persona_global_v1',
        'global_tag',
      );
    }
    if (decisionTag.isEmpty) decisionTag = 'lambda_decision';

    final Map<String, Object> payload = <String, Object>{
      'decision_value': decisionValue,
      'decision_tag': _ascii(decisionTag),
      'ready': true,
    };
    return Map<String, Object>.unmodifiable(<String, Object>{
      'lambda_release_decision_hook_v1': Map<String, Object>.unmodifiable(
        payload,
      ),
    });
  }

  static double _extractNested(
    Map<String, Object?>? map,
    String sectionKey,
    String entryKey,
  ) {
    if (map == null) return 0.0;
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extract(section, entryKey);
    }
    return 0.0;
  }

  static String _extractNestedTag(
    Map<String, Object?>? map,
    String sectionKey,
    String entryKey,
  ) {
    if (map == null) return '';
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extractTag(section, entryKey);
    }
    return '';
  }

  static double _extract(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static String _extractTag(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
