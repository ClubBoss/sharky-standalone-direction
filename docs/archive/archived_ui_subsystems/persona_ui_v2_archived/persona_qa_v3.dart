import 'persona_snapshot_binder_v3.dart';

class PersonaQAV3 {
  PersonaQAV3({PersonaSnapshotBinderV3? binder})
    : binder = binder ?? PersonaSnapshotBinderV3();

  final PersonaSnapshotBinderV3 binder;
  final Map<String, dynamic> baseline = {};
  Map<String, dynamic> lastSnapshot = {};

  void addSnapshotBaseline(Map<String, dynamic> b) {
    baseline
      ..clear()
      ..addAll(b);
  }

  void ingestSnapshot(Map<String, dynamic> snapshot) {
    lastSnapshot = snapshot;
  }

  String runQA() {
    binder.buildSnapshot();
    if (baseline.isEmpty) return 'Persona QA Report\nNO BASELINE';
    final diff = binder.compareSnapshot(baseline);
    final buffer = StringBuffer('Persona QA Report');
    diff.forEach((key, status) {
      buffer.writeln();
      buffer.write('$key: $status');
    });
    return buffer.toString();
  }

  String runPersonaQABlock() {
    final report = runQA();
    return '=== PERSONA QA REPORT ===\n$report';
  }
}
