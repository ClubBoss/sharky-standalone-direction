/// Passive semantic safety checker for Cash L3 theory v2.
class CashL3TheorySemanticSafetyV1 {
  const CashL3TheorySemanticSafetyV1(this.normalizedSegments);

  final Map<String, String> normalizedSegments;

  Map<String, Object> analyze() {
    final String intro = normalizedSegments['introduction'] ?? '';
    final String preflop = normalizedSegments['preflop'] ?? '';
    final String postflop = normalizedSegments['postflop'] ?? '';
    final String examples = normalizedSegments['examples'] ?? '';
    final String conclusion = normalizedSegments['conclusion'] ?? '';

    final bool hasIntro = intro.startsWith('## Introduction');
    final bool hasPreflop = preflop.startsWith('## Preflop');
    final bool hasPostflop = postflop.startsWith('## Postflop');
    final bool hasExamples = examples.startsWith('## Examples');
    final bool hasConclusion = conclusion.startsWith('## Conclusion');

    final List<String> forbidden = <String>[
      'TODO',
      'FIXME',
      '<<',
      '>>',
      '@@',
      '%%',
      'REPLACE_ME',
    ];
    final List<String> hits = <String>[];
    for (final String token in forbidden) {
      if (_containsToken(intro, token) ||
          _containsToken(preflop, token) ||
          _containsToken(postflop, token) ||
          _containsToken(examples, token) ||
          _containsToken(conclusion, token)) {
        hits.add(token);
      }
    }
    final bool noForbiddenTokens = hits.isEmpty;

    final bool semanticReady =
        hasIntro &&
        hasPreflop &&
        hasPostflop &&
        hasExamples &&
        hasConclusion &&
        noForbiddenTokens;

    return <String, Object>{
      'has_intro': hasIntro,
      'has_preflop': hasPreflop,
      'has_postflop': hasPostflop,
      'has_examples': hasExamples,
      'has_conclusion': hasConclusion,
      'no_forbidden_tokens': noForbiddenTokens,
      'semantic_ready': semanticReady,
      'forbidden_hits': hits,
    };
  }

  bool _containsToken(String text, String token) {
    return text.contains(token);
  }
}
