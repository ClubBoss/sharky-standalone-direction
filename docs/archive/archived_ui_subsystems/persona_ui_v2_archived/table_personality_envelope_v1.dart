/// Passive table personality envelope V1 (Phi-74.7).
class TablePersonalityEnvelopeV1 {
  const TablePersonalityEnvelopeV1(
    this.tablePersonalityRenderContextV1Map,
    this.tableUIPersonalitySealV1Map,
    this.tableAdaptivePersonaSpecV1Map,
    this.tableFusionPersonaV1Map,
    this.tableHintMapV1,
    this.personaOutput,
    this.personaHints,
  );

  final Object tablePersonalityRenderContextV1Map;
  final Object tableUIPersonalitySealV1Map;
  final Object tableAdaptivePersonaSpecV1Map;
  final Object tableFusionPersonaV1Map;
  final Object tableHintMapV1;
  final Object personaOutput;
  final Object personaHints;

  Map<String, Object> asReadOnlyMap() {
    final bool hasRender =
        tablePersonalityRenderContextV1Map is Map &&
        (tablePersonalityRenderContextV1Map as Map).isNotEmpty;
    final bool hasSeal =
        tableUIPersonalitySealV1Map is Map &&
        (tableUIPersonalitySealV1Map as Map).isNotEmpty;
    final bool hasSpec =
        tableAdaptivePersonaSpecV1Map is Map &&
        (tableAdaptivePersonaSpecV1Map as Map).isNotEmpty;
    final bool hasFusion =
        tableFusionPersonaV1Map is Map &&
        (tableFusionPersonaV1Map as Map).isNotEmpty;
    final bool hasHints =
        tableHintMapV1 is Map && (tableHintMapV1 as Map).isNotEmpty;
    final bool hasPersonaOutput =
        personaOutput is Map && (personaOutput as Map).isNotEmpty;
    final bool hasPersonaHints =
        personaHints is Map && (personaHints as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasRender) missing.add('table_personality_render_context_v1');
    if (!hasSeal) missing.add('table_ui_personality_seal_v1');
    if (!hasSpec) missing.add('table_adaptive_persona_spec_v1');
    if (!hasFusion) missing.add('table_fusion_persona_v1');
    if (!hasHints) missing.add('table_hint_map_v1');
    if (!hasPersonaOutput) missing.add('persona_output');
    if (!hasPersonaHints) missing.add('persona_hints');
    final bool envelopeReady = missing.isEmpty;
    return <String, Object>{
      'table_personality_envelope_v1': <String, Object>{
        'render_context': hasRender
            ? tablePersonalityRenderContextV1Map
            : <Object>{},
        'seal': hasSeal ? tableUIPersonalitySealV1Map : <Object>{},
        'spec': hasSpec ? tableAdaptivePersonaSpecV1Map : <Object>{},
        'fusion': hasFusion ? tableFusionPersonaV1Map : <Object>{},
        'hints': hasHints ? tableHintMapV1 : <Object>{},
        'persona_output': hasPersonaOutput ? personaOutput : <Object>{},
        'persona_hints': hasPersonaHints ? personaHints : <Object>{},
        'envelope_ready': envelopeReady,
        'missing': missing,
      },
      'ready': envelopeReady,
    };
  }
}
