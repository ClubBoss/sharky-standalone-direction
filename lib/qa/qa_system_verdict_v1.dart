class QASystemVerdictV1 {
  const QASystemVerdictV1(
    this.qaStructuralSealV1Map,
    this.qaDeepSystemVerdictV1Map,
    this.systemQACrownV1Map,
    this.qaCompletionSealV1Map,
    this.stabilitySnapshotV1Map,
  );

  final Object qaStructuralSealV1Map;
  final Object qaDeepSystemVerdictV1Map;
  final Object systemQACrownV1Map;
  final Object qaCompletionSealV1Map;
  final Object stabilitySnapshotV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> structural = m(qaStructuralSealV1Map);
    final Map<String, Object> deep = m(qaDeepSystemVerdictV1Map);
    final Map<String, Object> crown = m(systemQACrownV1Map);
    final Map<String, Object> completion = m(qaCompletionSealV1Map);
    final Map<String, Object> stability = m(stabilitySnapshotV1Map);
    final Map<String, Object> verdict = <String, Object>{
      'completion': completion,
      'crown': crown,
      'deep': deep,
      'stability': stability,
      'structural': structural,
    };
    final List<String> missing = <String>[
      if (structural.isEmpty) 'qa_structural_seal_v1',
      if (deep.isEmpty) 'qa_deep_system_verdict_v1',
      if (crown.isEmpty) 'system_qa_crown_v1',
      if (completion.isEmpty) 'qa_completion_seal_v1',
      if (stability.isEmpty) 'stability_snapshot_v1',
    ];
    final bool readyFlag =
        ready(structural) &&
        ready(deep) &&
        ready(crown) &&
        ready(completion) &&
        ready(stability);
    return <String, Object>{
      'qa_system_verdict_v1': <String, Object>{
        'verdict': verdict,
        'missing': missing,
        'verdict_ready': readyFlag,
      },
      'readiness': readyFlag,
    };
  }
}
