/// Passive theory pre-rewrite scanner v1.
class TheoryPreRewriteScannerV1 {
  const TheoryPreRewriteScannerV1(this.theoryText);

  final String theoryText;

  Map<String, Object> analyze() {
    final List<String> words = theoryText.split(' ');
    final int wordCount = words.length;
    final int headerCount = _countOccurrences('# ');
    final int sectionCount = _countOccurrences('## ');
    final bool hasIntro = theoryText.contains('## Introduction');
    final bool hasExamples = theoryText.contains('## Examples');
    final bool hasConclusion = theoryText.contains('## Conclusion');
    final bool templateReady =
        wordCount >= 250 &&
        headerCount >= 1 &&
        sectionCount >= 2 &&
        hasIntro &&
        hasExamples &&
        hasConclusion;
    return <String, Object>{
      'word_count': wordCount,
      'header_count': headerCount,
      'section_count': sectionCount,
      'has_intro': hasIntro,
      'has_examples': hasExamples,
      'has_conclusion': hasConclusion,
      'template_ready': templateReady,
    };
  }

  int _countOccurrences(String needle) {
    int count = 0;
    int index = theoryText.indexOf(needle);
    while (index != -1) {
      count++;
      index = theoryText.indexOf(needle, index + needle.length);
    }
    return count;
  }
}
