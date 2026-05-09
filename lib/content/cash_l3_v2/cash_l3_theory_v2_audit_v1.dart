/// Passive audit for Cash L3 theory v2.
class CashL3TheoryV2AuditV1 {
  const CashL3TheoryV2AuditV1(this.theoryV2);

  final String theoryV2;

  Map<String, Object> audit() {
    final bool hasIntro = theoryV2.contains('## Introduction');
    final bool hasPreflop = theoryV2.contains('## Preflop');
    final bool hasPostflop = theoryV2.contains('## Postflop');
    final bool hasExamples = theoryV2.contains('## Examples');
    final bool hasConclusion = theoryV2.contains('## Conclusion');
    final List<int> order = <int>[
      theoryV2.indexOf('## Introduction'),
      theoryV2.indexOf('## Preflop'),
      theoryV2.indexOf('## Postflop'),
      theoryV2.indexOf('## Examples'),
      theoryV2.indexOf('## Conclusion'),
    ];
    final bool headersInOrder =
        order.every((i) => i >= 0) && _isStrictlyIncreasing(order);
    final bool noDoubleBlanklines = !theoryV2.contains('\n\n\n');
    final bool noTrailingSpace = !RegExp(
      r'[ \t]+$',
      multiLine: true,
    ).hasMatch(theoryV2);
    final List<String> issues = <String>[];
    if (!hasIntro) issues.add('missing_intro');
    if (!hasPreflop) issues.add('missing_preflop');
    if (!hasPostflop) issues.add('missing_postflop');
    if (!hasExamples) issues.add('missing_examples');
    if (!hasConclusion) issues.add('missing_conclusion');
    if (!headersInOrder) issues.add('header_order');
    if (!noDoubleBlanklines) issues.add('double_blanklines');
    if (!noTrailingSpace) issues.add('trailing_space');
    final bool auditReady =
        hasIntro &&
        hasPreflop &&
        hasPostflop &&
        hasExamples &&
        hasConclusion &&
        headersInOrder &&
        noDoubleBlanklines &&
        noTrailingSpace;
    return <String, Object>{
      'has_intro': hasIntro,
      'has_preflop': hasPreflop,
      'has_postflop': hasPostflop,
      'has_examples': hasExamples,
      'has_conclusion': hasConclusion,
      'no_double_blanklines': noDoubleBlanklines,
      'headers_in_order': headersInOrder,
      'no_trailing_space': noTrailingSpace,
      'audit_ready': auditReady,
      'issues': issues,
    };
  }

  bool _isStrictlyIncreasing(List<int> values) {
    for (int i = 1; i < values.length; i++) {
      if (values[i - 1] >= values[i]) return false;
    }
    return true;
  }
}
