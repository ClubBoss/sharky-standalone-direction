/// Generates deterministic RC release notes metadata for downstream tooling.
Map<String, Object?> buildReleaseNotesV1() {
  final subsystems = List.unmodifiable(<String>[
    'Omega-integration',
    'Lambda-release-link',
    'Phi-table-v4',
    'Sigma2-micro-ux',
    'Pi-release-assembly',
  ]);
  final buildInstructions = List.unmodifiable(<String>[
    'dart run tool/validate_all.dart',
    'dart run tool/generate_and_export_packs.dart',
    'dart run tool/generate_packs_index.dart',
  ]);

  final overview = Map.unmodifiable(<String, Object?>{
    'subsystems': subsystems,
    'description':
        'Deterministic RC metadata for packaging, freeze, and store prep.',
  });
  final manifest = Map.unmodifiable(<String, Object?>{
    'entrypoint': 'buildRCPackagingManifest()',
  });
  final freezeGate = Map.unmodifiable(<String, Object?>{
    'entrypoint': 'buildRCFreezeGate()',
    'required': true,
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'rc1',
    'overview': overview,
    'manifest': manifest,
    'freeze_gate': freezeGate,
    'build_instructions': buildInstructions,
  });
}
