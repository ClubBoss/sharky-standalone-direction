/// SSOT composite pointing to entry/federation/graph surfaces for C-Series.
Map<String, Object?> buildContentGraphCompositeV1() {
  final surfaces = Map.unmodifiable(<String, Object?>{
    'entry_layer': 'buildContentEntryLayerV1()',
    'federation_bridge': 'buildCSeriesFederationBridgeV1()',
    'content_graph_root': 'buildContentGraphRootV1()',
  });
  final categories = Map.unmodifiable(<String, Object?>{
    'theory': 'theory_families',
    'checkpoints': 'mixed_checkpoint_families',
    'recaps': 'recap_families',
    'quizzes': 'micro_quiz_families',
    'srs': 'srs_families',
    'adaptive': 'persona_adaptive_families',
    'cumulative_review': 'cumulative_review_families',
  });
  final notes = List.unmodifiable(<String>[
    'Metadata-only; no loader logic.',
    'All pointers refer to static federation builders.',
    'This is the canonical SSOT surface for C-Series automation.',
  ]);

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified SSOT composite for all C-Series metadata.',
    'surfaces': surfaces,
    'categories': categories,
    'notes': notes,
  });
}
