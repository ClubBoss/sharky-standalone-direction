Map<String, Object> buildFinalSanitySurfaceV1({
  required Map<String, Object> pass1,
  required Map<String, Object> pass2,
}) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  bool _asciiMap(Map<dynamic, dynamic> m) {
    for (final entry in m.entries) {
      final key = entry.key.toString();
      if (!_isAscii(key)) return false;
      final v = entry.value;
      if (v is String && !_isAscii(v)) return false;
    }
    return true;
  }

  List<String> _asciiList(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      if (_isAscii(s)) out.add(s);
    }
    out.sort();
    return out;
  }

  const fallback = <String, Object>{
    'final_sanity_surface_v1': true,
    'sanity_ok': false,
    'issues': <String>['final_sanity_surface_safe_fallback'],
    'drivers': <String>['final_sanity_surface_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  bool _validMap(Object? value) {
    if (value is! Map) return false;
    final map = value;
    if (map.keys.any((k) => !_isAscii(k.toString()))) return false;
    if (!_asciiMap(map)) return false;
    return true;
  }

  Map<String, Object> _orderMap(Map<String, Object?> input) {
    final entries =
        input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final ordered = <String, Object>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value is Map) {
        ordered[entry.key] = _orderMap(value.cast<String, Object?>());
      } else if (value is Iterable) {
        final list = value.map<Object>((v) {
          if (v is Map) return _orderMap(v.cast<String, Object?>());
          if (v is num) return v.toDouble().clamp(0, 100);
          if (v is String && !_isAscii(v)) return '';
          return v as Object? ?? '';
        }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
        ordered[entry.key] = list;
      } else if (value is num) {
        ordered[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is String) {
        ordered[entry.key] = _isAscii(value) ? value : '';
      } else {
        ordered[entry.key] = value ?? '';
      }
    }
    return ordered;
  }

  final keys = <String>{...pass1.keys.map((k) => k.toString())};
  keys.addAll(pass2.keys.map((k) => k.toString()));

  final issues = <String>[];
  final drivers = <String>[];

  for (final key in keys.toList()..sort()) {
    final first = pass1[key];
    final second = pass2[key];
    if (!_validMap(first)) issues.add('${key}_invalid_first');
    if (!_validMap(second)) issues.add('${key}_invalid_second');
    if (first is Map && second is Map) {
      final orderedFirst = _orderMap(first.cast<String, Object?>());
      final orderedSecond = _orderMap(second.cast<String, Object?>());
      if (orderedFirst.toString() != orderedSecond.toString()) {
        issues.add('${key}_inconsistent');
      }
    }
    drivers.add(key);
  }

  final snapshot = _orderMap(<String, Object>{'pass1': pass1, 'pass2': pass2});

  final ok = issues.isEmpty;

  return <String, Object>{
    'final_sanity_surface_v1': true,
    'sanity_ok': ok,
    'issues': List<String>.unmodifiable(issues..sort()),
    'drivers': List<String>.unmodifiable(drivers..sort()),
    'snapshot': snapshot,
  };
}
