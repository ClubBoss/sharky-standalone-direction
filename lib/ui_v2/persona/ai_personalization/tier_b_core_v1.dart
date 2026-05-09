class TierBPersonalizationCoreV1 {
  const TierBPersonalizationCoreV1({
    required this.delta,
    required this.aggregator,
    required this.gate,
    required this.relay,
  });

  final Map<String, Object> delta;
  final Map<String, Object> aggregator;
  final Map<String, Object> gate;
  final Map<String, Object> relay;

  factory TierBPersonalizationCoreV1.fromTierA({
    required Map<String, Object> tierAValues,
    Map<String, Object> staticWeights = const <String, Object>{
      'calm_weight': 1.0,
      'focus_weight': 1.0,
      'tension_weight': 1.0,
    },
  }) {
    return TierBPersonalizationCoreV1(
      delta: Map<String, Object>.unmodifiable({
        'calm': tierAValues['calm'] ?? 0.0,
        'focus': tierAValues['focus'] ?? 0.0,
        'tension': tierAValues['tension'] ?? 0.0,
      }),
      aggregator: Map<String, Object>.unmodifiable({
        'weights': staticWeights,
        'snapshot': tierAValues,
      }),
      gate: const <String, Object>{
        'enabled': true,
        'reason': 'tier_b_placeholder',
      },
      relay: Map<String, Object>.unmodifiable({
        'tier': 'B',
        'source': 'tier_a_emotion_engine_v1',
        'payload': tierAValues,
      }),
    );
  }

  Map<String, Object> toReadOnlyMap() => Map<String, Object>.unmodifiable({
    'delta': delta,
    'aggregator': aggregator,
    'gate': gate,
    'relay': relay,
  });
}
