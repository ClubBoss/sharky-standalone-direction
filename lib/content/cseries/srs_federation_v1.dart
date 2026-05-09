/// Metadata describing how spaced repetition assets are federated across C-series.
Map<String, Object?> buildSRSFederationV1() {
  final spec = Map.unmodifiable(<String, Object?>{
    'required_files': List.unmodifiable(<String>['srs.jsonl']),
    'optional_files': List.unmodifiable(<String>['srs_notes/', 'srs_curves/']),
    'id_format': 'srs:<family>:<id>',
    'loader_hint':
        'SRS federation is metadata-only; planners live outside federation.',
  });
  final families = Map.unmodifiable(<String, Object?>{
    'theory_review': 'srs:theory',
    'checkpoint_review': 'srs:checkpoint',
    'quiz_review': 'srs:quiz',
    'mixed_review': 'srs:mixed',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified federation for spaced repetition (SRS) metadata.',
    'spec': spec,
    'families': families,
  });
}
