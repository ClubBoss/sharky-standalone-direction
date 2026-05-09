class TableAdaptationEnvelopeV1 {
  const TableAdaptationEnvelopeV1({
    this.tableAdaptationSeedMap = const <String, Object>{},
    this.personaDecisionSurfaceMap = const <String, Object>{},
    this.personaDirectionalRouterMap = const <String, Object>{},
  });

  TableAdaptationEnvelopeV1.fromInputs({
    Map<String, Object?>? tableAdaptationSeedMap,
    Map<String, Object?>? personaDecisionSurfaceMap,
    Map<String, Object?>? personaDirectionalRouterMap,
  }) : this(
         tableAdaptationSeedMap: _safe(tableAdaptationSeedMap),
         personaDecisionSurfaceMap: _safe(personaDecisionSurfaceMap),
         personaDirectionalRouterMap: _safe(personaDirectionalRouterMap),
       );

  final Map<String, Object> tableAdaptationSeedMap;
  final Map<String, Object> personaDecisionSurfaceMap;
  final Map<String, Object> personaDirectionalRouterMap;

  Map<String, Object> build() {
    final double seedScore = _extractNested(
      tableAdaptationSeedMap,
      'table_adaptation_seed_v1',
      'adaptation_score',
    );
    final double decisionScore = _extractNested(
      personaDecisionSurfaceMap,
      'persona_decision_surface_v1',
      'decision_score',
    );
    final double routerConfidence = _extractNested(
      personaDirectionalRouterMap,
      'persona_directional_router_v1',
      'confidence',
    );

    double envelopeValue =
        (seedScore * 0.6) + (decisionScore * 0.25) + (routerConfidence * 0.15);
    envelopeValue = envelopeValue.clamp(0.0, 1.0);

    String envelopeTag = _extractNestedTag(
      tableAdaptationSeedMap,
      'table_adaptation_seed_v1',
      'adaptation_tag',
    );
    if (envelopeTag.isEmpty || envelopeTag == 'adaptive') {
      envelopeTag = _extractNestedTag(
        personaDecisionSurfaceMap,
        'persona_decision_surface_v1',
        'decision_tag',
      );
    }
    if (envelopeTag.isEmpty) {
      envelopeTag = _extractNestedTag(
        personaDirectionalRouterMap,
        'persona_directional_router_v1',
        'direction_tag',
      );
    }
    if (envelopeTag.isEmpty) envelopeTag = 'envelope';

    final Map<String, Object> payload = <String, Object>{
      'envelope_value': envelopeValue,
      'envelope_tag': _ascii(envelopeTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'table_adaptation_envelope_v1': Map<String, Object>.unmodifiable(payload),
    });
  }

  static double _extractNested(
    Map<String, Object> map,
    String sectionKey,
    String entryKey,
  ) {
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extract(section, entryKey);
    }
    return 0.0;
  }

  static String _extractNestedTag(
    Map<String, Object> map,
    String sectionKey,
    String entryKey,
  ) {
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

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      if (entry.value == null) continue;
      cleaned[entry.key] = entry.value!;
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
