/// Counter - Phi-59.0
///
/// Passive QA sweep for V4 runtime toggle.
class V4RuntimeToggleQAV1 {
  const V4RuntimeToggleQAV1({
    required this.themeV4Controller,
    required this.activationFrame,
    required this.activationSyncMap,
    required this.materializationMap,
  });

  final Object themeV4Controller;
  final Object activationFrame;
  final Map<String, Object?> activationSyncMap;
  final Map<String, Object?> materializationMap;

  bool get isConsistent {
    final dynamic controller = themeV4Controller;
    final dynamic frame = activationFrame;
    final bool v4Active = (controller as dynamic)?.isActive == true;
    final bool frameReady =
        frame != null &&
        frame.tableUIRenderingGatewayV1 != null &&
        frame.tableUIRenderingBinderV1 != null &&
        frame.tableUIRuntimeBinderV1 != null &&
        frame.tableUISurfaceSkeletonV1 != null &&
        frame.v4ThemeHolderV2 != null &&
        frame.materialAppShellV4SupervisorV1 != null &&
        frame.v4ActivationDeliveryBinderV1 != null &&
        frame.personaThemeFinalSurfaceGatewayV1 != null;
    final bool syncReady = activationSyncMap['v4_ready'] == true;
    final bool materialized = materializationMap['v4_active'] == true;
    return v4Active && frameReady && syncReady && materialized;
  }
}
