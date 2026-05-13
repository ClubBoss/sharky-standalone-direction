class ExplanationOverlayRendererV4 {
  const ExplanationOverlayRendererV4({required this.explanationMap});

  final Map<String, String> explanationMap;

  Map<String, Object> buildOverlayStructure() => <String, Object>{
    'sections': <Map<String, String>>[
      <String, String>{
        'id': 'activation',
        'title': 'V4 Activation',
        'body': explanationMap['activation_state_explainer'] ?? '',
      },
      <String, String>{
        'id': 'emotion_a',
        'title': 'Emotion Tier-A',
        'body': explanationMap['emotion_a_explainer'] ?? '',
      },
      <String, String>{
        'id': 'personalization_b',
        'title': 'Personalization Tier-B',
        'body': explanationMap['personalization_b_explainer'] ?? '',
      },
    ],
  };
}
