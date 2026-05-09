class OmegaFinalExportV1 {
  OmegaFinalExportV1._();

  static Map<String, Object> build({
    Map<String, Object?>? omegaMasterBundleMap,
    Map<String, Object?>? omegaIntegrationSurfaceMap,
    Map<String, Object?>? omegaIntegrationRouterMap,
    Map<String, Object?>? omegaIntegrationBridgeMap,
    Map<String, Object?>? omegaIntegrationConsolidatorMap,
    Map<String, Object?>? personaGlobalV1Map,
  }) {
    final double masterValue = _extractNested(
      omegaMasterBundleMap,
      'omega_master_bundle_v1',
      'master_value',
    );
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
    final double globalValue = _extractNested(
      personaGlobalV1Map,
      'persona_global_v1',
      'global_score',
    );

    double exportValue =
        (masterValue * 0.4) +
        (surfaceValue * 0.2) +
        (routerValue * 0.15) +
        (bridgeValue * 0.1) +
        (consolidatorValue * 0.1) +
        (globalValue * 0.05);
    exportValue = exportValue.clamp(0.0, 1.0);

    String exportTag = _extractNestedTag(
      omegaMasterBundleMap,
      'omega_master_bundle_v1',
      'master_tag',
    );
    if (exportTag.isEmpty) {
      exportTag = _extractNestedTag(
        omegaIntegrationSurfaceMap,
        'omega_integration_surface_v1',
        'surface_tag',
      );
    }
    if (exportTag.isEmpty) {
      exportTag = _extractNestedTag(
        omegaIntegrationRouterMap,
        'omega_integration_router_v1',
        'route_tag',
      );
    }
    if (exportTag.isEmpty) {
      exportTag = _extractNestedTag(
        omegaIntegrationBridgeMap,
        'omega_integration_bridge_v1',
        'tag',
      );
    }
    if (exportTag.isEmpty) {
      exportTag = _extractNestedTag(
        omegaIntegrationConsolidatorMap,
        'omega_integration_consolidator_v1',
        'tag',
      );
    }
    if (exportTag.isEmpty) {
      exportTag = _extractNestedTag(
        personaGlobalV1Map,
        'persona_global_v1',
        'global_tag',
      );
    }
    if (exportTag.isEmpty) exportTag = 'omega_export';

    final Map<String, Object> payload = <String, Object>{
      'export_value': exportValue,
      'export_tag': _ascii(exportTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'omega_final_export_v1': Map<String, Object>.unmodifiable(payload),
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
