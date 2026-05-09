class OmegaMasterBundleV1 {
  OmegaMasterBundleV1._();

  static Map<String, Object> build({
    Map<String, Object?>? omegaIntegrationSurfaceMap,
    Map<String, Object?>? omegaIntegrationRouterMap,
    Map<String, Object?>? omegaIntegrationBridgeMap,
    Map<String, Object?>? omegaIntegrationConsolidatorMap,
    Map<String, Object?>? omegaIntegrationEnvelopeMap,
    Map<String, Object?>? personaGlobalV1Map,
  }) {
    final double surfaceValue = _extractNested(
      omegaIntegrationSurfaceMap,
      'omega_integration_surface_v1',
      'surface_strength',
    );
    final double routerValue = _extractNested(
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
    final double globalValue = _extractNested(
      personaGlobalV1Map,
      'persona_global_v1',
      'global_score',
    );

    double masterValue =
        (surfaceValue * 0.35) +
        (routerValue * 0.25) +
        (bridgeValue * 0.15) +
        (consolidatorValue * 0.15) +
        (envelopeValue * 0.05) +
        (globalValue * 0.05);
    masterValue = masterValue.clamp(0.0, 1.0);

    String masterTag = _extractNestedTag(
      omegaIntegrationSurfaceMap,
      'omega_integration_surface_v1',
      'surface_tag',
    );
    if (masterTag.isEmpty) {
      masterTag = _extractNestedTag(
        omegaIntegrationRouterMap,
        'omega_integration_router_v1',
        'route_tag',
      );
    }
    if (masterTag.isEmpty) {
      masterTag = _extractNestedTag(
        omegaIntegrationBridgeMap,
        'omega_integration_bridge_v1',
        'tag',
      );
    }
    if (masterTag.isEmpty) {
      masterTag = _extractNestedTag(
        omegaIntegrationConsolidatorMap,
        'omega_integration_consolidator_v1',
        'tag',
      );
    }
    if (masterTag.isEmpty) {
      masterTag = _extractNestedTag(
        omegaIntegrationEnvelopeMap,
        'omega_integration_envelope_v1',
        'tag',
      );
    }
    if (masterTag.isEmpty) {
      masterTag = _extractNestedTag(
        personaGlobalV1Map,
        'persona_global_v1',
        'global_tag',
      );
    }
    if (masterTag.isEmpty) masterTag = 'omega_master';

    final Map<String, Object> payload = <String, Object>{
      'master_value': masterValue,
      'master_tag': _ascii(masterTag),
      'ready': true,
    };
    return Map<String, Object>.unmodifiable(<String, Object>{
      'omega_master_bundle_v1': Map<String, Object>.unmodifiable(payload),
    });
  }

  static double _extractNested(
    Map<String, Object?>? map,
    String sectionKey,
    String entryKey,
  ) {
    if (map == null) return 0.0;
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extract(section, entryKey);
    }
    return 0.0;
  }

  static String _extractNestedTag(
    Map<String, Object?>? map,
    String sectionKey,
    String entryKey,
  ) {
    if (map == null) return '';
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

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
