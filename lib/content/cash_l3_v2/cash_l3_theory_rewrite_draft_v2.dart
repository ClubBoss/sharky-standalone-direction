/// Passive draft generator for Cash L3 theory rewrite v2.
class CashL3TheoryRewriteDraftV2 {
  const CashL3TheoryRewriteDraftV2(this.normalizedSegments);

  final Map<String, String> normalizedSegments;

  Map<String, Object> rewrite() {
    final String intro = normalizedSegments['introduction'] ?? '';
    final String preflop = normalizedSegments['preflop'] ?? '';
    final String postflop = normalizedSegments['postflop'] ?? '';
    final String examples = normalizedSegments['examples'] ?? '';
    final String conclusion = normalizedSegments['conclusion'] ?? '';

    final bool draftReady =
        intro.isNotEmpty &&
        preflop.isNotEmpty &&
        postflop.isNotEmpty &&
        examples.isNotEmpty &&
        conclusion.isNotEmpty &&
        intro.startsWith('## Introduction') &&
        preflop.startsWith('## Preflop') &&
        postflop.startsWith('## Postflop') &&
        examples.startsWith('## Examples') &&
        conclusion.startsWith('## Conclusion');

    return <String, Object>{
      'draft_intro': intro,
      'draft_preflop': preflop,
      'draft_postflop': postflop,
      'draft_examples': examples,
      'draft_conclusion': conclusion,
      'draft_ready': draftReady,
    };
  }
}
