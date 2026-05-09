class PersonaRhythmSignalV1 {
  const PersonaRhythmSignalV1({
    this.adaptiveCorrectionConsolidatorMap = const <String, Object>{},
    this.correctionBridgeMap = const <String, Object>{},
    this.contentPacingMap = const <String, Object>{},
  });

  PersonaRhythmSignalV1.fromInputs({
    Map<String, Object?>? adaptiveCorrectionConsolidatorMap,
    Map<String, Object?>? correctionBridgeMap,
    Map<String, Object?>? contentPacingMap,
  }) : this(
         adaptiveCorrectionConsolidatorMap: _safe(
           adaptiveCorrectionConsolidatorMap,
         ),
         correctionBridgeMap: _safe(correctionBridgeMap),
         contentPacingMap: _safe(contentPacingMap),
       );

  final Map<String, Object> adaptiveCorrectionConsolidatorMap;
  final Map<String, Object> correctionBridgeMap;
  final Map<String, Object> contentPacingMap;

  Map<String, Object> build() {
    final double q3Strength = _extractScore(
      adaptiveCorrectionConsolidatorMap['adaptive_correction_consolidator_v1']
          as Map<String, Object?>?,
      'consolidated_strength',
    );
    final double p3Strength = _extractScore(
      correctionBridgeMap['correction_bridge_v1'] as Map<String, Object?>?,
      'bridge_strength',
    );
    final double pacingValue = _extractScore(
      contentPacingMap['content_pacing_v1'] as Map<String, Object?>?,
      'pace_value',
    );

    double rhythmIntensity =
        (q3Strength * 0.5) + (p3Strength * 0.3) + (pacingValue * 0.2);
    rhythmIntensity = rhythmIntensity.clamp(0.0, 1.0);

    String rhythmMode = 'low_rhythm';
    if (rhythmIntensity >= 0.7) {
      rhythmMode = 'high_rhythm';
    } else if (rhythmIntensity >= 0.3) {
      rhythmMode = 'medium_rhythm';
    }

    return <String, Object>{
      'persona_rhythm_signal_v1': <String, Object>{
        'rhythm_mode': _ascii(rhythmMode),
        'rhythm_intensity': rhythmIntensity,
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
