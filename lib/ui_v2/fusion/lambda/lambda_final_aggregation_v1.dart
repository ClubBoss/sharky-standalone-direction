class LambdaFinalAggregationV1 {
  LambdaFinalAggregationV1._();

  static Map<String, Object> build({
    Map<String, Object?>? lambdaFusionSurfaceMap,
    Map<String, Object?>? lambdaThemePersonaCoherenceMap,
    Map<String, Object?>? lambdaReleaseDecisionHookMap,
    Map<String, Object?>? lambdaRuntimeBridgeMap,
    Map<String, Object?>? omegaFinalExportMap,
    Map<String, Object?>? omegaMasterBundleMap,
  }) {
    final double fusionValue = _extractNested(
      lambdaFusionSurfaceMap,
      'lambda_fusion_surface_v1',
      'fusion_value',
      fallback: 0.5,
    );
    final double coherenceValue = _extractNested(
      lambdaThemePersonaCoherenceMap,
      'lambda_theme_persona_coherence_v1',
      'coherence_value',
      fallback: 0.5,
    );
    final double decisionValue = _extractNested(
      lambdaReleaseDecisionHookMap,
      'lambda_release_decision_hook_v1',
      'decision_value',
      fallback: 0.5,
    );
    final double bridgeValue = _extractNested(
      lambdaRuntimeBridgeMap,
      'lambda_runtime_bridge_v1',
      'bridge_value',
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

    double aggregationValue =
        (fusionValue * 0.4) +
        (coherenceValue * 0.25) +
        (decisionValue * 0.2) +
        (finalExportValue * 0.1) +
        (masterValue * 0.05);
    aggregationValue = aggregationValue.clamp(0.0, 1.0);

    final String fusionTag = _extractNestedTag(
      lambdaFusionSurfaceMap,
      'lambda_fusion_surface_v1',
      'fusion_tag',
    );
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
    final String exportTag = _extractNestedTag(
      omegaFinalExportMap,
      'omega_final_export_v1',
      'export_tag',
    );

    String aggregationTag = 'neutral';
    if (fusionTag == 'aligned' || fusionTag == 'strong') {
      aggregationTag = fusionTag;
    } else if (coherenceTag.contains('coherent') ||
        coherenceTag.contains('aligned')) {
      aggregationTag = coherenceTag;
    } else if (decisionTag.contains('release') ||
        decisionTag.contains('green')) {
      aggregationTag = decisionTag;
    } else if (exportTag.contains('strong')) {
      aggregationTag = exportTag;
    }

    final Map<String, Object> payload = <String, Object>{
      'aggregation_value': aggregationValue,
      'aggregation_tag': _ascii(aggregationTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'lambda_final_aggregation_v1': Map<String, Object>.unmodifiable(payload),
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
