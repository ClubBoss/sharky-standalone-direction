class QAReleaseSummaryV1 {
  const QAReleaseSummaryV1(
    this.qaSystemVerdictV1Map,
    this.qaStructuralSealV1Map,
    this.qaDeepSystemVerdictV1Map,
    this.systemQACrownV1Map,
    this.qaCompletionSealV1Map,
    this.compositeIntegrityGateV1Map,
    this.stabilitySnapshotV1Map,
    this.behaviorPersonaReflectionQAV1Map,
    this.deterministicSmokeHarnessV1Map,
    this.visualIntegrityVerdictV1Map,
  );

  final Object qaSystemVerdictV1Map;
  final Object qaStructuralSealV1Map;
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
    final Map<String, Object> systemVerdict = m(qaSystemVerdictV1Map);
    final Map<String, Object> structural = m(qaStructuralSealV1Map);
    final Map<String, Object> deep = m(qaDeepSystemVerdictV1Map);
    final Map<String, Object> crown = m(systemQACrownV1Map);
    final Map<String, Object> completion = m(qaCompletionSealV1Map);
    final Map<String, Object> integrity = m(compositeIntegrityGateV1Map);
    final Map<String, Object> stability = m(stabilitySnapshotV1Map);
    final Map<String, Object> behavior = m(behaviorPersonaReflectionQAV1Map);
    final Map<String, Object> smoke = m(deterministicSmokeHarnessV1Map);
    final Map<String, Object> visual = m(visualIntegrityVerdictV1Map);
    final Map<String, Object> domains = <String, Object>{
      'behavior_persona': behavior,
      'completion': completion,
      'crown': crown,
      'deep': deep,
      'integrity': integrity,
      'smoke': smoke,
      'stability': stability,
      'structural': structural,
      'system_verdict': systemVerdict,
      'visual': visual,
    };
    final List<String> missing = <String>[
      if (systemVerdict.isEmpty) 'qa_system_verdict_v1',
      if (structural.isEmpty) 'qa_structural_seal_v1',
      if (deep.isEmpty) 'qa_deep_system_verdict_v1',
      if (crown.isEmpty) 'system_qa_crown_v1',
      if (completion.isEmpty) 'qa_completion_seal_v1',
      if (integrity.isEmpty) 'composite_integrity_gate_v1',
      if (stability.isEmpty) 'stability_snapshot_v1',
      if (behavior.isEmpty) 'behavior_persona_reflection_qa_v1',
      if (smoke.isEmpty) 'deterministic_smoke_harness_v1',
      if (visual.isEmpty) 'visual_integrity_verdict_v1',
    ];
    final bool readyFlag =
        ready(systemVerdict) &&
        ready(structural) &&
        ready(deep) &&
        ready(crown) &&
        ready(completion) &&
        ready(integrity) &&
        ready(stability) &&
        ready(behavior) &&
        ready(smoke) &&
        ready(visual);
    return <String, Object>{
      'qa_release_summary_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'summary_ready': readyFlag,
      },
      'readiness': readyFlag,
    };
  }
}
