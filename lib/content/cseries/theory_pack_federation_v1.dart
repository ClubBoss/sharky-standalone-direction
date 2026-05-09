/// Static metadata describing how theory pack families should be federated.
Map<String, Object?> buildTheoryPackFederationV1() {
  final spec = Map.unmodifiable(<String, Object?>{
    'required_files': List.unmodifiable(<String>[
      'theory.md',
      'drills.jsonl',
      'demos.jsonl',
      'allowlist.txt',
    ]),
    'optional_files': List.unmodifiable(<String>[
      'recap.md',
      'quiz.jsonl',
      'blitz.jsonl',
    ]),
    'id_format': 'family:level:version',
    'loader_hint':
        'Use pack loaders from content_root; federation is metadata-only.',
  });
  final families = Map.unmodifiable(<String, Object?>{
    'cash': 'cash:l3:v1',
    'icm_sb': 'icm:l4:sb:v1',
    'icm_bb': 'icm:l4:bb:v1',
    'icm_mix': 'icm:l4:mix:v1',
    'icm_bubble': 'icm:l4:bubble:v1',
    'import_last': 'import:last',
    'import_clipboard': 'import:clipboard',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'spec': spec,
    'families': families,
  });
}
