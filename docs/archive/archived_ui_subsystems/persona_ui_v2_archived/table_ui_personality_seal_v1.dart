/// Passive Table UI Personality Seal V1 (Phi-74.5).
class TableUIPersonalitySealV1 {
  const TableUIPersonalitySealV1(
    this.tableFusionConsistencyQAV1Map,
    this.tableAdaptivePersonaSpecV1Map,
    this.tableFusionPersonaV1Map,
    this.tableHintMapV1,
    this.personaOutput,
    this.personaHints,
  );

  final Object tableFusionConsistencyQAV1Map;
  final Object tableAdaptivePersonaSpecV1Map;
  final Object tableFusionPersonaV1Map;
  final Object tableHintMapV1;
  final Object personaOutput;
  final Object personaHints;

  Map<String, Object> asReadOnlyMap() {
    final Object consistencyCandidate = tableFusionConsistencyQAV1Map;
    final Object specCandidate = tableAdaptivePersonaSpecV1Map;
    final Object fusionCandidate = tableFusionPersonaV1Map;
    final Object hintsCandidate = tableHintMapV1;
    final Object personaOutputCandidate = personaOutput;
    final Object personaHintsCandidate = personaHints;
    final bool hasConsistency =
        consistencyCandidate is Map && (consistencyCandidate as Map).isNotEmpty;
    final bool hasSpec =
        specCandidate is Map && (specCandidate as Map).isNotEmpty;
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
    if (!hasConsistency) missing.add('table_fusion_consistency_qa_v1');
    if (!hasSpec) missing.add('table_adaptive_persona_spec_v1');
    if (!hasFusion) missing.add('table_fusion_persona_v1');
    if (!hasHints) missing.add('table_hint_map_v1');
    if (!hasPersonaOutput) missing.add('persona_output');
    if (!hasPersonaHints) missing.add('persona_hints');
    final bool sealReady = missing.isEmpty;
    return <String, Object>{
      'table_ui_personality_seal_v1': <String, Object>{
        'consistency': hasConsistency ? consistencyCandidate : <Object>{},
        'spec': hasSpec ? specCandidate : <Object>{},
        'fusion': hasFusion ? fusionCandidate : <Object>{},
        'hints': hasHints ? hintsCandidate : <Object>{},
        'persona_output': hasPersonaOutput
            ? personaOutputCandidate
            : <Object>{},
        'persona_hints': hasPersonaHints ? personaHintsCandidate : <Object>{},
        'seal_ready': sealReady,
        'missing': missing,
      },
      'ready': sealReady,
    };
  }
}
