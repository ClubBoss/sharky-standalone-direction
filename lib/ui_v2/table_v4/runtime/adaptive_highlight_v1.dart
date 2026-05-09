class AdaptiveHighlightV1 {
  AdaptiveHighlightV1._();

  static Map<String, Object> fromInputs({
    Map<String, Object>? shift,
    Map<String, Object>? table,
    Map<String, Object>? context,
  }) {
    final Map<String, Object> safeShift = _sanitize(shift);
    final Map<String, Object> safeTable = _sanitize(table);
    final Map<String, Object> safeContext = _sanitize(context);

    final String shiftTag = _extractString(safeShift, 'shift_tag');
    final String tableTag = _extractString(safeTable, 'surface_tag');
    final String contextTag = _extractString(safeContext, 'aggregation_tag');
    String highlightTag = 'neutral';
    if (shiftTag.isNotEmpty) {
      highlightTag = shiftTag;
    } else if (tableTag.isNotEmpty) {
      highlightTag = tableTag;
    } else if (contextTag.isNotEmpty) {
      highlightTag = contextTag;
    }

    final double shiftStrength = _extractDoubleSafe(
      safeShift,
      'shift_strength',
    );
    final double surfaceStrength = _extractDoubleSafe(
      safeTable,
      'surface_strength',
    );
    final bool contextReady = _extractBool(safeContext, 'ready');

    double highlightStrength =
        (0.5 * shiftStrength) +
        (0.3 * surfaceStrength) +
        (0.2 * (contextReady ? 1.0 : 0.0));
    highlightStrength = highlightStrength.clamp(0.0, 1.0);

    return Map<String, Object>.unmodifiable(<String, Object>{
      'adaptive_highlight_v1':
          Map<String, Object>.unmodifiable(<String, Object>{
            'highlight_tag': _ascii(highlightTag),
            'highlight_strength': highlightStrength,
            'ready': safeShift.isNotEmpty || safeTable.isNotEmpty,
          }),
    });
  }

  static Map<String, Object> _sanitize(Map<String, Object>? map) {
    if (map == null) return const <String, Object>{};
    final Map<String, Object> clean = <String, Object>{};
    for (final MapEntry<String, Object> entry in map.entries) {
      clean[_ascii(entry.key)] = entry.value;
    }
    return clean;
  }

  static double _extractDoubleSafe(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is num) return value.toDouble().clamp(0.0, 1.0);
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed.clamp(0.0, 1.0);
    }
    return 0.0;
  }

  static bool _extractBool(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  static String _extractString(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
