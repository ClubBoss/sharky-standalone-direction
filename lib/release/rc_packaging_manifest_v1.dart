/// Returns the deterministic RC packaging manifest for release automation.
Map<String, Object?> buildRCPackagingManifestV1() {
  final contentPacks = Map.unmodifiable(<String, Object?>{
    'packs_root': 'pack_release/',
    'index_file': 'packs_index.json',
    'required_files': List.unmodifiable(<String>[
      'theory.md',
      'drills.jsonl',
      'demos.jsonl',
      'allowlist.txt',
    ]),
  });

  // TODO: populate real validators metadata once RC validator maps are finalized.
  final validators = Map.unmodifiable(<String, Object?>{});

  // TODO: add visual QA manifests from existing visual audits.
  final visualQa = Map.unmodifiable(<String, Object?>{});

  // TODO: aggregate persona diagnostics exports here.
  final persona = Map.unmodifiable(<String, Object?>{});

  final telemetry = Map.unmodifiable(<String, Object?>{
    'supported_events': List.unmodifiable(<String>['v4_theme_toggle']),
  });

  final ciCommands = List.unmodifiable(<String>[
    'dart run tool/validate_all.dart',
    'dart run tool/generate_and_export_packs.dart',
    'dart run tool/generate_packs_index.dart',
  ]);

  final paths = Map.unmodifiable(<String, Object?>{
    'packs_root': 'pack_release/',
    'reports_root': 'release/_reports/',
  });

  final manifest = <String, Object?>{
    'content_packs': contentPacks,
    'validators': validators,
    'visual_qa': visualQa,
    'persona': persona,
    'telemetry': telemetry,
    'ci_commands': ciCommands,
    'paths': paths,
  };

  return Map.unmodifiable(manifest);
}
