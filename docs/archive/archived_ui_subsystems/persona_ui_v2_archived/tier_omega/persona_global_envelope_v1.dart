class PersonaGlobalEnvelopeV1 {
  const PersonaGlobalEnvelopeV1({
    this.personaGlobalSeedMap = const <String, Object>{},
  });

  PersonaGlobalEnvelopeV1.fromInputs({
    Map<String, Object?>? personaGlobalSeedMap,
  }) : this(personaGlobalSeedMap: _safe(personaGlobalSeedMap));

  final Map<String, Object> personaGlobalSeedMap;

  Map<String, Object> build() {
    final double value = _extract(personaGlobalSeedMap, 'global_value') * 0.9;
    final String tag = _extractTag(personaGlobalSeedMap, 'global_tag');
    return <String, Object>{
      'persona_global_envelope_v1': <String, Object>{
        'envelope_value': value.clamp(0.0, 1.0),
        'envelope_tag': tag,
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
    final Map<String, Object> sanitized = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      sanitized[entry.key] = entry.value ?? '';
    }
    return sanitized;
  }
}
