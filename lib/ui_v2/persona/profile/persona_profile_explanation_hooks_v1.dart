class PersonaProfileExplanationHooksV1 {
  const PersonaProfileExplanationHooksV1({
    required this.staticTraits,
    required this.aiInsights,
  });

  final Map<String, Object> staticTraits;
  final Map<String, Object> aiInsights;

  String buildShortExplanation() {
    final traitPreview = _preview(staticTraits, 2);
    final insightPreview = _preview(aiInsights, 1);
    final traitSentence = traitPreview.isNotEmpty
        ? 'Core traits: ${traitPreview.join(", ")}.'
        : 'Traits are pending.';
    final insightSentence = insightPreview.isNotEmpty
        ? 'AI notes: ${insightPreview.join(", ")}.'
        : 'AI insights are pending.';
    final combined = '$traitSentence $insightSentence';
    return combined.length <= 200 ? combined : combined.substring(0, 200);
  }

  String buildLongExplanation() {
    final traitPreview = _preview(staticTraits, 3);
    final insightPreview = _preview(aiInsights, 3);
    final buffer = StringBuffer();
    if (traitPreview.isNotEmpty) {
      buffer.writeln(
        'The persona highlights ${traitPreview.join(", ")} as its defining markers.',
      );
    } else {
      buffer.writeln('Static traits are still loading.');
    }
    if (insightPreview.isNotEmpty) {
      buffer.writeln(
        'Tier-B insight stream notes ${insightPreview.join(", ")} in support of those traits.',
      );
    } else {
      buffer.writeln('AI insights are still pending.');
    }
    buffer.writeln(
      'Together these entries form the starting profile that later layers will decorate.',
    );
    final narrative = buffer.toString().trimRight();
    return narrative.length <= 500 ? narrative : narrative.substring(0, 500);
  }

  List<String> _preview(Map<String, Object> source, int limit) {
    if (source.isEmpty) return [];
    final keys = source.keys.toList()..sort();
    final preview = <String>[];
    for (final key in keys.take(limit)) {
      preview.add('$key:${source[key]}');
    }
    return preview;
  }
}
