class AdaptiveFrequencyBridgeV1 {
  const AdaptiveFrequencyBridgeV1({
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.adaptiveFrequencyEnvelopeMap = const <String, Object>{},
    this.adaptiveFrequencyConsolidatorMap = const <String, Object>{},
  });

  AdaptiveFrequencyBridgeV1.fromInputs({
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? adaptiveFrequencyEnvelopeMap,
    Map<String, Object?>? adaptiveFrequencyConsolidatorMap,
  }) : this(
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         adaptiveFrequencyEnvelopeMap: _safe(adaptiveFrequencyEnvelopeMap),
         adaptiveFrequencyConsolidatorMap: _safe(
           adaptiveFrequencyConsolidatorMap,
         ),
       );

  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> adaptiveFrequencyEnvelopeMap;
  final Map<String, Object> adaptiveFrequencyConsolidatorMap;

  Map<String, Object> build() {
    final double rawValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double envelopeIntensity = _extractScore(
      adaptiveFrequencyEnvelopeMap['adaptive_frequency_envelope_v1']
          as Map<String, Object?>?,
      'envelope_intensity',
    );
    final double coreValue = _extractScore(
      adaptiveFrequencyConsolidatorMap['adaptive_frequency_consolidator_v1']
          as Map<String, Object?>?,
      'frequency_core',
    );

    double bridgeValue =
        (coreValue * 0.7) + (envelopeIntensity * 0.2) + (rawValue * 0.1);
    bridgeValue = bridgeValue.clamp(0.0, 1.0);

    String bridgeTag = 'frequency_bridge_low';
    if (bridgeValue >= 0.80) {
      bridgeTag = 'frequency_bridge_peak';
    } else if (bridgeValue >= 0.45) {
      bridgeTag = 'frequency_bridge_mid';
    }

    return <String, Object>{
      'adaptive_frequency_bridge_v1': <String, Object>{
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
