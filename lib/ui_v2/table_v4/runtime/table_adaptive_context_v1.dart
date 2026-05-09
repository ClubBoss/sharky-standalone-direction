class TableAdaptiveContextV1 {
  const TableAdaptiveContextV1({
    required this.personaSignals,
    required this.tableSignals,
    required this.ready,
  });

  final Map<String, Object> personaSignals;
  final Map<String, Object> tableSignals;
  final bool ready;

  Map<String, Object> toMap() => <String, Object>{
    'persona_signals': personaSignals,
    'table_signals': tableSignals,
    'ready': ready,
  };

  static TableAdaptiveContextV1 fromInputs({
    Map<String, Object>? persona,
    Map<String, Object>? table,
  }) {
    final Map<String, Object> safePersona = _sanitize(persona);
    final Map<String, Object> safeTable = _sanitize(table);
    return TableAdaptiveContextV1(
      personaSignals: safePersona,
      tableSignals: safeTable,
      ready: safePersona.isNotEmpty && safeTable.isNotEmpty,
    );
  }

  static Map<String, Object> _sanitize(Map<String, Object>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> sanitized = <String, Object>{};
    for (final MapEntry<String, Object> entry in source.entries) {
      final String key = _ascii(entry.key);
      sanitized[key] = entry.value;
    }
    return Map<String, Object>.unmodifiable(sanitized);
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
