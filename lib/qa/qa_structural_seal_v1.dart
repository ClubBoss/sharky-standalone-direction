class QAStructuralSealV1 {
  const QAStructuralSealV1(
    this.qaDeepSystemVerdictV1Map,
    this.systemQACrownV1Map,
    this.qaCompletionSealV1Map,
    this.compositeIntegrityGateV1Map,
    this.stabilitySnapshotV1Map,
    this.behaviorPersonaReflectionQAV1Map,
    this.deterministicSmokeHarnessV1Map,
    this.visualIntegrityVerdictV1Map,
  );

  final Object qaDeepSystemVerdictV1Map;
  final Object systemQACrownV1Map;
  final Object qaCompletionSealV1Map;
  final Object compositeIntegrityGateV1Map;
  final Object stabilitySnapshotV1Map;
  final Object behaviorPersonaReflectionQAV1Map;
  final Object deterministicSmokeHarnessV1Map;
  final Object visualIntegrityVerdictV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> deepVerdict = m(qaDeepSystemVerdictV1Map);
    final Map<String, Object> systemCrown = m(systemQACrownV1Map);
    final Map<String, Object> completion = m(qaCompletionSealV1Map);
    final Map<String, Object> integrity = m(compositeIntegrityGateV1Map);
    final Map<String, Object> stability = m(stabilitySnapshotV1Map);
    final Map<String, Object> behaviorPersona = m(
      behaviorPersonaReflectionQAV1Map,
    );
    final Map<String, Object> smoke = m(deterministicSmokeHarnessV1Map);
    final Map<String, Object> visual = m(visualIntegrityVerdictV1Map);
    final Map<String, Object> domains = <String, Object>{
      'deep_verdict': deepVerdict,
      'system_crown': systemCrown,
      'completion': completion,
      'integrity': integrity,
      'stability': stability,
      'behavior_persona': behaviorPersona,
      'smoke': smoke,
      'visual': visual,
    };
    final List<String> missing = <String>[
      if (deepVerdict.isEmpty) 'qa_deep_system_verdict_v1',
      if (systemCrown.isEmpty) 'system_qa_crown_v1',
      if (completion.isEmpty) 'qa_completion_seal_v1',
      if (integrity.isEmpty) 'composite_integrity_gate_v1',
      if (stability.isEmpty) 'stability_snapshot_v1',
      if (behaviorPersona.isEmpty) 'behavior_persona_reflection_qa_v1',
      if (smoke.isEmpty) 'deterministic_smoke_harness_v1',
      if (visual.isEmpty) 'visual_integrity_verdict_v1',
    ];
    final bool readyFlag =
        ready(deepVerdict) &&
        ready(systemCrown) &&
        ready(completion) &&
        ready(integrity) &&
        ready(stability) &&
        ready(behaviorPersona) &&
        ready(smoke) &&
        ready(visual);
    return <String, Object>{
      'qa_structural_seal_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'seal_ready': readyFlag,
      },
      'readiness': readyFlag,
    };
  }
}
