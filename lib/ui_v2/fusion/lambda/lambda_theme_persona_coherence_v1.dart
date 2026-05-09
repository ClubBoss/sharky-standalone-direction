class LambdaThemePersonaCoherenceV1 {
  LambdaThemePersonaCoherenceV1._();

  static Map<String, Object> build({
    Map<String, Object?>? lambdaReleaseDecisionHookMap,
    Map<String, Object?>? omegaFinalExportMap,
    Map<String, Object?>? personaGlobalV1Map,
    Map<String, Object?>? themeRuntimeStateMap,
  }) {
    final double decisionValue = _extractNested(
      lambdaReleaseDecisionHookMap,
      'lambda_release_decision_hook_v1',
      'decision_value',
    );
    final double omegaValue = _extractNested(
      omegaFinalExportMap,
      'omega_final_export_v1',
      'export_value',
    );
    final double globalScore = _extractNested(
      personaGlobalV1Map,
      'persona_global_v1',
      'global_score',
    );

    final double themeFlag = _extractThemeFlag(themeRuntimeStateMap);

    double coherenceValue =
        (decisionValue * 0.45) +
        (omegaValue * 0.3) +
        (globalScore * 0.15) +
        (themeFlag * 0.1);
    coherenceValue = coherenceValue.clamp(0.0, 1.0);

    final String decisionTag = _extractNestedTag(
      lambdaReleaseDecisionHookMap,
      'lambda_release_decision_hook_v1',
      'decision_tag',
    );
    final String omegaTag = _extractNestedTag(
      omegaFinalExportMap,
      'omega_final_export_v1',
      'export_tag',
    );

    String coherenceTag = 'neutral';
    final String lowerDecision = decisionTag.toLowerCase();
    if (lowerDecision.startsWith('stable') ||
        lowerDecision.startsWith('strong')) {
      coherenceTag = 'aligned';
    } else if (omegaTag.contains('drift')) {
      coherenceTag = 'misaligned';
    }

    final Map<String, Object> payload = <String, Object>{
      'coherence_value': coherenceValue,
      'coherence_tag': _ascii(coherenceTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'lambda_theme_persona_coherence_v1': Map<String, Object>.unmodifiable(
        payload,
      ),
    });
  }

  static double _extractThemeFlag(Map<String, Object?>? map) {
    if (map == null) return 0.5;
    final Object? match = map['theme_match'];
    if (match is bool) return match ? 1.0 : 0.0;
    if (match is num) return match.toDouble().clamp(0.0, 1.0);
    if (match is String) {
      if (match.toLowerCase() == 'true') return 1.0;
      if (match.toLowerCase() == 'false') return 0.0;
      final double? parsed = double.tryParse(match);
      if (parsed != null) return parsed.clamp(0.0, 1.0);
    }
    return 0.5;
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
