/// Metadata describing the top-level C-Series content graph root.
Map<String, Object?> buildContentGraphRootV1() {
  final nodes = Map.unmodifiable(<String, Object?>{
    'federation_bridge': 'buildCSeriesFederationBridgeV1()',
    'theory': 'theory_families',
    'checkpoints': 'mixed_checkpoint_families',
    'recaps': 'recap_families',
    'quizzes': 'micro_quiz_families',
    'srs': 'srs_families',
    'adaptive': 'persona_adaptive_families',
    'cumulative_review': 'cumulative_review_families',
  });
  final links = Map.unmodifiable(<String, Object?>{
    'recap_to_theory': 'recap references theory topics',
    'quiz_to_recap': 'quiz reinforces recap concepts',
    'srs_to_all': 'SRS spans theory/checkpoint/quiz/recap',
    'adaptive_to_any': 'adaptive persona routing can target any family',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Top-level C-Series content graph root.',
    'nodes': nodes,
    'links': links,
  });
}
