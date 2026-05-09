class PersonaMetaCompletionV1 {
  const PersonaMetaCompletionV1({
    this.personaMetaPersonaMap = const <String, Object>{},
    this.personaMetaEnvelopeMap = const <String, Object>{},
    this.personaMetaRoutingMap = const <String, Object>{},
  });

  PersonaMetaCompletionV1.fromInputs({
    Map<String, Object?>? personaMetaPersonaMap,
    Map<String, Object?>? personaMetaEnvelopeMap,
    Map<String, Object?>? personaMetaRoutingMap,
  }) : this(
         personaMetaPersonaMap: _safe(personaMetaPersonaMap),
         personaMetaEnvelopeMap: _safe(personaMetaEnvelopeMap),
         personaMetaRoutingMap: _safe(personaMetaRoutingMap),
       );

  final Map<String, Object> personaMetaPersonaMap;
  final Map<String, Object> personaMetaEnvelopeMap;
  final Map<String, Object> personaMetaRoutingMap;

  Map<String, Object> build() {
    final double score = _extractScore(
      personaMetaPersonaMap['persona_meta_persona_v1'] as Map<String, Object?>?,
      'score',
    );
    final String? personaTag =
        (personaMetaPersonaMap['persona_meta_persona_v1']
                as Map<String, Object?>?)?['persona_tag']
            as String?;
    final String? envelopeMode =
        (personaMetaEnvelopeMap['persona_meta_envelope_v1']
                as Map<String, Object?>?)?['mode']
            as String?;
    final String? routing =
        (personaMetaRoutingMap['persona_meta_routing_v1']
                as Map<String, Object?>?)?['route']
            as String?;
    String completionTag = 'completion_neutral';
    if (personaTag?.startsWith('persona_advance') == true) {
      completionTag = 'completion_advance';
    } else if (envelopeMode == 'adaptive_stabilize') {
      completionTag = 'completion_stabilize';
    } else if (routing == 'mtt') {
      completionTag = 'completion_mtt';
    } else if (routing == 'c_series') {
      completionTag = 'completion_cash';
    }
    return <String, Object>{
      'persona_meta_completion_v1': <String, Object>{
        'completion_tag': _ascii(completionTag),
        'score': score,
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?>? body, String key) {
    if (body == null) return 0.0;
    final Object? raw = body[key];
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0.0;
  }

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
