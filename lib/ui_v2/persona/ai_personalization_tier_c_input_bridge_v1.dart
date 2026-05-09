/// Tier-C input bridge (Phi-39.1).
class AIPersonalizationTierCInputBridgeV1 {
  const AIPersonalizationTierCInputBridgeV1(
    this.tierBFinalVerdict,
    this.tableShellContext,
    this.personaProfileContext,
  );

  final Map<String, Object> tierBFinalVerdict;
  final Map<String, Object> tableShellContext;
  final Map<String, Object> personaProfileContext;

  Map<String, Object> asReadOnlyMap() {
    final bool tierBReady =
        tierBFinalVerdict.isNotEmpty &&
        tierBFinalVerdict['verdict_ready'] == true;

    final bool tableContextReady = tableShellContext.isNotEmpty;
    final Object? deviceClass = tableShellContext['device_class'];
    final Object? viewShellTokens = tableShellContext['view_shell_tokens'];
    final bool hasDeviceClass =
        deviceClass != null &&
        (!(deviceClass is Iterable) || deviceClass.isNotEmpty) &&
        (!(deviceClass is Map) || deviceClass.isNotEmpty);
    final bool hasViewShellTokens =
        viewShellTokens != null &&
        (!(viewShellTokens is Iterable) || viewShellTokens.isNotEmpty) &&
        (!(viewShellTokens is Map) || viewShellTokens.isNotEmpty);

    final bool personaContextReady = personaProfileContext.isNotEmpty;
    final Object? personaId = personaProfileContext['persona_id'];
    final bool hasPersonaId =
        personaId != null &&
        (!(personaId is String) || personaId.trim().isNotEmpty);

    final bool bridgeReady =
        tierBReady &&
        tableContextReady &&
        hasDeviceClass &&
        hasViewShellTokens &&
        personaContextReady &&
        hasPersonaId;

    return <String, Object>{
      'tier_b': tierBReady ? tierBFinalVerdict : <Object>{},
      'table_context': tableContextReady ? tableShellContext : <Object>{},
      'persona_context': personaContextReady
          ? personaProfileContext
          : <Object>{},
      'bridge_ready': bridgeReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}
