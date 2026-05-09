/// Passive binder for Tap-to-Explain v1.
class T2EBinderV1 {
  const T2EBinderV1({
    required this.parsedExplanations,
    required this.parsedDrills,
    required this.parsedDemos,
  });

  final List<Map<String, Object>> parsedExplanations;
  final List<Map<String, Object>> parsedDrills;
  final List<Map<String, Object>> parsedDemos;

  Map<String, Object> analyzeBindings() {
    final Set<Object?> drillIds = parsedDrills
        .map<Object?>((e) => e['id'])
        .toSet();
    final Set<Object?> demoIds = parsedDemos
        .map<Object?>((e) => e['id'])
        .toSet();

    bool refsOk(Set<Object?> allowed, String key) {
      for (final Map<String, Object> exp in parsedExplanations) {
        final Object? ref = exp[key];
        if (ref != null && !allowed.contains(ref)) return false;
      }
      return true;
    }

    final List<String> dangling = <String>[];
    for (final Map<String, Object> exp in parsedExplanations) {
      final Object? id = exp['id'];
      final Object? drillId = exp['drill_id'];
      final Object? demoId = exp['demo_id'];
      final bool drillMissing = drillId != null && !drillIds.contains(drillId);
      final bool demoMissing = demoId != null && !demoIds.contains(demoId);
      if ((drillMissing || demoMissing) && id is String) {
        dangling.add(id);
      }
    }

    return <String, Object>{
      'explanation_count': parsedExplanations.length,
      'drill_refs_ok': refsOk(drillIds, 'drill_id'),
      'demo_refs_ok': refsOk(demoIds, 'demo_id'),
      'dangling_refs': dangling,
    };
  }
}
