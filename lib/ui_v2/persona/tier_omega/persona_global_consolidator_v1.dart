class PersonaGlobalConsolidatorV1 {
  const PersonaGlobalConsolidatorV1({
    this.personaGlobalSeedMap = const <String, Object>{},
    this.personaGlobalEnvelopeMap = const <String, Object>{},
  });

  PersonaGlobalConsolidatorV1.fromInputs({
    Map<String, Object?>? personaGlobalSeedMap,
    Map<String, Object?>? personaGlobalEnvelopeMap,
  }) : this(
         personaGlobalSeedMap: _safe(personaGlobalSeedMap),
         personaGlobalEnvelopeMap: _safe(personaGlobalEnvelopeMap),
       );

  final Map<String, Object> personaGlobalSeedMap;
  final Map<String, Object> personaGlobalEnvelopeMap;

  Map<String, Object> build() {
    final double seedValue = _extract(personaGlobalSeedMap, 'global_value');
    final double envelopeValue = _extract(
      personaGlobalEnvelopeMap,
      'envelope_value',
    );
    final String envelopeTag = _extractTag(
      personaGlobalEnvelopeMap,
      'envelope_tag',
    );
    final String seedTag = _extractTag(personaGlobalSeedMap, 'global_tag');

    double consolidatedValue = (seedValue * 0.5) + (envelopeValue * 0.5);
    consolidatedValue = consolidatedValue.clamp(0.0, 1.0);

    final String tag = envelopeTag.isNotEmpty
        ? _ascii(envelopeTag)
        : _ascii(seedTag);

    return <String, Object>{
      'persona_global_consolidator_v1': <String, Object>{
        'consolidated_value': consolidatedValue,
        'consolidated_tag': tag,
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
