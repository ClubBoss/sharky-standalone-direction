class MicroUXEngineV1 {
  MicroUXEngineV1._();

  static Map<String, Object> fromInputs({
    Map<String, Object>? shift,
    Map<String, Object>? highlight,
    Map<String, Object>? context,
    Map<String, Object>? table,
  }) {
    final Map<String, Object> safeShift = _sanitize(shift);
    final Map<String, Object> safeHighlight = _sanitize(highlight);
    final Map<String, Object> safeContext = _sanitize(context);
    final Map<String, Object> safeTable = _sanitize(table);

    final String shiftTag = _extractString(safeShift, 'shift_tag');
    final String highlightTag = _extractString(safeHighlight, 'highlight_tag');
    final String tableTag = _extractString(safeTable, 'surface_tag');
    final String contextTag = _extractString(safeContext, 'aggregation_tag');

    String engineTag = 'neutral';
    if (highlightTag.isNotEmpty) {
      engineTag = highlightTag;
    } else if (shiftTag.isNotEmpty) {
      engineTag = shiftTag;
    } else if (tableTag.isNotEmpty) {
      engineTag = tableTag;
    } else if (contextTag.isNotEmpty) {
      engineTag = contextTag;
    }

    final double highlightStrength = _extractDouble(
      safeHighlight,
      'highlight_strength',
    );
    final double shiftStrength = _extractDouble(safeShift, 'shift_strength');
    final double surfaceStrength = _extractDouble(
      safeTable,
      'surface_strength',
    );
    final bool contextReady = _extractBool(safeContext, 'ready');

    double engineStrength =
        (0.4 * highlightStrength) +
        (0.3 * shiftStrength) +
        (0.2 * surfaceStrength) +
        (0.1 * (contextReady ? 1.0 : 0.0));
    engineStrength = engineStrength.clamp(0.0, 1.0);

    return Map<String, Object>.unmodifiable(<String, Object>{
      'micro_ux_engine_v1': Map<String, Object>.unmodifiable(<String, Object>{
        'engine_tag': _ascii(engineTag),
        'engine_strength': engineStrength,
        'ready': true,
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

  static double _extractDouble(Map<String, Object> map, String key) {
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
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static String _extractString(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
