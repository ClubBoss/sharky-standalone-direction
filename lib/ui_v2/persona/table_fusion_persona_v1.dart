/// Passive Table Fusion Persona V1 (Phi-74.2).
class TableFusionPersonaV1 {
  const TableFusionPersonaV1(
    this.tableHintMapV1,
    this.tablePersonalizationBridgeV1,
    this.personaOutput,
    this.personaHints,
  );

  final Object tableHintMapV1;
  final Object tablePersonalizationBridgeV1;
  final Object personaOutput;
  final Object personaHints;

  Map<String, Object> asReadOnlyMap() {
    final Object hintsCandidate = tableHintMapV1;
    final Object contextCandidate = tablePersonalizationBridgeV1;
    final Object personaOutputCandidate = personaOutput;
    final Object personaHintsCandidate = personaHints;
    final bool hasHints =
        hintsCandidate is Map && (hintsCandidate as Map).isNotEmpty;
    final bool hasContext =
        contextCandidate is Map && (contextCandidate as Map).isNotEmpty;
    final bool hasPersonaOutput =
        personaOutputCandidate is Map &&
        (personaOutputCandidate as Map).isNotEmpty;
    final bool hasPersonaHints =
        personaHintsCandidate is Map &&
        (personaHintsCandidate as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasHints) missing.add('table_hint_map_v1');
    if (!hasContext) missing.add('table_personalization_bridge_v1');
    if (!hasPersonaOutput) missing.add('persona_output');
    if (!hasPersonaHints) missing.add('persona_hints');
    final bool fusionReady = missing.isEmpty;
    return <String, Object>{
      'table_fusion_persona_v1': <String, Object>{
        'context': hasContext ? contextCandidate : <Object>{},
        'hints': hasHints ? hintsCandidate : <Object>{},
        'persona_output': hasPersonaOutput
            ? personaOutputCandidate
            : <Object>{},
        'persona_hints': hasPersonaHints ? personaHintsCandidate : <Object>{},
        'fusion_ready': fusionReady,
        'missing': missing,
      },
      'ready': fusionReady,
    };
  }
}
