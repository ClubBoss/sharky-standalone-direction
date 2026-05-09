class MicroUXShiftV1 {
  MicroUXShiftV1._();

  static Map<String, Object> fromInputs({
    Map<String, Object>? persona,
    Map<String, Object>? table,
    Map<String, Object>? adaptiveContext,
  }) {
    final Map<String, Object> safePersona = _sanitize(persona);
    final Map<String, Object> safeTable = _sanitize(table);
    final Map<String, Object> safeContext = _sanitize(adaptiveContext);

    final String tag = _detectShiftTag(safeContext, safePersona, safeTable);
    final double personaScore = _extractDouble(safePersona, 'global_score');
    final double surfaceStrength = _extractDouble(
      safeTable,
      'surface_strength',
    );
    final bool contextReady = _extractBool(safeContext, 'ready');

    double strength =
        (0.4 * personaScore) +
        (0.4 * surfaceStrength) +
        (0.2 * (contextReady ? 1.0 : 0.0));
    strength = strength.clamp(0.0, 1.0);

    return Map<String, Object>.unmodifiable(<String, Object>{
      'micro_ux_shift_v1': Map<String, Object>.unmodifiable(<String, Object>{
        'shift_tag': _ascii(tag),
        'shift_strength': strength,
        'ready': safeContext.isNotEmpty,
      }),
    });
  }

  static String _detectShiftTag(
    Map<String, Object> context,
    Map<String, Object> persona,
    Map<String, Object> table,
  ) {
    final String contextTag = _extractString(context, 'aggregation_tag');
    if (contextTag.isNotEmpty) return contextTag;
    final String personaTag = _extractString(persona, 'global_tag');
    if (personaTag.isNotEmpty) return personaTag;
    final String tableTag = _extractString(table, 'surface_tag');
    if (tableTag.isNotEmpty) return tableTag;
    return 'neutral';
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
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  static String _extractString(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static Map<String, Object> _sanitize(Map<String, Object>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object> entry in source.entries) {
      cleaned[_ascii(entry.key)] = entry.value;
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
