class SessionFlowConsolidatorV1 {
  const SessionFlowConsolidatorV1({
    this.sessionFlowSeedMap = const <String, Object>{},
    this.sessionFlowEnvelopeMap = const <String, Object>{},
  });

  SessionFlowConsolidatorV1.fromInputs({
    Map<String, Object?>? sessionFlowSeedMap,
    Map<String, Object?>? sessionFlowEnvelopeMap,
  }) : this(
         sessionFlowSeedMap: _safe(sessionFlowSeedMap),
         sessionFlowEnvelopeMap: _safe(sessionFlowEnvelopeMap),
       );

  final Map<String, Object> sessionFlowSeedMap;
  final Map<String, Object> sessionFlowEnvelopeMap;

  Map<String, Object> build() {
    final double seedValue = _extractScore(
      sessionFlowSeedMap['session_flow_seed_v1'] as Map<String, Object?>?,
      'seed_value',
    );
    final double envelopeValue = _extractScore(
      sessionFlowEnvelopeMap['session_flow_envelope_v1']
          as Map<String, Object?>?,
      'envelope_value',
    );

    double consolidatedValue = (seedValue * 0.4) + (envelopeValue * 0.6);
    consolidatedValue = consolidatedValue.clamp(0.0, 1.0);

    String consolidatedTag = 'u_low';
    if (consolidatedValue >= 0.75) {
      consolidatedTag = 'u_high';
    } else if (consolidatedValue >= 0.40) {
      consolidatedTag = 'u_mid';
    }

    return <String, Object>{
      'session_flow_consolidator_v1': <String, Object>{
        'consolidated_value': consolidatedValue,
        'consolidated_tag': _ascii(consolidatedTag),
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
    final Map<String, Object> sanitized = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      sanitized[entry.key] = entry.value ?? '';
    }
    return sanitized;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
