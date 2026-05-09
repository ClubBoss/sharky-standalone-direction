class QACompletionSealV1 {
  const QACompletionSealV1(
    this.readinessPropagationAuditorMap,
    this.stabilitySnapshotMap,
    this.compositeIntegrityGateMap,
    this.behaviorPersonaReflectionQAMap,
    this.deterministicSmokeHarnessMap,
    this.visualIntegrityVerdictMap,
  );

  final Object readinessPropagationAuditorMap;
  final Object stabilitySnapshotMap;
  final Object compositeIntegrityGateMap;
  final Object behaviorPersonaReflectionQAMap;
  final Object deterministicSmokeHarnessMap;
  final Object visualIntegrityVerdictMap;

  Map<String, Object> asReadOnlyMap() {
    bool ok(Object m, String key) => m is Map && m[key] == true && m.isNotEmpty;
    final bool readinessOk = ok(readinessPropagationAuditorMap, 'readiness');
    final bool stabilityOk = ok(stabilitySnapshotMap, 'readiness');
    final bool integrityOk = ok(compositeIntegrityGateMap, 'readiness');
    final bool reflectionOk = ok(behaviorPersonaReflectionQAMap, 'readiness');
    final bool smokeOk = ok(deterministicSmokeHarnessMap, 'readiness');
    final bool visualOk = ok(visualIntegrityVerdictMap, 'readiness');
    final List<String> missing = <String>[
      if (!readinessOk) 'readiness_propagation',
      if (!stabilityOk) 'stability_snapshot',
      if (!integrityOk) 'composite_integrity',
      if (!reflectionOk) 'behavior_persona_reflection',
      if (!smokeOk) 'deterministic_smoke',
      if (!visualOk) 'visual_integrity',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'qa_completion_seal_v1': <String, Object>{
        'summary': <String, Object>{
          'readiness_propagation_ok': readinessOk,
          'stability_ok': stabilityOk,
          'integrity_ok': integrityOk,
          'reflection_ok': reflectionOk,
          'smoke_ok': smokeOk,
          'visual_ok': visualOk,
        },
        'qa_ready': ready,
        'missing': missing,
      },
      'readiness': ready,
    };
  }
}
