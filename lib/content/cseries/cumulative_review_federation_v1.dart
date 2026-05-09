/// Static metadata describing cumulative review federation rules.
Map<String, Object?> buildCumulativeReviewFederationV1() {
  final spec = Map.unmodifiable(<String, Object?>{
    'required_files': List.unmodifiable(<String>['review.jsonl']),
    'optional_files': List.unmodifiable(<String>[
      'review_notes/',
      'review_images/',
    ]),
    'id_format': 'review:<family>:<id>',
    'loader_hint':
        'Cumulative review federation is metadata-only; review logic implemented elsewhere.',
  });
  final families = Map.unmodifiable(<String, Object?>{
    'theory_review': 'review:theory',
    'checkpoint_review': 'review:checkpoint',
    'quiz_review': 'review:quiz',
    'mixed_review': 'review:mixed',
    'srs_review': 'review:srs',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified federation for cumulative review assets.',
    'spec': spec,
    'families': families,
  });
}
