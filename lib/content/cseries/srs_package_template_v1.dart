/// Static descriptor for the SRS package template structure.
class SRSPackageTemplateV1 {
  const SRSPackageTemplateV1();

  Map<String, Object?> build() {
    final files = <String, Object>{
      'srs_sequence_jsonl': 'srs_sequence.jsonl',
      'difficulty_map_json': 'difficulty_map.json',
    };
    final tapExplain = List.unmodifiable(<String>[
      'interval_logic',
      'error_decay',
      'reinforce_node',
      'difficulty_shift',
    ]);
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'files': Map.unmodifiable(files),
      'tap_to_explain_tokens': tapExplain,
      'note': 'Deterministic SRSPackageTemplateV1; no logic, no IO.',
    });
  }
}

SRSPackageTemplateV1 buildSRSPackageTemplateV1() =>
    const SRSPackageTemplateV1();
