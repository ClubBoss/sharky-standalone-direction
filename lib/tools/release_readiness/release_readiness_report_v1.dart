Map<String, Object> buildReleaseReadinessReportV1(
  Map<String, bool> domainStatus,
) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  final keys = domainStatus.keys.toList()..sort();
  if (keys.isEmpty || keys.any((k) => !_isAscii(k))) {
    return const <String, Object>{
      'ok': false,
      'domains': <String, Object>{},
      'missing': <String>[],
      'drivers': <String>['release_readiness_safe_fallback'],
      'strict_findings': <String, Object>{'missing': <String>[]},
      'readiness_score': 0,
    };
  }

  final domains = <String, bool>{};
  final missing = <String>[];
  for (final key in keys) {
    final value = domainStatus[key] == true;
    domains[key] = value;
    if (!value) missing.add(key);
  }

  missing.sort();
  final drivers = missing.isEmpty
      ? const <String>[]
      : List<String>.unmodifiable(missing.toList());
  final ok = missing.isEmpty;
  final readinessScore =
      ((domains.values.where((v) => v).length / domains.length) * 100).floor();

  return Map<String, Object>.unmodifiable(<String, Object>{
    'ok': ok,
    'domains': Map<String, Object>.unmodifiable(domains),
    'missing': List<String>.unmodifiable(missing),
    'drivers': drivers,
    'strict_findings': <String, Object>{
      'missing': List<String>.unmodifiable(missing),
    },
    'readiness_score': readinessScore,
  });
}
