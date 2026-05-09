/// Metadata describing how recap assets are federated across C-series.
Map<String, Object?> buildRecapFederationV1() {
  final spec = Map.unmodifiable(<String, Object?>{
    'required_files': List.unmodifiable(<String>['recap.md']),
    'optional_files': List.unmodifiable(<String>[
      'recap_images/',
      'recap_notes/',
    ]),
    'id_format': 'recap:<family>:<id>',
    'loader_hint':
        'Recap federation is metadata-only; loaders remain in content_root.',
  });
  final families = Map.unmodifiable(<String, Object?>{
    'theory': 'recap:theory',
    'checkpoint': 'recap:checkpoint',
    'review': 'recap:review',
    'module_summary': 'recap:module_summary',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified federation for recap.md assets.',
    'spec': spec,
    'families': families,
  });
}
