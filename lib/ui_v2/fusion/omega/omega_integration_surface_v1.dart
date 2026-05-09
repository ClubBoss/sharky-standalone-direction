class OmegaIntegrationSurfaceV1 {
  const OmegaIntegrationSurfaceV1({
    this.omegaIntegrationRouterMap = const <String, Object>{},
    this.omegaIntegrationBridgeMap = const <String, Object>{},
    this.omegaIntegrationConsolidatorMap = const <String, Object>{},
    this.omegaIntegrationEnvelopeMap = const <String, Object>{},
    this.personaGlobalV1Map = const <String, Object>{},
  });

  OmegaIntegrationSurfaceV1.fromInputs({
    Map<String, Object?>? omegaIntegrationRouterMap,
    Map<String, Object?>? omegaIntegrationBridgeMap,
    Map<String, Object?>? omegaIntegrationConsolidatorMap,
    Map<String, Object?>? omegaIntegrationEnvelopeMap,
    Map<String, Object?>? personaGlobalV1Map,
  }) : this(
         omegaIntegrationRouterMap: _safe(omegaIntegrationRouterMap),
         omegaIntegrationBridgeMap: _safe(omegaIntegrationBridgeMap),
         omegaIntegrationConsolidatorMap: _safe(
           omegaIntegrationConsolidatorMap,
         ),
         omegaIntegrationEnvelopeMap: _safe(omegaIntegrationEnvelopeMap),
         personaGlobalV1Map: _safe(personaGlobalV1Map),
       );

  final Map<String, Object> omegaIntegrationRouterMap;
  final Map<String, Object> omegaIntegrationBridgeMap;
  final Map<String, Object> omegaIntegrationConsolidatorMap;
  final Map<String, Object> omegaIntegrationEnvelopeMap;
  final Map<String, Object> personaGlobalV1Map;

  Map<String, Object> build() {
    final double routerStrength = _extractNested(
      omegaIntegrationRouterMap,
      'omega_integration_router_v1',
      'route_strength',
    );
    final double bridgeValue = _extractNested(
      omegaIntegrationBridgeMap,
      'omega_integration_bridge_v1',
      'value',
    );
    final double consolidatorValue = _extractNested(
      omegaIntegrationConsolidatorMap,
      'omega_integration_consolidator_v1',
      'value',
    );
    final double envelopeValue = _extractNested(
      omegaIntegrationEnvelopeMap,
      'omega_integration_envelope_v1',
      'value',
    );

    double surfaceStrength =
        (routerStrength * 0.4) +
        (bridgeValue * 0.3) +
        (consolidatorValue * 0.2) +
        (envelopeValue * 0.1);
    surfaceStrength = surfaceStrength.clamp(0.0, 1.0);

    String surfaceTag = _extractNestedTag(
      omegaIntegrationRouterMap,
      'omega_integration_router_v1',
      'route_tag',
    );
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        omegaIntegrationBridgeMap,
        'omega_integration_bridge_v1',
        'tag',
      );
    }
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        omegaIntegrationConsolidatorMap,
        'omega_integration_consolidator_v1',
        'tag',
      );
    }
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        omegaIntegrationEnvelopeMap,
        'omega_integration_envelope_v1',
        'tag',
      );
    }
    if (surfaceTag.isEmpty) {
      surfaceTag = _extractNestedTag(
        personaGlobalV1Map,
        'persona_global_v1',
        'global_tag',
      );
    }
    if (surfaceTag.isEmpty) surfaceTag = 'surface';

    final Map<String, Object> payload = <String, Object>{
      'surface_strength': surfaceStrength,
      'surface_tag': _ascii(surfaceTag),
      'ready': true,
    };
    return Map<String, Object>.unmodifiable(<String, Object>{
      'omega_integration_surface_v1': Map<String, Object>.unmodifiable(payload),
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
