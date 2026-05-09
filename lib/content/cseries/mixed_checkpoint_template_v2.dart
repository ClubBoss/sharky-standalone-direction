/// Static descriptor for mixed checkpoint template v2 structure.
class MixedCheckpointTemplateV2 {
  const MixedCheckpointTemplateV2();

  Map<String, Object?> build() {
    final files = <String, Object>{
      'checkpoint_md': 'checkpoint.md',
      'drills_jsonl': 'drills.jsonl',
      'examples_jsonl': 'examples.jsonl',
      'review_jsonl': 'review.jsonl',
    };
    final tapExplain = List.unmodifiable(<String>[
      'range_miss',
      'node_shift',
      'icm_pressure',
      'equity_drop',
      'turn_simplify',
    ]);
    return Map.unmodifiable(<String, Object?>{
      'version': 'v2',
      'files': Map.unmodifiable(files),
      'tap_to_explain_tokens': tapExplain,
      'note': 'Deterministic MixedCheckpointTemplateV2; no logic, no IO.',
    });
  }
}

MixedCheckpointTemplateV2 buildMixedCheckpointTemplateV2() =>
    const MixedCheckpointTemplateV2();
