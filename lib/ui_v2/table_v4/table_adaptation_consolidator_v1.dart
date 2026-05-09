class TableAdaptationConsolidatorV1 {
  const TableAdaptationConsolidatorV1({
    this.tableAdaptationSeedMap = const <String, Object>{},
    this.tableAdaptationEnvelopeMap = const <String, Object>{},
  });

  TableAdaptationConsolidatorV1.fromInputs({
    Map<String, Object?>? tableAdaptationSeedMap,
    Map<String, Object?>? tableAdaptationEnvelopeMap,
  }) : this(
         tableAdaptationSeedMap: _safe(tableAdaptationSeedMap),
         tableAdaptationEnvelopeMap: _safe(tableAdaptationEnvelopeMap),
       );

  final Map<String, Object> tableAdaptationSeedMap;
  final Map<String, Object> tableAdaptationEnvelopeMap;

  Map<String, Object> build() {
    final double seedScore = _extractNested(
      tableAdaptationSeedMap,
      'table_adaptation_seed_v1',
      'adaptation_score',
    );
    final double envelopeValue = _extractNested(
      tableAdaptationEnvelopeMap,
      'table_adaptation_envelope_v1',
      'envelope_value',
    );

    double consolidatedValue = (seedScore * 0.5) + (envelopeValue * 0.5);
    consolidatedValue = consolidatedValue.clamp(0.0, 1.0);

    String consolidatedTag = _extractNestedTag(
      tableAdaptationEnvelopeMap,
      'table_adaptation_envelope_v1',
      'envelope_tag',
    );
    if (consolidatedTag.isEmpty) {
      consolidatedTag = _extractNestedTag(
        tableAdaptationSeedMap,
        'table_adaptation_seed_v1',
        'adaptation_tag',
      );
    }
    if (consolidatedTag.isEmpty) consolidatedTag = 'consolidated';

    final Map<String, Object> payload = <String, Object>{
      'consolidated_value': consolidatedValue,
      'consolidated_tag': _ascii(consolidatedTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'table_adaptation_consolidator_v1': Map<String, Object>.unmodifiable(
        payload,
      ),
    });
  }

  static double _extractNested(
    Map<String, Object> map,
    String sectionKey,
    String entryKey,
  ) {
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extract(section, entryKey);
    }
    return 0.0;
  }

  static String _extractNestedTag(
    Map<String, Object> map,
    String sectionKey,
    String entryKey,
  ) {
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extractTag(section, entryKey);
    }
    return '';
  }

  static double _extract(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static String _extractTag(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      if (entry.value == null) continue;
      cleaned[entry.key] = entry.value!;
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
