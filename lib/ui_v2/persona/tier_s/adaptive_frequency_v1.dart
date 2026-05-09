class AdaptiveFrequencyV1 {
  const AdaptiveFrequencyV1({
    this.rhythmConsolidatorMap = const <String, Object>{},
    this.personaInfluenceSurfaceMap = const <String, Object>{},
    this.personaAdaptiveSchedulerMap = const <String, Object>{},
  });

  AdaptiveFrequencyV1.fromInputs({
    Map<String, Object?>? rhythmConsolidatorMap,
    Map<String, Object?>? personaInfluenceSurfaceMap,
    Map<String, Object?>? personaAdaptiveSchedulerMap,
  }) : this(
         rhythmConsolidatorMap: _safe(rhythmConsolidatorMap),
         personaInfluenceSurfaceMap: _safe(personaInfluenceSurfaceMap),
         personaAdaptiveSchedulerMap: _safe(personaAdaptiveSchedulerMap),
       );

  final Map<String, Object> rhythmConsolidatorMap;
  final Map<String, Object> personaInfluenceSurfaceMap;
  final Map<String, Object> personaAdaptiveSchedulerMap;

  Map<String, Object> build() {
    final double consolidatedValue = _extractScore(
      rhythmConsolidatorMap['rhythm_consolidator_v1'] as Map<String, Object?>?,
      'consolidated_value',
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

    double frequencyValue =
        (consolidatedValue * 0.45) +
        (influenceStrength * 0.35) +
        (schedulerIntensity * 0.20);
    frequencyValue = frequencyValue.clamp(0.0, 1.0);

    String frequencyTag = 'frequency_low';
    if (frequencyValue >= 0.75) {
      frequencyTag = 'frequency_peak';
    } else if (frequencyValue >= 0.45) {
      frequencyTag = 'frequency_balanced';
    }

    return <String, Object>{
      'adaptive_frequency_v1': <String, Object>{
        'frequency_value': frequencyValue,
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
