class SessionFlowBridgeV1 {
  const SessionFlowBridgeV1({
    this.sessionFlowSeedMap = const <String, Object>{},
    this.sessionFlowEnvelopeMap = const <String, Object>{},
    this.sessionFlowConsolidatorMap = const <String, Object>{},
  });

  SessionFlowBridgeV1.fromInputs({
    Map<String, Object?>? sessionFlowSeedMap,
    Map<String, Object?>? sessionFlowEnvelopeMap,
    Map<String, Object?>? sessionFlowConsolidatorMap,
  }) : this(
         sessionFlowSeedMap: _safe(sessionFlowSeedMap),
         sessionFlowEnvelopeMap: _safe(sessionFlowEnvelopeMap),
         sessionFlowConsolidatorMap: _safe(sessionFlowConsolidatorMap),
       );

  final Map<String, Object> sessionFlowSeedMap;
  final Map<String, Object> sessionFlowEnvelopeMap;
  final Map<String, Object> sessionFlowConsolidatorMap;

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
    final double consolidatedValue = _extractScore(
      sessionFlowConsolidatorMap['session_flow_consolidator_v1']
          as Map<String, Object?>?,
      'consolidated_value',
    );

    double bridgeValue =
        (seedValue * 0.25) +
        (envelopeValue * 0.35) +
        (consolidatedValue * 0.40);
    bridgeValue = bridgeValue.clamp(0.0, 1.0);

    String bridgeTag = 'u_bridge_low';
    if (bridgeValue >= 0.75) {
      bridgeTag = 'u_bridge_high';
    } else if (bridgeValue >= 0.40) {
      bridgeTag = 'u_bridge_mid';
    }

    return <String, Object>{
      'session_flow_bridge_v1': <String, Object>{
        'bridge_value': bridgeValue,
        'bridge_tag': _ascii(bridgeTag),
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
