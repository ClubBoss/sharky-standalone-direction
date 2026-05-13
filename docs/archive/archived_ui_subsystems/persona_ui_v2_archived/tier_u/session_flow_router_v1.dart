class SessionFlowRouterV1 {
  const SessionFlowRouterV1({
    this.sessionFlowBridgeMap = const <String, Object>{},
  });

  SessionFlowRouterV1.fromInputs({Map<String, Object?>? sessionFlowBridgeMap})
    : this(sessionFlowBridgeMap: _safe(sessionFlowBridgeMap));

  final Map<String, Object> sessionFlowBridgeMap;

  Map<String, Object> build() {
    final double bridgeValue = _extractScore(
      sessionFlowBridgeMap['session_flow_bridge_v1'] as Map<String, Object?>?,
      'bridge_value',
    );
    final double clamped = bridgeValue.clamp(0.0, 1.0);
    String routeTag = 'u_route_low';
    if (clamped >= 0.75) {
      routeTag = 'u_route_high';
    } else if (clamped >= 0.40) {
      routeTag = 'u_route_mid';
    }

    return <String, Object>{
      'session_flow_router_v1': <String, Object>{
        'route_tag': _ascii(routeTag),
        'route_strength': clamped,
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
