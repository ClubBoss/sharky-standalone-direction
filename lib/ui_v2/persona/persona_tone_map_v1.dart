class PersonaToneMapV1 {
  const PersonaToneMapV1({
    required this.personaId,
    required this.toneProfile,
    required this.moodWeight,
    required this.tierHint,
  });

  final Object personaId;
  final Object toneProfile;
  final Object moodWeight;
  final Object tierHint;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'persona_id': personaId.toString(),
    'tone_profile': toneProfile.toString(),
    'mood_weight': moodWeight.toString(),
    'tier_hint': tierHint.toString(),
  });
}
