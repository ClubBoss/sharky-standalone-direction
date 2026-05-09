/// Metadata defining persona-adaptive federation routing rules.
Map<String, Object?> buildPersonaAdaptiveFederationV1() {
  final spec = Map.unmodifiable(<String, Object?>{
    'id_format': 'adaptive:<persona>:<family>:<id>',
    'required_inputs': List.unmodifiable(<String>[
      'theory_families',
      'checkpoint_families',
      'quiz_families',
      'recap_families',
      'srs_families',
    ]),
    'loader_hint':
        'Adaptive federation is metadata-only; routing logic is implemented elsewhere.',
  });
  final personaTiers = List.unmodifiable(<String>[
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'Omega',
  ]);
  final families = Map.unmodifiable(<String, Object?>{
    'theory': 'adaptive:theory',
    'checkpoint': 'adaptive:checkpoint',
    'quiz': 'adaptive:quiz',
    'recap': 'adaptive:recap',
    'srs': 'adaptive:srs',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified federation for persona-adaptive content routing.',
    'spec': spec,
    'persona_tiers': personaTiers,
    'families': families,
  });
}
