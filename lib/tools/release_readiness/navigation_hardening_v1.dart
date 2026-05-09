Map<String, Object> buildNavigationHardeningV1(Map<String, Object?> routes) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  const fallback = <String, Object>{
    'ok': false,
    'issues': <String>[],
    'drivers': <String>['navigation_hardening_safe_fallback'],
  };

  if (routes.isEmpty || routes.keys.any((k) => !_isAscii(k.toString())))
    return fallback;

  final issues = <String>[];
  final keys = routes.keys.map((k) => k.toString()).toList()..sort();
  for (final key in keys) {
    final value = routes[key];
    if (value is! Map) {
      issues.add('route_missing_builder:$key');
      continue;
    }
    final mapValue = value.cast<Object?, Object?>();
    if (!mapValue.containsKey('builder')) {
      issues.add('route_missing_builder:$key');
      continue;
    }
    if (mapValue['builder'] != true) {
      issues.add('route_invalid_builder:$key');
    }
  }

  final ok = issues.isEmpty;
  issues.sort();
  final drivers = ok
      ? const <String>[]
      : List<String>.unmodifiable(List<String>.from(issues));

  return Map<String, Object>.unmodifiable(<String, Object>{
    'ok': ok,
    'issues': List<String>.unmodifiable(issues),
    'drivers': drivers,
  });
}
