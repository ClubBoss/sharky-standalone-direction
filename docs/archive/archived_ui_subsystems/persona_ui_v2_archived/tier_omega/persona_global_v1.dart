class PersonaGlobalV1 {
  const PersonaGlobalV1({
    this.personaGlobalSeedMap = const <String, Object>{},
    this.personaGlobalEnvelopeMap = const <String, Object>{},
    this.personaGlobalConsolidatorMap = const <String, Object>{},
    this.personaGlobalBridgeMap = const <String, Object>{},
  });

  PersonaGlobalV1.fromInputs({
    Map<String, Object?>? personaGlobalSeedMap,
    Map<String, Object?>? personaGlobalEnvelopeMap,
    Map<String, Object?>? personaGlobalConsolidatorMap,
    Map<String, Object?>? personaGlobalBridgeMap,
  }) : this(
         personaGlobalSeedMap: _safe(personaGlobalSeedMap),
         personaGlobalEnvelopeMap: _safe(personaGlobalEnvelopeMap),
         personaGlobalConsolidatorMap: _safe(personaGlobalConsolidatorMap),
         personaGlobalBridgeMap: _safe(personaGlobalBridgeMap),
       );

  final Map<String, Object> personaGlobalSeedMap;
  final Map<String, Object> personaGlobalEnvelopeMap;
  final Map<String, Object> personaGlobalConsolidatorMap;
  final Map<String, Object> personaGlobalBridgeMap;

  Map<String, Object> build() {
    final double seedValue = _extract(personaGlobalSeedMap, 'global_value');
    final double envelopeValue = _extract(
      personaGlobalEnvelopeMap,
      'envelope_value',
    );
    final double consolidatorValue = _extract(
      personaGlobalConsolidatorMap,
      'consolidated_value',
    );
    final double bridgeValue = _extract(personaGlobalBridgeMap, 'bridge_value');
    final String bridgeTag = _extractTag(personaGlobalBridgeMap, 'bridge_tag');
    final String consolidatorTag = _extractTag(
      personaGlobalConsolidatorMap,
      'consolidated_tag',
    );
    final String envelopeTag = _extractTag(
      personaGlobalEnvelopeMap,
      'envelope_tag',
    );
    final String seedTag = _extractTag(personaGlobalSeedMap, 'global_tag');

    double value =
        (seedValue + envelopeValue + consolidatorValue + bridgeValue) / 4.0;
    value = value.clamp(0.0, 1.0);

    final String tag = bridgeTag.isNotEmpty
        ? bridgeTag
        : consolidatorTag.isNotEmpty
        ? consolidatorTag
        : envelopeTag.isNotEmpty
        ? envelopeTag
        : seedTag;

    return <String, Object>{
      'persona_global_v1': <String, Object>{
        'global_score': value,
        'global_tag': _ascii(tag),
        'ready': true,
      },
    };
  }

  static double _extract(Map<String, Object> map, String key) {
    final Object? raw = map[key];
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
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
      cleaned[entry.key] = entry.value ?? '';
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
