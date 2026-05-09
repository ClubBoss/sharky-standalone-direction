class TableAdaptationSurfaceV1 {
  const TableAdaptationSurfaceV1({
    this.tableAdaptationRouterMap = const <String, Object>{},
    this.tableAdaptationBridgeMap = const <String, Object>{},
    this.tableAdaptationConsolidatorMap = const <String, Object>{},
    this.tableAdaptationEnvelopeMap = const <String, Object>{},
    this.tableAdaptationSeedMap = const <String, Object>{},
  });

  TableAdaptationSurfaceV1.fromInputs({
    Map<String, Object?>? tableAdaptationRouterMap,
    Map<String, Object?>? tableAdaptationBridgeMap,
    Map<String, Object?>? tableAdaptationConsolidatorMap,
    Map<String, Object?>? tableAdaptationEnvelopeMap,
    Map<String, Object?>? tableAdaptationSeedMap,
  }) : this(
         tableAdaptationRouterMap: _safe(tableAdaptationRouterMap),
         tableAdaptationBridgeMap: _safe(tableAdaptationBridgeMap),
         tableAdaptationConsolidatorMap: _safe(tableAdaptationConsolidatorMap),
         tableAdaptationEnvelopeMap: _safe(tableAdaptationEnvelopeMap),
         tableAdaptationSeedMap: _safe(tableAdaptationSeedMap),
       );

  final Map<String, Object> tableAdaptationRouterMap;
  final Map<String, Object> tableAdaptationBridgeMap;
  final Map<String, Object> tableAdaptationConsolidatorMap;
  final Map<String, Object> tableAdaptationEnvelopeMap;
  final Map<String, Object> tableAdaptationSeedMap;

  Map<String, Object> build() {
    final double routerStrength = _extractNested(
      tableAdaptationRouterMap,
      'table_adaptation_router_v1',
      'route_strength',
    );
    final double bridgeValue = _extractNested(
      tableAdaptationBridgeMap,
      'table_adaptation_bridge_v1',
      'bridge_value',
    );
    final double consolidatedValue = _extractNested(
      tableAdaptationConsolidatorMap,
      'table_adaptation_consolidator_v1',
      'consolidated_value',
    );
    final double envelopeValue = _extractNested(
      tableAdaptationEnvelopeMap,
      'table_adaptation_envelope_v1',
      'envelope_value',
    );

    double surfaceStrength =
        (routerStrength * 0.5) +
        (bridgeValue * 0.2) +
        (consolidatedValue * 0.2) +
        (envelopeValue * 0.1);
    surfaceStrength = surfaceStrength.clamp(0.0, 1.0);

    String surfaceTag = _extractNestedTag(
      tableAdaptationRouterMap,
      'table_adaptation_router_v1',
      'route_tag',
    );
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        tableAdaptationBridgeMap,
        'table_adaptation_bridge_v1',
        'bridge_tag',
      );
    }
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        tableAdaptationConsolidatorMap,
        'table_adaptation_consolidator_v1',
        'consolidated_tag',
      );
    }
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        tableAdaptationEnvelopeMap,
        'table_adaptation_envelope_v1',
        'envelope_tag',
      );
    }
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        tableAdaptationSeedMap,
        'table_adaptation_seed_v1',
        'adaptation_tag',
      );
    }
    if (surfaceTag.isEmpty) surfaceTag = 'surface';

    final Map<String, Object> payload = <String, Object>{
      'surface_tag': _ascii(surfaceTag),
      'surface_strength': surfaceStrength,
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'table_adaptation_surface_v1': Map<String, Object>.unmodifiable(payload),
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
