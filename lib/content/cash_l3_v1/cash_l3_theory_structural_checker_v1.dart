/// Passive structural checker for Cash L3 theory.md.
class CashL3TheoryStructuralCheckerV1 {
  const CashL3TheoryStructuralCheckerV1(this.theoryText);

  final String theoryText;

  Map<String, Object> analyze() {
    final bool hasHeader = theoryText.contains('# ');
    final bool hasSections = theoryText.contains('## ');
    final int approxWordCount = theoryText.split(' ').length;
    final bool hasContrastLine = theoryText.contains('Contrast:');
    return <String, Object>{
      'has_header': hasHeader,
      'has_sections': hasSections,
      'approx_word_count': approxWordCount,
      'has_contrast_line': hasContrastLine,
    };
  }
}
