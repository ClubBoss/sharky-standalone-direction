class PersonaProfileContextProviderV4 {
  const PersonaProfileContextProviderV4({
    required this.isV4Active,
    required this.v4ActivationBundle,
    required this.emotionA,
    required this.personalizationB,
  });

  final bool isV4Active;
  final Map<String, Object> v4ActivationBundle;
  final Map<String, Object> emotionA;
  final Map<String, Object> personalizationB;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'is_v4_active': isV4Active,
    'v4_activation_bundle': Map<String, Object>.unmodifiable(
      v4ActivationBundle,
    ),
    'emotion_a': Map<String, Object>.unmodifiable(emotionA),
    'personalization_b': Map<String, Object>.unmodifiable(personalizationB),
  });
}
