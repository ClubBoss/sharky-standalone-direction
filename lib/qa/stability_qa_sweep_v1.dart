/// Passive stability QA sweep v1.
class StabilityQASweepV1 {
  const StabilityQASweepV1({
    required this.activationFrame,
    required this.activationSync,
    required this.materialization,
    required this.runtimeQA,
    required this.runtimeBundle,
  });

  final Map<String, Object> activationFrame;
  final Map<String, Object> activationSync;
  final Map<String, Object> materialization;
  final Map<String, Object> runtimeQA;
  final Map<String, Object> runtimeBundle;

  Map<String, Object> run() {
    final bool hasActivationFrame = activationFrame.isNotEmpty;
    final bool hasSync = activationSync.isNotEmpty;
    final bool hasMaterialization = materialization.isNotEmpty;
    final bool hasRuntimeQA = runtimeQA.isNotEmpty;
    final bool hasBundle = runtimeBundle.isNotEmpty;

    final List<String> missingSections = <String>[];
    if (!hasActivationFrame) missingSections.add('activation_frame');
    if (!hasSync) missingSections.add('sync');
    if (!hasMaterialization) missingSections.add('materialization');
    if (!hasRuntimeQA) missingSections.add('runtime_qa');
    if (!hasBundle) missingSections.add('bundle');

    final List<String> emptyKeys = <String>[];
    void checkEmpty(Map<String, Object> map, String prefix) {
      map.forEach((key, value) {
        if (value is Map && value.isEmpty) {
          emptyKeys.add('$prefix.$key');
        } else if (value is Iterable && value.isEmpty) {
          emptyKeys.add('$prefix.$key');
        } else if (value is String && value.isEmpty) {
          emptyKeys.add('$prefix.$key');
        }
      });
    }

    checkEmpty(activationFrame, 'activation_frame');
    checkEmpty(activationSync, 'sync');
    checkEmpty(materialization, 'materialization');
    checkEmpty(runtimeQA, 'runtime_qa');
    checkEmpty(runtimeBundle, 'bundle');

    final bool qaReady =
        hasActivationFrame &&
        hasSync &&
        hasMaterialization &&
        hasRuntimeQA &&
        hasBundle &&
        emptyKeys.isEmpty &&
        missingSections.isEmpty;

    return <String, Object>{
      'has_activation_frame': hasActivationFrame,
      'has_sync': hasSync,
      'has_materialization': hasMaterialization,
      'has_runtime_qa': hasRuntimeQA,
      'has_bundle': hasBundle,
      'empty_keys': emptyKeys,
      'missing_sections': missingSections,
      'qa_ready': qaReady,
    };
  }
}
