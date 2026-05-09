/// Metadata descriptor for the Cash L3 Blind Defense extended module.
class CashL3BlindDefenseModuleDescriptorV1 {
  const CashL3BlindDefenseModuleDescriptorV1();

  Map<String, Object?> build() {
    final meta = <String, Object>{
      'id': 'cash:l3:blind_defense:v1',
      'title': 'Cash L3 — Blind Defense (Extended)',
      'templates': <String, Object>{
        'theory_pack': 'TheoryPackTemplateV2',
        'mixed_checkpoint': 'MixedCheckpointTemplateV2',
        'srs_package': 'SRSPackageTemplateV1',
        'persona_adaptive': 'PersonaAdaptiveTemplateV1',
      },
      'expected_assets': <String>[
        'theory.md',
        'drills.jsonl',
        'demos.jsonl',
        'recap.md',
        'quiz.jsonl',
        'allowlist.txt',
        'srs_sequence.jsonl',
        'difficulty_map.json',
        'persona_map.json',
        'weighting_map.json',
        'adaptive_hints.json',
      ],
      'note':
          'Descriptor only — no content. Real content will be added in C-3.2+.',
    };
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'module': Map.unmodifiable(meta),
    });
  }
}

CashL3BlindDefenseModuleDescriptorV1
buildCashL3BlindDefenseModuleDescriptorV1() =>
    const CashL3BlindDefenseModuleDescriptorV1();
