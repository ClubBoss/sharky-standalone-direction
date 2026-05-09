class RhythmEnvelopeV1 {
  const RhythmEnvelopeV1({
    this.personaRhythmSignalMap = const <String, Object>{},
    this.adaptiveRhythmModulatorMap = const <String, Object>{},
  });

  RhythmEnvelopeV1.fromInputs({
    Map<String, Object?>? personaRhythmSignalMap,
    Map<String, Object?>? adaptiveRhythmModulatorMap,
  }) : this(
         personaRhythmSignalMap: _safe(personaRhythmSignalMap),
         adaptiveRhythmModulatorMap: _safe(adaptiveRhythmModulatorMap),
       );

  final Map<String, Object> personaRhythmSignalMap;
  final Map<String, Object> adaptiveRhythmModulatorMap;

  Map<String, Object> build() {
    final double rawIntensity = _extractScore(
      personaRhythmSignalMap['persona_rhythm_signal_v1']
          as Map<String, Object?>?,
      'rhythm_intensity',
    );
    final double modulatedRhythm = _extractScore(
      adaptiveRhythmModulatorMap['adaptive_rhythm_modulator_v1']
          as Map<String, Object?>?,
      'modulated_rhythm',
    );
    double envelopeValue = (rawIntensity * 0.5) + (modulatedRhythm * 0.5);
    envelopeValue = envelopeValue.clamp(0.0, 1.0);
    String envelopeTag = 'rhythm_low';
    if (envelopeValue >= 0.75) {
      envelopeTag = 'rhythm_peak';
    } else if (envelopeValue >= 0.45) {
      envelopeTag = 'rhythm_balanced';
    }
    return <String, Object>{
      'rhythm_envelope_v1': <String, Object>{
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
