class EmotionTierATelemetryV4 {
  EmotionTierATelemetryV4({required Map<String, Object?> finalBundle})
    : _finalBundle = Map.of(finalBundle);

  final Map<String, Object?> _finalBundle;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_a_state_v4': _finalBundle['tier_a_final_state'],
    'tier_a_readiness': _finalBundle['readiness'],
    'tier_a_supervisor': _finalBundle['supervisor'],
    'tier_a_outcome': _finalBundle['outcome'],
  };
}
