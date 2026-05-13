class SessionFlowEnvelopeV1 {
  const SessionFlowEnvelopeV1({
    this.sessionFlowSeedMap = const <String, Object>{},
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.rhythmConsolidatorMap = const <String, Object>{},
  });

  SessionFlowEnvelopeV1.fromInputs({
    Map<String, Object?>? sessionFlowSeedMap,
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? rhythmConsolidatorMap,
  }) : this(
         sessionFlowSeedMap: _safe(sessionFlowSeedMap),
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         rhythmConsolidatorMap: _safe(rhythmConsolidatorMap),
       );

  final Map<String, Object> sessionFlowSeedMap;
  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> rhythmConsolidatorMap;

  Map<String, Object> build() {
    final double seedValue = _extractScore(
      sessionFlowSeedMap['session_flow_seed_v1'] as Map<String, Object?>?,
      'seed_value',
    );
    final double frequencyValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double rhythmValue = _extractScore(
      rhythmConsolidatorMap['rhythm_consolidator_v1'] as Map<String, Object?>?,
      'consolidated_value',
    );

    double envelopeValue =
        (seedValue * 0.5) + (frequencyValue * 0.3) + (rhythmValue * 0.2);
    envelopeValue = envelopeValue.clamp(0.0, 1.0);

    String envelopeTag = 'u_slow';
    if (envelopeValue >= 0.75) {
      envelopeTag = 'u_fast';
    } else if (envelopeValue >= 0.40) {
      envelopeTag = 'u_balanced';
    }

    return <String, Object>{
      'session_flow_envelope_v1': <String, Object>{
        'envelope_value': envelopeValue,
        'envelope_tag': _ascii(envelopeTag),
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
      if (parsed != null) return parsed;
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
