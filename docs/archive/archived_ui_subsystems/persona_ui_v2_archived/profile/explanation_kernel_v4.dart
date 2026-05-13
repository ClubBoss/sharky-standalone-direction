class ExplanationKernelV4 {
  const ExplanationKernelV4({required this.personaProfileMap});

  final Map<String, Object> personaProfileMap;

  Map<String, String> buildExplanation() => const <String, String>{
    'activation_state_explainer': 'V4 active or inactive.',
    'emotion_a_explainer': 'Tier-A emotional metadata.',
    'personalization_b_explainer': 'Tier-B personalization metadata.',
  };
}
