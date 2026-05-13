class TimingBridgeV1 {
  const TimingBridgeV1({
    this.timingSeedMap = const <String, Object>{},
    this.timingEnvelopeMap = const <String, Object>{},
    this.timingConsolidatorMap = const <String, Object>{},
  });

  TimingBridgeV1.fromInputs({
    Map<String, Object?>? timingSeedMap,
    Map<String, Object?>? timingEnvelopeMap,
    Map<String, Object?>? timingConsolidatorMap,
  }) : this(
         timingSeedMap: _safe(timingSeedMap),
         timingEnvelopeMap: _safe(timingEnvelopeMap),
         timingConsolidatorMap: _safe(timingConsolidatorMap),
       );

  final Map<String, Object> timingSeedMap;
  final Map<String, Object> timingEnvelopeMap;
  final Map<String, Object> timingConsolidatorMap;

  Map<String, Object> build() {
    final double seedValue = _extractScore(
      timingSeedMap['timing_seed_v1'] as Map<String, Object?>?,
      'seed_value',
    );
    final double envelopeValue = _extractScore(
      timingEnvelopeMap['timing_envelope_v1'] as Map<String, Object?>?,
      'envelope_value',
    );
    final double consolidatedValue = _extractScore(
      timingConsolidatorMap['timing_consolidator_v1'] as Map<String, Object?>?,
      'consolidated_value',
    );

    double bridgeValue =
        (seedValue * 0.3) + (envelopeValue * 0.3) + (consolidatedValue * 0.4);
    bridgeValue = bridgeValue.clamp(0.0, 1.0);

    String bridgeTag = 'timing_soft';
    if (bridgeValue >= 0.80) {
      bridgeTag = 'timing_sharp';
    } else if (bridgeValue >= 0.45) {
      bridgeTag = 'timing_balanced';
    }

    return <String, Object>{
      'timing_bridge_v1': <String, Object>{
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
