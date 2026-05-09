/// Passive structural rewrite skeleton for Cash L3 theory v2.
class CashL3TheoryRewriteSkeletonV2 {
  const CashL3TheoryRewriteSkeletonV2(this.segments);

  final Map<String, String> segments;

  Map<String, Object> transform() {
    final String intro = _normalize(
      '## Introduction',
      segments['introduction'],
    );
    final String preflop = _normalize('## Preflop', segments['preflop']);
    final String postflop = _normalize('## Postflop', segments['postflop']);
    final String examples = _normalize('## Examples', segments['examples']);
    final String conclusion = _normalize(
      '## Conclusion',
      segments['conclusion'],
    );

    final bool structureReady =
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
      'normalized_intro': intro,
      'normalized_preflop': preflop,
      'normalized_postflop': postflop,
      'normalized_examples': examples,
      'normalized_conclusion': conclusion,
      'structure_ready': structureReady,
    };
  }

  String _normalize(String header, String? content) {
    final String raw = (content ?? '').trim();
    if (raw.isEmpty) return '';
    final String withHeader = raw.startsWith(header) ? raw : '$header\n$raw';
    final List<String> lines = withHeader.split('\n');
    final List<String> collapsed = <String>[];
    for (final String line in lines) {
      if (line.trim().isEmpty) {
        if (collapsed.isNotEmpty && collapsed.last.isEmpty) continue;
        collapsed.add('');
      } else {
        collapsed.add(line);
      }
    }
    return collapsed.join('\n').trim();
  }
}
