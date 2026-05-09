/// Metadata manifest describing the full C-Series surface for automation.
Map<String, Object?> buildContentSurfaceManifestV1() {
  final surfaces = Map.unmodifiable(<String, Object?>{
    'entry_layer': 'buildContentEntryLayerV1()',
    'federation_bridge': 'buildCSeriesFederationBridgeV1()',
    'content_graph_root': 'buildContentGraphRootV1()',
    'content_graph_composite': 'buildContentGraphCompositeV1()',
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
  final manifest = Map.unmodifiable(<String, Object?>{
    'all_surfaces': List.unmodifiable(<String>[
      'entry_layer',
      'federation_bridge',
      'content_graph_root',
      'content_graph_composite',
    ]),
    'all_categories': List.unmodifiable(<String>[
      'theory',
      'checkpoints',
      'recaps',
      'quizzes',
      'srs',
      'adaptive',
      'cumulative_review',
    ]),
  });
  final notes = List.unmodifiable(<String>[
    'Metadata-only; no loaders.',
    'All values are static pointers (string names).',
    'This manifest is the machine-consumable SSOT for C-Series automation.',
  ]);

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description':
        'Automation-ready SSOT manifest for all C-Series metadata surfaces.',
    'surfaces': surfaces,
    'categories': categories,
    'manifest': manifest,
    'notes': notes,
  });
}
