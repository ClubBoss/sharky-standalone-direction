class ReleaseAssemblyHarmonizerV1 {
  const ReleaseAssemblyHarmonizerV1({
    required this.v2Snapshot,
    required this.v3Snapshot,
  });

  final Map<String, Object> v2Snapshot;
  final Map<String, Object> v3Snapshot;

  Map<String, Object> toReadOnlyMap() {
    final missing = <String>[];
    final requiredFields = <String>['package', 'version', 'artifacts'];
    for (final field in requiredFields) {
      if (!v2Snapshot.containsKey(field) || !v3Snapshot.containsKey(field)) {
        missing.add(field);
      }
    }
    final harmonizedOk = missing.isEmpty;
    final structDiff = harmonizedOk ? 'aligned' : 'pending_alignment';
    return Map<String, Object>.unmodifiable({
      'harmonized_ok': harmonizedOk,
      'missing_fields': List<String>.unmodifiable(missing),
      'struct_diff': structDiff,
    });
  }
}
