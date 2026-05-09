class TableAdaptationBridgeV1 {
  const TableAdaptationBridgeV1({
    this.tableAdaptationSeedMap = const <String, Object>{},
    this.tableAdaptationEnvelopeMap = const <String, Object>{},
    this.tableAdaptationConsolidatorMap = const <String, Object>{},
  });

  TableAdaptationBridgeV1.fromInputs({
    Map<String, Object?>? tableAdaptationSeedMap,
    Map<String, Object?>? tableAdaptationEnvelopeMap,
    Map<String, Object?>? tableAdaptationConsolidatorMap,
  }) : this(
         tableAdaptationSeedMap: _safe(tableAdaptationSeedMap),
         tableAdaptationEnvelopeMap: _safe(tableAdaptationEnvelopeMap),
         tableAdaptationConsolidatorMap: _safe(tableAdaptationConsolidatorMap),
       );

  final Map<String, Object> tableAdaptationSeedMap;
  final Map<String, Object> tableAdaptationEnvelopeMap;
  final Map<String, Object> tableAdaptationConsolidatorMap;

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
    final double consolidatedValue = _extractNested(
      tableAdaptationConsolidatorMap,
      'table_adaptation_consolidator_v1',
      'consolidated_value',
    );

    double bridgeValue =
        (consolidatedValue * 0.5) + (envelopeValue * 0.3) + (seedScore * 0.2);
    bridgeValue = bridgeValue.clamp(0.0, 1.0);

    String bridgeTag = _extractNestedTag(
      tableAdaptationConsolidatorMap,
      'table_adaptation_consolidator_v1',
      'consolidated_tag',
    );
    if (bridgeTag.isEmpty) {
      bridgeTag = _extractNestedTag(
        tableAdaptationEnvelopeMap,
        'table_adaptation_envelope_v1',
        'envelope_tag',
      );
    }
    if (bridgeTag.isEmpty) {
      bridgeTag = _extractNestedTag(
        tableAdaptationSeedMap,
        'table_adaptation_seed_v1',
        'adaptation_tag',
      );
    }
    if (bridgeTag.isEmpty) bridgeTag = 'bridge';

    final Map<String, Object> payload = <String, Object>{
      'bridge_value': bridgeValue,
      'bridge_tag': _ascii(bridgeTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'table_adaptation_bridge_v1': Map<String, Object>.unmodifiable(payload),
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
