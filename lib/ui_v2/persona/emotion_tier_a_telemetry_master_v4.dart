class EmotionTierATelemetryMasterV4 {
  EmotionTierATelemetryMasterV4({
    required Map<String, Object?> finalLogic,
    required Map<String, Object?> masterEnvelope,
    required Map<String, Object?> telemetryMap,
    required Map<String, Object?> telemetryRelay,
  }) : _finalLogic = Map.of(finalLogic),
       _masterEnvelope = Map.of(masterEnvelope),
       _telemetryMap = Map.of(telemetryMap),
       _telemetryRelay = Map.of(telemetryRelay);

  final Map<String, Object?> _finalLogic;
  final Map<String, Object?> _masterEnvelope;
  final Map<String, Object?> _telemetryMap;
  final Map<String, Object?> _telemetryRelay;

  Map<String, Object?> asReadOnlyMap() => {
    'tierA_synthesized': {
      'mood': _finalLogic['finalMood'],
      'tone': _finalLogic['finalTone'],
      'arousal': _finalLogic['finalArousal'],
      'valence': _finalLogic['finalValence'],
    },
    'tierA_stability': {
      'mood': _finalLogic['finalMoodStability'],
      'tone': _finalLogic['finalToneStability'],
      'arousal': _finalLogic['finalArousalStability'],
      'valence': _finalLogic['finalValenceStability'],
    },
    'tierA_state': _finalLogic['finalTierAState'],
    'tierA_coherence': _finalLogic['coherenceScore'],
    'tierA_finalFlag': _finalLogic['tierAFinalFlag'],
    'tierA_envelope': Map.of(_masterEnvelope),
    'tierA_telemetry': Map.of(_telemetryMap),
    'tierA_telemetry_relay': Map.of(_telemetryRelay),
  };
}
