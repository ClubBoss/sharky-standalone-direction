/// Passive extraction skeleton for Cash L3 theory v2.
class CashL3TheoryExtractionSkeletonV1 {
  const CashL3TheoryExtractionSkeletonV1(this.oldTheoryText);

  final String oldTheoryText;

  Map<String, Object> analyze() {
    final bool hasIntro =
        oldTheoryText.contains('## Introduction') ||
        oldTheoryText.contains('## Intro');
    final bool hasPreflop = oldTheoryText.contains('## Preflop');
    final bool hasPostflop = oldTheoryText.contains('## Postflop');
    final bool hasExamples = oldTheoryText.contains('## Examples');
    final bool hasConclusion = oldTheoryText.contains('## Conclusion');
    final bool extractable =
        hasIntro && hasPreflop && hasPostflop && hasExamples && hasConclusion;
    return <String, Object>{
      'has_intro': hasIntro,
      'has_preflop': hasPreflop,
      'has_postflop': hasPostflop,
      'has_examples': hasExamples,
      'has_conclusion': hasConclusion,
      'segments': <String, String>{
        'introduction': _extractSection(<String>[
          '## Introduction',
          '## Intro',
        ]),
        'preflop': _extractSection(<String>['## Preflop']),
        'postflop': _extractSection(<String>['## Postflop']),
        'examples': _extractSection(<String>['## Examples']),
        'conclusion': _extractSection(<String>['## Conclusion']),
      },
      'extractable': extractable,
    };
  }

  String _extractSection(List<String> labels) {
    int start = -1;
    String? usedLabel;
    for (final String label in labels) {
      final int idx = oldTheoryText.indexOf(label);
      if (idx != -1 && (start == -1 || idx < start)) {
        start = idx;
        usedLabel = label;
      }
    }
    if (start == -1 || usedLabel == null) return '';
    final int contentStart = start + usedLabel.length;
    final int nextHeader = oldTheoryText.indexOf('## ', contentStart);
    final String slice = nextHeader == -1
        ? oldTheoryText.substring(contentStart)
        : oldTheoryText.substring(contentStart, nextHeader);
    return slice.trim();
  }
}
