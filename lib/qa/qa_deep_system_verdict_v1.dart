class QADeepSystemVerdictV1 {
  const QADeepSystemVerdictV1(
    this.systemQACrownV1Map,
    this.qaCompletionSealV1Map,
    this.visualIntegrityVerdictV1Map,
    this.stabilitySnapshotV1Map,
    this.compositeIntegrityGateV1Map,
    this.deterministicSmokeHarnessV1Map,
    this.behaviorPersonaReflectionQAV1Map,
    this.tableUIStabilitySealV1Map,
  );

  final Object systemQACrownV1Map;
  final Object qaCompletionSealV1Map;
  final Object visualIntegrityVerdictV1Map;
  final Object stabilitySnapshotV1Map;
  final Object compositeIntegrityGateV1Map;
  final Object deterministicSmokeHarnessV1Map;
  final Object behaviorPersonaReflectionQAV1Map;
  final Object tableUIStabilitySealV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> systemCrown = m(systemQACrownV1Map);
    final Map<String, Object> qaCompletion = m(qaCompletionSealV1Map);
    final Map<String, Object> visual = m(visualIntegrityVerdictV1Map);
    final Map<String, Object> stability = m(stabilitySnapshotV1Map);
    final Map<String, Object> integrity = m(compositeIntegrityGateV1Map);
    final Map<String, Object> smoke = m(deterministicSmokeHarnessV1Map);
    final Map<String, Object> behaviorPersona = m(
      behaviorPersonaReflectionQAV1Map,
    );
    final Map<String, Object> uiStability = m(tableUIStabilitySealV1Map);
    final Map<String, Object> domains = <String, Object>{
      'system_crown': systemCrown,
      'qa_completion': qaCompletion,
      'visual_verdict': visual,
      'stability_snapshot': stability,
      'integrity_gate': integrity,
      'smoke': smoke,
      'behavior_persona': behaviorPersona,
      'ui_stability': uiStability,
    };
    final List<String> missing = <String>[
      if (systemCrown.isEmpty) 'system_qa_crown_v1',
      if (qaCompletion.isEmpty) 'qa_completion_seal_v1',
      if (visual.isEmpty) 'visual_integrity_verdict_v1',
      if (stability.isEmpty) 'stability_snapshot_v1',
      if (integrity.isEmpty) 'composite_integrity_gate_v1',
      if (smoke.isEmpty) 'deterministic_smoke_harness_v1',
      if (behaviorPersona.isEmpty) 'behavior_persona_reflection_qa_v1',
      if (uiStability.isEmpty) 'table_ui_stability_seal_v1',
    ];
    final List<String> invalid = <String>[];
    final bool deepReady =
        ready(systemCrown) &&
        ready(qaCompletion) &&
        ready(visual) &&
        ready(stability) &&
        ready(integrity) &&
        ready(smoke) &&
        ready(behaviorPersona) &&
        ready(uiStability);
    return <String, Object>{
      'qa_deep_system_verdict_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'invalid': invalid,
        'deep_ready': deepReady,
      },
      'readiness': deepReady,
    };
  }
}
