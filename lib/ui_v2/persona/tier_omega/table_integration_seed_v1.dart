class TableIntegrationSeedV1 {
  const TableIntegrationSeedV1({
    this.tableAdaptationSurfaceMap = const <String, Object>{},
    this.tableAdaptationRouterMap = const <String, Object>{},
    this.tableAdaptationBridgeMap = const <String, Object>{},
    this.personaGlobalV1Map = const <String, Object>{},
    this.personaGlobalConsolidatorMap = const <String, Object>{},
    this.personaGlobalEnvelopeMap = const <String, Object>{},
  });

  TableIntegrationSeedV1.fromInputs({
    Map<String, Object?>? tableAdaptationSurfaceMap,
    Map<String, Object?>? tableAdaptationRouterMap,
    Map<String, Object?>? tableAdaptationBridgeMap,
    Map<String, Object?>? personaGlobalV1Map,
    Map<String, Object?>? personaGlobalConsolidatorMap,
    Map<String, Object?>? personaGlobalEnvelopeMap,
  }) : this(
         tableAdaptationSurfaceMap: _safe(tableAdaptationSurfaceMap),
         tableAdaptationRouterMap: _safe(tableAdaptationRouterMap),
         tableAdaptationBridgeMap: _safe(tableAdaptationBridgeMap),
         personaGlobalV1Map: _safe(personaGlobalV1Map),
         personaGlobalConsolidatorMap: _safe(personaGlobalConsolidatorMap),
         personaGlobalEnvelopeMap: _safe(personaGlobalEnvelopeMap),
       );

  final Map<String, Object> tableAdaptationSurfaceMap;
  final Map<String, Object> tableAdaptationRouterMap;
  final Map<String, Object> tableAdaptationBridgeMap;
  final Map<String, Object> personaGlobalV1Map;
  final Map<String, Object> personaGlobalConsolidatorMap;
  final Map<String, Object> personaGlobalEnvelopeMap;

  Map<String, Object> build() {
    final double globalScore = _extractNested(
      personaGlobalV1Map,
      'persona_global_v1',
      'global_score',
    );
    final double surfaceStrength = _extractNested(
      tableAdaptationSurfaceMap,
      'table_adaptation_surface_v1',
      'surface_strength',
    );
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

    double integrationStrength =
        (globalScore * 0.5) +
        (surfaceStrength * 0.3) +
        (routerStrength * 0.15) +
        (bridgeValue * 0.05);
    integrationStrength = integrationStrength.clamp(0.0, 1.0);

    String integrationTag = _extractNestedTag(
      personaGlobalV1Map,
      'persona_global_v1',
      'global_tag',
    );
    if (integrationTag.isEmpty) {
      integrationTag = _extractNestedTag(
        tableAdaptationSurfaceMap,
        'table_adaptation_surface_v1',
        'surface_tag',
      );
    }
    if (integrationTag.isEmpty) {
      integrationTag = _extractNestedTag(
        tableAdaptationRouterMap,
        'table_adaptation_router_v1',
        'route_tag',
      );
    }
    if (integrationTag.isEmpty) {
      integrationTag = _extractNestedTag(
        tableAdaptationBridgeMap,
        'table_adaptation_bridge_v1',
        'bridge_tag',
      );
    }
    if (integrationTag.isEmpty) integrationTag = 'integration';

    final Map<String, Object> payload = <String, Object>{
      'integration_tag': _ascii(integrationTag),
      'integration_strength': integrationStrength,
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'table_integration_seed_v1': Map<String, Object>.unmodifiable(payload),
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
