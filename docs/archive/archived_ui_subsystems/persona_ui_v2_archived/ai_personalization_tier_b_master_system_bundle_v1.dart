/// Tier-B master system bundle (Phi-32.19).
class AIPersonalizationTierBMasterSystemBundleV1 {
  const AIPersonalizationTierBMasterSystemBundleV1({
    required this.tierBOutputMap,
    required this.tierBHintsMap,
    required this.tierBSystemBridgeMap,
  });

  final Object tierBOutputMap;
  final Object tierBHintsMap;
  final Object tierBSystemBridgeMap;

  Map<String, Object> asReadOnlyMap() {
    final bool hasOutput =
        tierBOutputMap is Map && (tierBOutputMap as Map).isNotEmpty;
    final bool hasHints =
        tierBHintsMap is Map && (tierBHintsMap as Map).isNotEmpty;
    final bool hasBridge =
        tierBSystemBridgeMap is Map && (tierBSystemBridgeMap as Map).isNotEmpty;
    final bool bridgeReady =
        hasBridge && (tierBSystemBridgeMap as Map)['bridge_ready'] == true;
    final bool bundleReady = hasOutput && hasHints && bridgeReady;

    return <String, Object>{
      'output': hasOutput ? tierBOutputMap : <Object>{},
      'hints': hasHints ? tierBHintsMap : <Object>{},
      'system_bridge': hasBridge ? tierBSystemBridgeMap : <Object>{},
      'bundle_ready': bundleReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}
