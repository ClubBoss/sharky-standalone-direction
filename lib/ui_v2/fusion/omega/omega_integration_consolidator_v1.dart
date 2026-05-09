class OmegaIntegrationConsolidatorV1 {
  const OmegaIntegrationConsolidatorV1({
    this.omegaIntegrationEnvelopeMap = const <String, Object>{},
    this.tableIntegrationSeedMap = const <String, Object>{},
    this.personaGlobalV1Map = const <String, Object>{},
  });

  OmegaIntegrationConsolidatorV1.fromInputs({
    Map<String, Object?>? omegaIntegrationEnvelopeMap,
    Map<String, Object?>? tableIntegrationSeedMap,
    Map<String, Object?>? personaGlobalV1Map,
  }) : this(
         omegaIntegrationEnvelopeMap: _safe(omegaIntegrationEnvelopeMap),
         tableIntegrationSeedMap: _safe(tableIntegrationSeedMap),
         personaGlobalV1Map: _safe(personaGlobalV1Map),
       );

  final Map<String, Object> omegaIntegrationEnvelopeMap;
  final Map<String, Object> tableIntegrationSeedMap;
  final Map<String, Object> personaGlobalV1Map;

  Map<String, Object> build() {
    final double envelopeValue = _extractNested(
      omegaIntegrationEnvelopeMap,
      'omega_integration_envelope_v1',
      'value',
    );
    final double integrationStrength = _extractNested(
      tableIntegrationSeedMap,
      'table_integration_seed_v1',
      'integration_strength',
    );
    final double globalScore = _extractNested(
      personaGlobalV1Map,
      'persona_global_v1',
      'global_score',
    );

    double consolidatedValue =
        (envelopeValue + integrationStrength + globalScore) / 3.0;
    consolidatedValue = consolidatedValue.clamp(0.0, 1.0);

    String consolidatedTag = _extractNestedTag(
      omegaIntegrationEnvelopeMap,
      'omega_integration_envelope_v1',
      'tag',
    );
    if (consolidatedTag.isEmpty) {
      consolidatedTag = _extractNestedTag(
        personaGlobalV1Map,
        'persona_global_v1',
        'global_tag',
      );
    }
    if (consolidatedTag.isEmpty) {
      consolidatedTag = _extractNestedTag(
        tableIntegrationSeedMap,
        'table_integration_seed_v1',
        'integration_tag',
      );
    }
    if (consolidatedTag.isEmpty) consolidatedTag = 'consolidated';

    final Map<String, Object> payload = <String, Object>{
      'value': consolidatedValue,
      'tag': _ascii(consolidatedTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'omega_integration_consolidator_v1': Map<String, Object>.unmodifiable(
        payload,
      ),
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
