/// Metadata describing how micro-quiz assets are federated across C-series.
Map<String, Object?> buildMicroQuizFederationV1() {
  final spec = Map.unmodifiable(<String, Object?>{
    'required_files': List.unmodifiable(<String>['quiz.jsonl']),
    'optional_files': List.unmodifiable(<String>[
      'quiz_notes/',
      'quiz_images/',
    ]),
    'id_format': 'quiz:<family>:<id>',
    'loader_hint':
        'Micro-quiz federation is metadata-only; loaders remain in content_root.',
  });
  final families = Map.unmodifiable(<String, Object?>{
    'theory_quiz': 'quiz:theory',
    'recap_quiz': 'quiz:recap',
    'checkpoint_quiz': 'quiz:checkpoint',
    'mixed_quiz': 'quiz:mixed',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified federation for micro-quiz assets.',
    'spec': spec,
    'families': families,
  });
}
