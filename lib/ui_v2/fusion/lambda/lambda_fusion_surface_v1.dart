class LambdaFusionSurfaceV1 {
  LambdaFusionSurfaceV1._();

  static Map<String, Object> build({
    Map<String, Object?>? lambdaThemePersonaCoherenceMap,
    Map<String, Object?>? lambdaReleaseDecisionHookMap,
    Map<String, Object?>? lambdaRuntimeBridgeMap,
    Map<String, Object?>? omegaFinalExportMap,
    Map<String, Object?>? omegaMasterBundleMap,
  }) {
    final double coherenceValue = _extractNested(
      lambdaThemePersonaCoherenceMap,
      'lambda_theme_persona_coherence_v1',
      'coherence_value',
      fallback: 0.5,
    );
    final double decisionHookValue = _extractNested(
      lambdaReleaseDecisionHookMap,
      'lambda_release_decision_hook_v1',
      'decision_value',
      fallback: 0.5,
    );
    final double finalExportValue = _extractNested(
      omegaFinalExportMap,
      'omega_final_export_v1',
      'export_value',
      fallback: 0.5,
    );
    final double masterValue = _extractNested(
      omegaMasterBundleMap,
      'omega_master_bundle_v1',
      'master_value',
      fallback: 0.5,
    );

    double fusionValue =
        (coherenceValue * 0.4) +
        (decisionHookValue * 0.3) +
        (finalExportValue * 0.2) +
        (masterValue * 0.1);
    fusionValue = fusionValue.clamp(0.0, 1.0);

    final String coherenceTag = _extractNestedTag(
      lambdaThemePersonaCoherenceMap,
      'lambda_theme_persona_coherence_v1',
      'coherence_tag',
    );
    final String decisionTag = _extractNestedTag(
      lambdaReleaseDecisionHookMap,
      'lambda_release_decision_hook_v1',
      'decision_tag',
    );
    final String invoiceTag = _extractNestedTag(
      omegaFinalExportMap,
      'omega_final_export_v1',
      'export_tag',
    );

    String fusionTag = 'neutral';
    if (coherenceTag == 'aligned') {
      fusionTag = 'aligned';
    } else if (decisionTag.contains('drift')) {
      fusionTag = 'drift';
    } else if (invoiceTag.contains('strong')) {
      fusionTag = 'strong';
    }

    final Map<String, Object> payload = <String, Object>{
      'fusion_value': fusionValue,
      'fusion_tag': _ascii(fusionTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'lambda_fusion_surface_v1': Map<String, Object>.unmodifiable(payload),
    });
  }

  static double _extractNested(
    Map<String, Object?>? map,
    String sectionKey,
    String entryKey, {
    double fallback = 0.0,
  }) {
    if (map == null) return fallback;
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extract(section, entryKey, fallback: fallback);
    }
    return fallback;
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

  static double _extract(
    Map<String, Object> map,
    String key, {
    double fallback = 0.0,
  }) {
    final Object? value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static String _extractTag(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
