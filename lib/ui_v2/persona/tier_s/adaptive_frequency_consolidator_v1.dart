class AdaptiveFrequencyConsolidatorV1 {
  const AdaptiveFrequencyConsolidatorV1({
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.adaptiveFrequencyEnvelopeMap = const <String, Object>{},
  });

  AdaptiveFrequencyConsolidatorV1.fromInputs({
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? adaptiveFrequencyEnvelopeMap,
  }) : this(
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         adaptiveFrequencyEnvelopeMap: _safe(adaptiveFrequencyEnvelopeMap),
       );

  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> adaptiveFrequencyEnvelopeMap;

  Map<String, Object> build() {
    final double frequencyValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double envelopeIntensity = _extractScore(
      adaptiveFrequencyEnvelopeMap['adaptive_frequency_envelope_v1']
          as Map<String, Object?>?,
      'envelope_intensity',
    );

    double frequencyCore = (frequencyValue * 0.6) + (envelopeIntensity * 0.4);
    frequencyCore = frequencyCore.clamp(0.0, 1.0);
    String frequencyTag = 'frequency_low';
    if (frequencyCore >= 0.80) {
      frequencyTag = 'frequency_peak';
    } else if (frequencyCore >= 0.45) {
      frequencyTag = 'frequency_mid';
    }

    return <String, Object>{
      'adaptive_frequency_consolidator_v1': <String, Object>{
        'frequency_core': frequencyCore,
        'frequency_tag': _ascii(frequencyTag),
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
