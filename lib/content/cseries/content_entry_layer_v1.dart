/// Deterministic entry surface for future C-Series content surfaces.
Map<String, Object?> buildContentEntryLayerV1() {
  final routes = Map.unmodifiable(<String, Object?>{
    'theory_packs': 'content/theory/',
    'mixed_checkpoints': 'content/checkpoints/',
    'recaps': 'content/recaps/',
    'micro_quizzes': 'content/quizzes/',
    'srs': 'content/srs/',
    'persona_adaptive': 'content/adaptive/',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified entry surface for all C-Series content packs.',
    'routes': routes,
  });
}
