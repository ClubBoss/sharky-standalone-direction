class SessionFlowSurfaceV1 {
  const SessionFlowSurfaceV1({
    this.sessionFlowSeedMap = const <String, Object>{},
    this.sessionFlowEnvelopeMap = const <String, Object>{},
    this.sessionFlowConsolidatorMap = const <String, Object>{},
    this.sessionFlowBridgeMap = const <String, Object>{},
    this.sessionFlowRouterMap = const <String, Object>{},
  });

  SessionFlowSurfaceV1.fromInputs({
    Map<String, Object?>? sessionFlowSeedMap,
    Map<String, Object?>? sessionFlowEnvelopeMap,
    Map<String, Object?>? sessionFlowConsolidatorMap,
    Map<String, Object?>? sessionFlowBridgeMap,
    Map<String, Object?>? sessionFlowRouterMap,
  }) : this(
         sessionFlowSeedMap: _safe(sessionFlowSeedMap),
         sessionFlowEnvelopeMap: _safe(sessionFlowEnvelopeMap),
         sessionFlowConsolidatorMap: _safe(sessionFlowConsolidatorMap),
         sessionFlowBridgeMap: _safe(sessionFlowBridgeMap),
         sessionFlowRouterMap: _safe(sessionFlowRouterMap),
       );

  final Map<String, Object> sessionFlowSeedMap;
  final Map<String, Object> sessionFlowEnvelopeMap;
  final Map<String, Object> sessionFlowConsolidatorMap;
  final Map<String, Object> sessionFlowBridgeMap;
  final Map<String, Object> sessionFlowRouterMap;

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
    final double consolidatorValue = _extractScore(
      sessionFlowConsolidatorMap['session_flow_consolidator_v1']
          as Map<String, Object?>?,
      'consolidated_value',
    );
    final double bridgeValue = _extractScore(
      sessionFlowBridgeMap['session_flow_bridge_v1'] as Map<String, Object?>?,
      'bridge_value',
    );
    final double routerStrength = _extractScore(
      sessionFlowRouterMap['session_flow_router_v1'] as Map<String, Object?>?,
      'route_strength',
    );

    double flowValue =
        (seedValue +
            envelopeValue +
            consolidatorValue +
            bridgeValue +
            routerStrength) /
        5.0;
    flowValue = flowValue.clamp(0.0, 1.0);

    String flowTag = 'low';
    if (flowValue >= 0.75) {
      flowTag = 'high';
    } else if (flowValue >= 0.40) {
      flowTag = 'mid';
    }

    return <String, Object>{
      'session_flow_surface_v1': <String, Object>{
        'flow_value': flowValue,
        'flow_tag': _ascii(flowTag),
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
