/// Passive composer for Cash L3 theory V2 final assembly.
class CashL3TheoryV2Composer {
  const CashL3TheoryV2Composer(this.normSegments);

  final Map<String, String> normSegments;

  Map<String, Object> compose() {
    final List<String> sections = <String>[
      normSegments['norm_intro'] ?? '',
      normSegments['norm_preflop'] ?? '',
      normSegments['norm_postflop'] ?? '',
      normSegments['norm_examples'] ?? '',
      normSegments['norm_conclusion'] ?? '',
    ];

    final String theory = sections
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trimRight())
        .join('\n\n');

    final bool finalReady =
        theory.isNotEmpty &&
        theory.contains('## Introduction') &&
        theory.contains('## Preflop') &&
        theory.contains('## Postflop') &&
        theory.contains('## Examples') &&
        theory.contains('## Conclusion');

    return <String, Object>{
      'theory_v2': theory.trimRight(),
      'final_ready': finalReady,
    };
  }
}
