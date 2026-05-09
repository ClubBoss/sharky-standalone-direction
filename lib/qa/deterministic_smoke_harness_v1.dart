class DeterministicSmokeHarnessV1 {
  const DeterministicSmokeHarnessV1(
    this.fullCompositeExportFn,
    this.readinessAuditorFn,
    this.stabilitySnapshotFn,
    this.compositeIntegrityFn,
    this.reflectionQAFn,
  );

  final Object Function() fullCompositeExportFn;
  final Object Function() readinessAuditorFn;
  final Object Function() stabilitySnapshotFn;
  final Object Function() compositeIntegrityFn;
  final Object Function() reflectionQAFn;

  Map<String, Object> asReadOnlyMap() {
    Object call(Object Function() fn) => fn();
    final Object composite = call(fullCompositeExportFn);
    final Object auditor = call(readinessAuditorFn);
    final Object snapshot = call(stabilitySnapshotFn);
    final Object integrity = call(compositeIntegrityFn);
    final Object reflection = call(reflectionQAFn);
    final Map<String, Object> calls = <String, Object>{
      'full_composite': composite,
      'readiness_auditor': auditor,
      'stability_snapshot': snapshot,
      'composite_integrity': integrity,
      'reflection_qa': reflection,
    };
    final List<String> issues = <String>[];
    calls.forEach((key, value) {
      if (value is! Map) {
        issues.add('$key not a map');
      } else if (!value.containsKey('readiness')) {
        issues.add('$key missing readiness');
      } else if (value['readiness'] != true) {
        issues.add('$key readiness false');
      }
    });
    final bool ready = issues.isEmpty;
    return <String, Object>{
      'deterministic_smoke_harness_v1': <String, Object>{
        'calls': calls,
        'issues': issues,
        'smoke_ready': ready,
      },
      'readiness': ready,
    };
  }
}
