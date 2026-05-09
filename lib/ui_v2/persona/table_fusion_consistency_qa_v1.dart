/// Passive table fusion consistency QA V1 (Phi-74.4).
class TableFusionConsistencyQAV1 {
  const TableFusionConsistencyQAV1(
    this.tableAdaptivePersonaSpecV1Map,
    this.tableFusionPersonaV1Map,
    this.tableHintMapV1,
    this.personaOutput,
    this.personaHints,
  );

  final Object tableAdaptivePersonaSpecV1Map;
  final Object tableFusionPersonaV1Map;
  final Object tableHintMapV1;
  final Object personaOutput;
  final Object personaHints;

  Map<String, Object> asReadOnlyMap() {
    final List<String> missing = <String>[];
    bool _ok(Object o, String label) {
      final ok = o is Map && (o as Map).isNotEmpty;
      if (!ok) missing.add(label);
      return ok;
    }

    _ok(tableAdaptivePersonaSpecV1Map, 'spec');
    _ok(tableFusionPersonaV1Map, 'fusion');
    _ok(tableHintMapV1, 'hints');
    _ok(personaOutput, 'persona_output');
    _ok(personaHints, 'persona_hints');

    final List<String> conflicts = <String>[];
    final bool consistencyReady = missing.isEmpty && conflicts.isEmpty;
    return <String, Object>{
      'table_fusion_consistency_qa_v1': <String, Object>{
        'inputs': <String, Object>{
          'spec': tableAdaptivePersonaSpecV1Map,
          'fusion': tableFusionPersonaV1Map,
          'hints': tableHintMapV1,
          'persona_output': personaOutput,
          'persona_hints': personaHints,
        },
        'consistency_ready': consistencyReady,
        'missing': missing,
        'conflicts': conflicts,
      },
      'ready': consistencyReady,
    };
  }
}
