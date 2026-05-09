class TimingSeedV1 {
  const TimingSeedV1({
    this.adaptiveFrequencyBridgeMap = const <String, Object>{},
    this.personaInfluenceSurfaceMap = const <String, Object>{},
    this.personaAdaptiveSchedulerMap = const <String, Object>{},
  });

  TimingSeedV1.fromInputs({
    Map<String, Object?>? adaptiveFrequencyBridgeMap,
    Map<String, Object?>? personaInfluenceSurfaceMap,
    Map<String, Object?>? personaAdaptiveSchedulerMap,
  }) : this(
         adaptiveFrequencyBridgeMap: _safe(adaptiveFrequencyBridgeMap),
         personaInfluenceSurfaceMap: _safe(personaInfluenceSurfaceMap),
         personaAdaptiveSchedulerMap: _safe(personaAdaptiveSchedulerMap),
       );

  final Map<String, Object> adaptiveFrequencyBridgeMap;
  final Map<String, Object> personaInfluenceSurfaceMap;
  final Map<String, Object> personaAdaptiveSchedulerMap;

  Map<String, Object> build() {
    final double bridgeValue = _extractScore(
      adaptiveFrequencyBridgeMap['adaptive_frequency_bridge_v1']
          as Map<String, Object?>?,
      'bridge_value',
    );
    final double influenceStrength = _extractScore(
      personaInfluenceSurfaceMap['persona_influence_surface_v1']
          as Map<String, Object?>?,
      'influence_strength',
    );
    final double schedulerIntensity = _extractScore(
      personaAdaptiveSchedulerMap['persona_adaptive_scheduler_v1']
          as Map<String, Object?>?,
      'schedule_intensity',
    );

    double seedValue =
        (bridgeValue * 0.5) +
        (influenceStrength * 0.3) +
        (schedulerIntensity * 0.2);
    seedValue = seedValue.clamp(0.0, 1.0);

    String seedTag = 'timing_low';
    if (seedValue >= 0.80) {
      seedTag = 'timing_peak';
    } else if (seedValue >= 0.45) {
      seedTag = 'timing_mid';
    }

    return <String, Object>{
      'timing_seed_v1': <String, Object>{
        'seed_value': seedValue,
        'seed_tag': _ascii(seedTag),
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
