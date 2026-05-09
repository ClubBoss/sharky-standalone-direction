class ExplanationInlineBinderV4 {
  const ExplanationInlineBinderV4(this.inlineBundle);

  final Map<String, Object> inlineBundle;

  Map<String, String> bindForTooltip(String componentId) {
    final id = _normalizeId(componentId);
    final match = _tooltips().firstWhere(
      (entry) => entry['id'] == id,
      orElse: () => const <String, String>{},
    );
    if (match.isEmpty) _debugLogMissing(id, 'tooltip');
    return Map<String, String>.unmodifiable(match);
  }

  Map<String, Object> bindForOverlay(String componentId) {
    final id = _normalizeId(componentId);
    final sections = _overlaySections()
        .where((entry) => entry['id'] == id)
        .toList();
    if (sections.isEmpty) _debugLogMissing(id, 'overlay');
    return _surfacePayload(id, null, sections, const <Map<String, String>>[]);
  }

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'tooltip': List<Map<String, String>>.unmodifiable(
      _tooltips().map(Map<String, String>.unmodifiable),
    ),
    'overlay': List<Map<String, Object>>.unmodifiable(
      _overlaySections().map(Map<String, Object>.unmodifiable),
    ),
  });

  Map<String, Object> bindForSurface(String componentId) {
    final id = _normalizeId(componentId);
    final sections = _overlaySections()
        .where((entry) => entry['id'] == id)
        .toList();
    final title = sections.isNotEmpty
        ? sections.first['title'].toString()
        : null;
    final hooks = _hooks().where((entry) => entry['id'] == id).toList();
    if (sections.isEmpty && hooks.isEmpty) _debugLogMissing(id, 'surface');
    return _surfacePayload(id, title, sections, hooks);
  }

  List<Map<String, String>> _tooltips() {
    final data = inlineBundle['tooltips'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (e) => e.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
          .toList();
    }
    return const <Map<String, String>>[];
  }

  List<Map<String, Object>> _overlaySections() {
    final overlay = inlineBundle['overlay'];
    if (overlay is Map && overlay['sections'] is List) {
      final sections = <Map<String, Object>>[];
      for (final entry in overlay['sections'] as List) {
        if (entry is Map) {
          final mapped = <String, Object>{};
          entry.forEach((key, value) {
            mapped[key.toString()] = value ?? '';
          });
          sections.add(Map<String, Object>.unmodifiable(mapped));
        }
      }
      return sections;
    }
    return const <Map<String, Object>>[];
  }

  List<Map<String, String>> _hooks() {
    final data = inlineBundle['hooks'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (e) => e.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
          .toList();
    }
    return const <Map<String, String>>[];
  }

  String _normalizeId(String raw) {
    final trimmed = raw.trim();
    final lowered = trimmed.toLowerCase();
    return lowered;
  }

  Map<String, Object> _surfacePayload(
    String id,
    String? title,
    List<Map<String, Object>> sections,
    List<Map<String, String>> hooks,
  ) {
    return Map<String, Object>.unmodifiable({
      'title': title,
      'sections': List<Map<String, String>>.unmodifiable(
        sections.map(
          (e) => Map<String, String>.unmodifiable(
            e.map((key, value) => MapEntry(key.toString(), value.toString())),
          ),
        ),
      ),
      'hooks': List<Map<String, String>>.unmodifiable(
        hooks.map(Map<String, String>.unmodifiable),
      ),
      'surface': id,
    });
  }

  void _debugLogMissing(String id, String channel) {
    assert(() {
      // ignore: avoid_print
      print('ExplanationInlineBinderV4 missing data for $id on $channel');
      return true;
    }());
  }
}
