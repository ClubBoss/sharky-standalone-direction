// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Counter — Φ-48.0
///
/// Passive container for V4 Theme Controller Integration Layer v1.
class ThemeControllerIntegrationLayerV1 {
  const ThemeControllerIntegrationLayerV1({
    required this.themeRuntimeExportPackV1,
    required this.personaThemeFinalSurfaceGatewayV1,
    required this.personaFinalSurfacePackV1,
    required this.personaResolutionGatewayV1,
    required this.personaFusionGatewayV1,
    required this.personaFusionNodeV1,
    required this.themeFinalGatewayV1,
    required this.themePersonaExportPackV1,
    required this.v4ThemeController,
    required this.personaAdaptiveThemeBuilderV3,
    required this.personaAdaptiveThemeBlendV2,
    required this.personaAdaptiveThemeProxyV2,
  });

  final Object themeRuntimeExportPackV1;
  final Object personaThemeFinalSurfaceGatewayV1;
  final Object personaFinalSurfacePackV1;
  final Object personaResolutionGatewayV1;
  final Object personaFusionGatewayV1;
  final Object personaFusionNodeV1;
  final Object themeFinalGatewayV1;
  final Object themePersonaExportPackV1;
  final Object v4ThemeController;
  final Object personaAdaptiveThemeBuilderV3;
  final Object personaAdaptiveThemeBlendV2;
  final Object personaAdaptiveThemeProxyV2;

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'runtime_export': '<opaque>',
      'persona_surface_gateway': '<opaque>',
      'persona_final_surface': '<opaque>',
      'persona_resolution_gateway': '<opaque>',
      'persona_fusion_gateway': '<opaque>',
      'persona_fusion_node': '<opaque>',
      'theme_final_gateway': '<opaque>',
      'persona_export_pack': '<opaque>',
      'controller': '<opaque>',
      'builder': '<opaque>',
      'blend': '<opaque>',
      'proxy': '<opaque>',
    };
  }
}
