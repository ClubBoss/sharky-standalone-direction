class PersonaTooltipDataBuilderV4 {
  const PersonaTooltipDataBuilderV4({
    required this.hooks,
    required this.overlay,
  });

  final List<Map<String, String>> hooks;
  final Map<String, Object> overlay;

  List<Map<String, String>> buildTooltipData() {
    final sections = overlay['sections'];
    if (sections is! List) return <Map<String, String>>[];
    final results = <Map<String, String>>[];
    for (final hook in hooks) {
      final id = hook['id'];
      if (id == null || id.isEmpty) continue;
      final section = sections.cast<Map>().firstWhere(
        (s) => s['id']?.toString() == id,
        orElse: () => const <String, Object?>{},
      );
      final title = section['title']?.toString() ?? '';
      final body = section['body']?.toString() ?? '';
      results.add(<String, String>{
        'id': id,
        'title': title,
        'body': body,
        'tooltip_key': hook['tooltip_key'] ?? '',
      });
    }
    return results;
  }
}
