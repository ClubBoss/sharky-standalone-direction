/// Passive migration skeleton for Cash L3 theory v2.
class CashL3TheoryMigrationSkeletonV1 {
  const CashL3TheoryMigrationSkeletonV1(this.oldTheoryText);

  final String oldTheoryText;

  Map<String, Object> analyze() {
    final List<String> words = oldTheoryText.split(' ');
    final int wordCount = words.length;
    final bool hasIntro =
        oldTheoryText.contains('## Introduction') ||
        oldTheoryText.contains('## Intro');
    final bool hasKeySections =
        oldTheoryText.contains('## Preflop') &&
        oldTheoryText.contains('## Postflop');
    final bool hasExamples = oldTheoryText.contains('## Examples');
    final bool hasConclusion = oldTheoryText.contains('## Conclusion');
    final bool templateReady =
        wordCount >= 250 &&
        hasIntro &&
        hasKeySections &&
        hasExamples &&
        hasConclusion;
    return <String, Object>{
      'old_word_count': wordCount,
      'has_intro': hasIntro,
      'has_key_sections': hasKeySections,
      'has_examples': hasExamples,
      'has_conclusion': hasConclusion,
      'migration_map': <String, String>{
        'introduction': '## Introduction',
        'core': '## Core Concepts',
        'examples': '## Examples',
        'conclusion': '## Conclusion',
      },
      'template_ready': templateReady,
    };
  }
}
