/// Passive normalization pass for Cash L3 theory draft v1.
class CashL3TheoryDraftNormalizeV1 {
  const CashL3TheoryDraftNormalizeV1(this.draftSegments);

  final Map<String, String> draftSegments;

  Map<String, Object> normalize() {
    final String intro = _normalizeSection(
      '## Introduction',
      draftSegments['draft_intro'],
    );
    final String preflop = _normalizeSection(
      '## Preflop',
      draftSegments['draft_preflop'],
    );
    final String postflop = _normalizeSection(
      '## Postflop',
      draftSegments['draft_postflop'],
    );
    final String examples = _normalizeSection(
      '## Examples',
      draftSegments['draft_examples'],
    );
    final String conclusion = _normalizeSection(
      '## Conclusion',
      draftSegments['draft_conclusion'],
    );

    final bool normReady =
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
      'norm_intro': intro,
      'norm_preflop': preflop,
      'norm_postflop': postflop,
      'norm_examples': examples,
      'norm_conclusion': conclusion,
      'norm_ready': normReady,
    };
  }

  String _normalizeSection(String header, String? content) {
    final String raw = (content ?? '').trimRight();
    if (raw.isEmpty) return '';
    String withHeader = raw.startsWith(header) ? raw : '$header\n$raw';
    withHeader = _unifyBullets(withHeader);
    withHeader = _collapseBlankLines(withHeader);
    withHeader = _dedupeLines(withHeader);
    withHeader = _normalizeTerms(withHeader);
    return withHeader.trim();
  }

  String _unifyBullets(String text) {
    return text.replaceAll(RegExp(r'^\s*\* ', multiLine: true), '- ');
  }

  String _collapseBlankLines(String text) {
    return text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  String _dedupeLines(String text) {
    final List<String> lines = text.split('\n');
    final List<String> result = <String>[];
    for (final String line in lines) {
      if (result.isNotEmpty && result.last.trim() == line.trim()) continue;
      result.add(line);
    }
    return result.join('\n');
  }

  String _normalizeTerms(String text) {
    String normalized = text;
    normalized = normalized.replaceAll(
      RegExp(r'\bc[\- ]?bet\b', caseSensitive: false),
      'c-bet',
    );
    normalized = normalized.replaceAll(
      RegExp(r'\bspr\b', caseSensitive: false),
      'SPR',
    );
    normalized = normalized.replaceAll(RegExp(r'\bRange\b'), 'range');
    normalized = normalized.replaceAll(RegExp(r'\bBoard\b'), 'board');
    normalized = normalized.replaceAll(RegExp(r'\bEquity\b'), 'equity');
    normalized = normalized.replaceAll(RegExp(r'\n +'), '\n');
    normalized = normalized.replaceAll(RegExp(r'[ \t]+$', multiLine: true), '');
    return normalized;
  }
}
