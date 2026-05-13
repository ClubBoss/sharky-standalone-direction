class RhythmConsolidatorV1 {
  const RhythmConsolidatorV1({
    this.personaRhythmSignalMap = const <String, Object>{},
    this.adaptiveRhythmModulatorMap = const <String, Object>{},
    this.rhythmEnvelopeMap = const <String, Object>{},
  });

  RhythmConsolidatorV1.fromInputs({
    Map<String, Object?>? personaRhythmSignalMap,
    Map<String, Object?>? adaptiveRhythmModulatorMap,
    Map<String, Object?>? rhythmEnvelopeMap,
  }) : this(
         personaRhythmSignalMap: _safe(personaRhythmSignalMap),
         adaptiveRhythmModulatorMap: _safe(adaptiveRhythmModulatorMap),
         rhythmEnvelopeMap: _safe(rhythmEnvelopeMap),
       );

  final Map<String, Object> personaRhythmSignalMap;
  final Map<String, Object> adaptiveRhythmModulatorMap;
  final Map<String, Object> rhythmEnvelopeMap;

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
    final double envelopeValue = _extractScore(
      rhythmEnvelopeMap['rhythm_envelope_v1'] as Map<String, Object?>?,
      'envelope_value',
    );

    double consolidatedValue =
        (rawIntensity * 0.33) +
        (modulatedRhythm * 0.33) +
        (envelopeValue * 0.34);
    consolidatedValue = consolidatedValue.clamp(0.0, 1.0);

    String consolidatedTag = 'rhythm_consolidated_low';
    if (consolidatedValue >= 0.75) {
      consolidatedTag = 'rhythm_consolidated_peak';
    } else if (consolidatedValue >= 0.45) {
      consolidatedTag = 'rhythm_consolidated_balanced';
    }

    return <String, Object>{
      'rhythm_consolidator_v1': <String, Object>{
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
