/// Passive persona-driven table context bridge V1 (Phi-72.0).
class TableContextBridgeV1 {
  const TableContextBridgeV1(
    this.tableViewShellV1Map,
    this.aiPersonalizationTierBOutputV1Map,
    this.aiPersonalizationUIPersonalityHintsV1Map,
  );

  final Object tableViewShellV1Map;
  final Object aiPersonalizationTierBOutputV1Map;
  final Object aiPersonalizationUIPersonalityHintsV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object shellCandidate = tableViewShellV1Map;
    final Object outputCandidate = aiPersonalizationTierBOutputV1Map;
    final Object hintsCandidate = aiPersonalizationUIPersonalityHintsV1Map;
    final bool hasShell =
        shellCandidate is Map && (shellCandidate as Map).isNotEmpty;
    final bool hasOutput =
        outputCandidate is Map && (outputCandidate as Map).isNotEmpty;
    final bool hasHints =
        hintsCandidate is Map && (hintsCandidate as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasShell) missing.add('table_view_shell_v1');
    if (!hasOutput) missing.add('ai_personalization_tier_b_output_v1');
    if (!hasHints) missing.add('ai_personalization_ui_personality_hints_v1');

    final Map<String, Object> bridge = <String, Object>{
      'table_shell': hasShell ? shellCandidate : <Object>{},
      'persona_output': hasOutput ? outputCandidate : <Object>{},
      'persona_hints': hasHints ? hintsCandidate : <Object>{},
      'bridge_ready': missing.isEmpty,
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'table_context_bridge_v1': bridge,
      'readiness': readiness,
      'missing': missing,
    };
  }
}
