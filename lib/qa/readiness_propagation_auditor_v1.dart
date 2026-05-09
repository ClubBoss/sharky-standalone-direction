class ReadinessPropagationAuditorV1 {
  const ReadinessPropagationAuditorV1(this.fullCompositeMap);

  final Map<String, Object> fullCompositeMap;

  Map<String, Object> asReadOnlyMap() {
    final List<String> readyKeys =
        fullCompositeMap.keys
            .where(
              (key) => key.endsWith('_ready') || key.endsWith('_ready_flag'),
            )
            .toList()
          ..sort();
    final Map<String, bool> readyFlags = <String, bool>{};
    final List<String> issues = <String>[];
    for (final String key in readyKeys) {
      final bool flag = fullCompositeMap[key] == true;
      readyFlags[key] = flag;
      final String base = key.endsWith('_ready_flag')
          ? key.substring(0, key.length - '_ready_flag'.length)
          : key.substring(0, key.length - '_ready'.length);
      final Object? sub = fullCompositeMap[base];
      final bool hasSub = sub is Map && sub.isNotEmpty;
      if (flag && !hasSub) issues.add('$key true but $base missing');
      if (!flag && hasSub) issues.add('$key false but $base present');
    }
    final bool ok = issues.isEmpty;
    return <String, Object>{
      'readiness_propagation_auditor_v1': <String, Object>{
        'issues': issues,
        'ready_flags': readyFlags,
        'propagation_ok': ok,
      },
    };
  }
}
