Map<String, Object> buildReleaseSmokePassV1({
  required Map<String, Object> firstPass,
  required Map<String, Object> secondPass,
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
    'release_smoke_pass_v1': false,
    'issues': <String>['release_smoke_pass_safe_fallback'],
    'drivers': <String>['release_smoke_pass_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  bool _validMap(Object? value) {
    if (value is! Map) return false;
    if ((value).isEmpty) return false;
    if (!(value).keys.every((k) => _isAscii(k.toString()))) return false;
    if (!(value).isEmpty && !_asciiMap(value)) return false;
    return true;
  }

  final issues = <String>[];
  final drivers = <String>[];

  final keys = <String>{...firstPass.keys.map((k) => k.toString())};
  keys.addAll(secondPass.keys.map((k) => k.toString()));

  for (final key in keys.toList()..sort()) {
    final first = firstPass[key];
    final second = secondPass[key];
    if (!_validMap(first)) {
      issues.add('${key}_invalid_first');
    }
    if (!_validMap(second)) {
      issues.add('${key}_invalid_second');
    }
    if (first is Map && second is Map) {
      final firstOrdered = Map.fromEntries(
        first.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      final secondOrdered = Map.fromEntries(
        second.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      if (firstOrdered.toString() != secondOrdered.toString()) {
        issues.add('${key}_unstable');
      }
      if (first.containsKey('error') || second.containsKey('error')) {
        issues.add('${key}_error');
      }
    }
    drivers.add(key);
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

  final snapshot = _orderMap(<String, Object>{
    'first_pass': firstPass,
    'second_pass': secondPass,
  });

  final smokeOk = issues.isEmpty;

  return <String, Object>{
    'release_smoke_pass_v1': smokeOk,
    'issues': List<String>.unmodifiable(issues..sort()),
    'drivers': List<String>.unmodifiable(drivers..sort()),
    'snapshot': snapshot,
  };
}
