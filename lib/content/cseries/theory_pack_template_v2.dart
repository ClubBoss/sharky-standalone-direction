/// Static descriptor for the v2 theory pack template structure.
class TheoryPackTemplateV2 {
  const TheoryPackTemplateV2();

  Map<String, Object?> build() {
    final files = <String, Object>{
      'theory_md': 'theory.md',
      'drills_jsonl': 'drills.jsonl',
      'demos_jsonl': 'demos.jsonl',
      'recap_md': 'recap.md',
      'quiz_jsonl': 'quiz.jsonl',
      'allowlist_txt': 'allowlist.txt',
    };
    final tapExplain = List.unmodifiable(<String>[
      'range_adv',
      'spr',
      'cbet_freq',
      'probe_node',
      'turn_barrel',
      'bluffcatch_node',
    ]);
    return Map.unmodifiable(<String, Object?>{
      'version': 'v2',
      'files': Map.unmodifiable(files),
      'tap_to_explain_tokens': tapExplain,
      'note': 'Deterministic TheoryPackTemplateV2; no logic, no IO.',
    });
  }
}

TheoryPackTemplateV2 buildTheoryPackTemplateV2() =>
    const TheoryPackTemplateV2();
