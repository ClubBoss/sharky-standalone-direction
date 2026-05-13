class CorrectionBridgeV1 {
  const CorrectionBridgeV1({
    this.correctionEngineMap = const <String, Object>{},
    this.reinforcementSyncSurfaceMap = const <String, Object>{},
    this.reinforcementFeedbackEngineMap = const <String, Object>{},
  });

  CorrectionBridgeV1.fromInputs({
    Map<String, Object?>? correctionEngineMap,
    Map<String, Object?>? reinforcementSyncSurfaceMap,
    Map<String, Object?>? reinforcementFeedbackEngineMap,
  }) : this(
         correctionEngineMap: _safe(correctionEngineMap),
         reinforcementSyncSurfaceMap: _safe(reinforcementSyncSurfaceMap),
         reinforcementFeedbackEngineMap: _safe(reinforcementFeedbackEngineMap),
       );

  final Map<String, Object> correctionEngineMap;
  final Map<String, Object> reinforcementSyncSurfaceMap;
  final Map<String, Object> reinforcementFeedbackEngineMap;

  Map<String, Object> build() {
    final Map<String, Object?> correctionBody =
        correctionEngineMap['correction_engine_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> syncBody =
        reinforcementSyncSurfaceMap['reinforcement_sync_surface_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> feedbackBody =
        reinforcementFeedbackEngineMap['reinforcement_feedback_engine_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};

    final String correctionTag =
        (correctionBody['correction_tag'] as String?)?.trim() ?? '';
    final double correctionValue = _extractScore(
      correctionBody,
      'correction_value',
    );
    final double syncStrength = _extractScore(syncBody, 'sync_strength');
    final double feedbackStrength = _extractScore(
      feedbackBody,
      'feedback_strength',
    );

    String bridgeTag = 'neutral_path';
    if (correctionTag == 'intensify') {
      bridgeTag = 'push_forward';
    } else if (correctionTag == 'stabilize') {
      bridgeTag = 'hold_center';
    } else if (correctionTag == 'ease_off') {
      bridgeTag = 'soft_reduce';
    }

    double bridgeStrength =
        (correctionValue * 0.5) +
        (syncStrength * 0.3) +
        (feedbackStrength * 0.2);
    bridgeStrength = bridgeStrength.clamp(0.0, 1.0);

    return <String, Object>{
      'correction_bridge_v1': <String, Object>{
        'bridge_tag': _ascii(bridgeTag),
        'bridge_strength': bridgeStrength,
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
