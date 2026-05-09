class AdaptiveCorrectionEngineV1 {
  const AdaptiveCorrectionEngineV1({
    this.correctionBridgeMap = const <String, Object>{},
    this.reinforcementSyncSurfaceMap = const <String, Object>{},
    this.reinforcementFeedbackEngineMap = const <String, Object>{},
  });

  AdaptiveCorrectionEngineV1.fromInputs({
    Map<String, Object?>? correctionBridgeMap,
    Map<String, Object?>? reinforcementSyncSurfaceMap,
    Map<String, Object?>? reinforcementFeedbackEngineMap,
  }) : this(
         correctionBridgeMap: _safe(correctionBridgeMap),
         reinforcementSyncSurfaceMap: _safe(reinforcementSyncSurfaceMap),
         reinforcementFeedbackEngineMap: _safe(reinforcementFeedbackEngineMap),
       );

  final Map<String, Object> correctionBridgeMap;
  final Map<String, Object> reinforcementSyncSurfaceMap;
  final Map<String, Object> reinforcementFeedbackEngineMap;

  Map<String, Object> build() {
    final Map<String, Object?> bridgeBody =
        correctionBridgeMap['correction_bridge_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> syncBody =
        reinforcementSyncSurfaceMap['reinforcement_sync_surface_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> feedbackBody =
        reinforcementFeedbackEngineMap['reinforcement_feedback_engine_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};

    final String bridgeTag =
        (bridgeBody['bridge_tag'] as String?)?.trim() ?? '';
    final double bridgeStrength = _extractScore(bridgeBody, 'bridge_strength');
    final double syncStrength = _extractScore(syncBody, 'sync_strength');
    final double feedbackStrength = _extractScore(
      feedbackBody,
      'feedback_strength',
    );

    String adaptiveTag = 'adaptive_neutral';
    if (bridgeTag == 'push_forward') {
      adaptiveTag = 'adaptive_push';
    } else if (bridgeTag == 'hold_center') {
      adaptiveTag = 'adaptive_hold';
    } else if (bridgeTag == 'soft_reduce') {
      adaptiveTag = 'adaptive_reduce';
    }

    double adaptiveStrength =
        (bridgeStrength * 0.5) +
        (syncStrength * 0.3) +
        (feedbackStrength * 0.2);
    adaptiveStrength = adaptiveStrength.clamp(0.0, 1.0);

    return <String, Object>{
      'adaptive_correction_engine_v1': <String, Object>{
        'adaptive_tag': _ascii(adaptiveTag),
        'adaptive_strength': adaptiveStrength,
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?> body, String key) {
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
