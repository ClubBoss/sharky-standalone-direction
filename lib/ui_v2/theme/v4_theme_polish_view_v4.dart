class V4ThemePolishViewV4 {
  Map<String, Object> buildV4PolishView(
    Map<String, Object?> normalizedTokens,
    Map<String, Object?> cohesionReport,
    Map<String, Object?> polishBundle,
  ) {
    bool asciiOk = true;
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    List<String> _asciiList(Object? value) {
      if (value is! Iterable) return const <String>[];
      final out = <String>[];
      for (final v in value) {
        final s = v.toString();
        if (_isAscii(s)) {
          out.add(s);
        } else {
          asciiOk = false;
        }
      }
      out.sort();
      return out;
    }

    final polishTokens = <String, Object>{};
    Object _numOrDefault(Object? v) {
      if (v is num) return v.toDouble();
      return 0;
    }

    final polishKeyList = [
      'v4FinalRadius',
      'v4FinalPadding',
      'v4FinalShadow',
      'v4FinalAccentColor',
      'v4FinalSurfaceColor',
    ];
    for (final key in polishKeyList) {
      final value = polishBundle[key] ?? normalizedTokens[key];
      if (value is num) {
        polishTokens[key] = (value).toDouble();
      } else if (value is String && _isAscii(value)) {
        polishTokens[key] = value;
      }
    }

    final tokenKeys =
        normalizedTokens.keys.map((e) => e.toString()).where(_isAscii).toList()
          ..sort();
    final polishKeys =
        polishBundle.keys.map((e) => e.toString()).where(_isAscii).toList()
          ..sort();

    final missingPolish = <String>[];
    for (final key in tokenKeys) {
      if (!polishKeys.contains(key) && key.startsWith('polish')) {
        missingPolish.add(key);
      }
    }

    final mismatched = <String>[];
    for (final key in polishKeys) {
      if (!tokenKeys.contains(key) && key.startsWith('polish')) {
        mismatched.add(key);
      }
    }

    final surfaceFlags = <String>[
      ..._asciiList(
        cohesionReport['missing_tokens'],
      ).map((e) => 'cohesion_missing:$e'),
      ..._asciiList(
        cohesionReport['mismatched_tokens'],
      ).map((e) => 'cohesion_mismatch:$e'),
    ]..sort();

    final drivers = _asciiList(polishBundle['drivers']);

    if (!asciiOk) return _fallback();

    final ok =
        missingPolish.isEmpty &&
        mismatched.isEmpty &&
        surfaceFlags.isEmpty &&
        drivers.isEmpty;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'final_polish_ready': ok && asciiOk,
      'missing_polish': List<String>.unmodifiable(missingPolish..sort()),
      'token_polish_mismatch': List<String>.unmodifiable(mismatched..sort()),
      'surface_polish_flags': List<String>.unmodifiable(surfaceFlags..sort()),
      'drivers': List<String>.unmodifiable(drivers),
      'polish_tokens': Map<String, Object>.unmodifiable(
        Map.fromEntries(
          polishTokens.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        ),
      ),
    });
  }

  Map<String, Object> _fallback() => const <String, Object>{
    'ok': false,
    'final_polish_ready': false,
    'missing_polish': <String>[],
    'token_polish_mismatch': <String>[],
    'surface_polish_flags': <String>[],
    'drivers': <String>['v4_polish_view_safe_fallback'],
    'polish_tokens': <String, Object>{},
  };
}
