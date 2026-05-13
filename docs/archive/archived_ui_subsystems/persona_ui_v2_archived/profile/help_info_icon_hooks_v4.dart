class HelpInfoIconHooksV4 {
  const HelpInfoIconHooksV4({required this.hooks});

  final List<Map<String, String>> hooks;

  static HelpInfoIconHooksV4 fromOverlayStructure(Map<String, Object> overlay) {
    final sections = overlay['sections'];
    if (sections is! List) {
      return const HelpInfoIconHooksV4(hooks: <Map<String, String>>[]);
    }
    final mappedHooks = <Map<String, String>>[];
    for (final section in sections) {
      final id = (section is Map ? section['id'] : null)?.toString();
      if (id == null || id.isEmpty) continue;
      mappedHooks.add(<String, String>{
        'id': id,
        'icon': 'info',
        'tooltip_key': 'persona_${id}_tooltip',
      });
    }
    return HelpInfoIconHooksV4(hooks: mappedHooks);
  }
}
