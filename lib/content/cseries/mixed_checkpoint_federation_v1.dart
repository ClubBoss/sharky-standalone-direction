/// Static metadata unifying mixed checkpoint families.
Map<String, Object?> buildMixedCheckpointFederationV1() {
  final spec = Map.unmodifiable(<String, Object?>{
    'required_files': List.unmodifiable(<String>['checkpoint.jsonl']),
    'id_format': 'checkpoint:<family>:<id>',
    'loader_hint':
        'Use MixedCheckpointLoaderV1; this federation is metadata-only.',
  });
  final families = Map.unmodifiable(<String, Object?>{
    'core': 'mixed_checkpoint:core',
    'demo': 'mixed_checkpoint:demo',
    'drill': 'mixed_checkpoint:drill',
    'leakfix': 'mixed_checkpoint:leakfix',
    'micro': 'mixed_checkpoint:micro',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified federation for all mixed checkpoints.',
    'spec': spec,
    'families': families,
  });
}
