/// Passive table adaptive persona spec V1 (Phi-74.3).
class TableAdaptivePersonaSpecV1 {
  const TableAdaptivePersonaSpecV1(
    this.tableFusionPersonaV1Map,
    this.tableHintMapV1,
    this.personaOutput,
    this.personaHints,
  );

  final Object tableFusionPersonaV1Map;
  final Object tableHintMapV1;
  final Object personaOutput;
  final Object personaHints;

  Map<String, Object> asReadOnlyMap() {
    final Object fusionCandidate = tableFusionPersonaV1Map;
    final Object hintsCandidate = tableHintMapV1;
    final Object personaOutputCandidate = personaOutput;
    final Object personaHintsCandidate = personaHints;
    final bool hasFusion =
        fusionCandidate is Map && (fusionCandidate as Map).isNotEmpty;
    final bool hasHints =
        hintsCandidate is Map && (hintsCandidate as Map).isNotEmpty;
    final bool hasPersonaOutput =
        personaOutputCandidate is Map &&
        (personaOutputCandidate as Map).isNotEmpty;
    final bool hasPersonaHints =
        personaHintsCandidate is Map &&
        (personaHintsCandidate as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasFusion) missing.add('table_fusion_persona_v1');
    if (!hasHints) missing.add('table_hint_map_v1');
    if (!hasPersonaOutput) missing.add('persona_output');
    if (!hasPersonaHints) missing.add('persona_hints');
    final bool specReady = missing.isEmpty;
    return <String, Object>{
      'table_adaptive_persona_spec_v1': <String, Object>{
        'fusion': hasFusion ? fusionCandidate : <Object>{},
        'hints': hasHints ? hintsCandidate : <Object>{},
        'persona_output': hasPersonaOutput
            ? personaOutputCandidate
            : <Object>{},
        'persona_hints': hasPersonaHints ? personaHintsCandidate : <Object>{},
        'spec_ready': specReady,
        'missing': missing,
      },
      'ready': specReady,
    };
  }
}
