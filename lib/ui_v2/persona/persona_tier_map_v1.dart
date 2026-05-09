class PersonaTierMapV1 {
  const PersonaTierMapV1({
    required this.personaId,
    required this.tierProfile,
    required this.weightMap,
    required this.blendHint,
  });

  final Object personaId;
  final Object tierProfile;
  final Object weightMap;
  final Object blendHint;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'persona_id': personaId.toString(),
    'tier_profile': tierProfile.toString(),
    'weight_map': weightMap.toString(),
    'blend_hint': blendHint.toString(),
  });
}
