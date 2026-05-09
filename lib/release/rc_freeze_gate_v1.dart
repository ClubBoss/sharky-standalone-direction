/// Immutable gate metadata describing the RC freeze boundary.
Map<String, Object?> buildRCFreezeGateV1() {
  final frozenKeys = List.unmodifiable(<String>[
    'content_packs',
    'validators',
    'visual_qa',
    'persona',
    'telemetry',
    'ci_commands',
    'paths',
  ]);

  return Map.unmodifiable(<String, Object?>{
    'rc_frozen': true,
    'version': 'v1',
    'frozen_keys': frozenKeys,
    'notes': 'RC boundary locked; no structural changes allowed.',
  });
}
