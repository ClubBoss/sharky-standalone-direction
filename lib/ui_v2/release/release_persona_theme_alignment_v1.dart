class ReleasePersonaThemeAlignmentV1 {
  const ReleasePersonaThemeAlignmentV1({
    required this.personaProfileMap,
    required this.themeTokenMap,
    required this.v4ReadinessMap,
    required this.stabilityMap,
  });

  final Map<String, Object?> personaProfileMap;
  final Map<String, Object?> themeTokenMap;
  final Map<String, Object> v4ReadinessMap;
  final Map<String, Object> stabilityMap;

  Map<String, Object> asReadOnlyMap() {
    final String personaMood = _stringValue(personaProfileMap['persona_mood']);
    final String preferredTheme = _stringValue(
      personaProfileMap['preferred_theme_family'],
    );
    final String activeTheme = _stringValue(
      themeTokenMap['active_theme_family'],
    );
    final bool v4Ready = _boolFlag(v4ReadinessMap, 'v4_ready');
    final bool aligned =
        !v4Ready ||
        (preferredTheme.isNotEmpty && preferredTheme == activeTheme);
    final String mismatchReason;
    if (!v4Ready) {
      mismatchReason = '';
    } else if (preferredTheme.isEmpty || activeTheme.isEmpty) {
      mismatchReason = 'insufficient_theme_family';
    } else if (!aligned) {
      mismatchReason = 'preferred_theme_mismatch';
    } else {
      mismatchReason = '';
    }
    final bool stabilityReady = _boolFlag(stabilityMap, 'ready');
    final bool ready =
        personaProfileMap.isNotEmpty &&
        themeTokenMap.isNotEmpty &&
        stabilityReady;
    return <String, Object>{
      'persona_theme_alignment_v1': <String, Object>{
        'persona_mood': personaMood,
        'preferred_theme_family': preferredTheme,
        'active_theme_family': activeTheme,
        'aligned': aligned,
        'mismatch_reason': mismatchReason,
      },
      'ready': ready,
    };
  }

  static String _stringValue(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is num) {
      return value.toString();
    }
    if (value is Map) {
      final String candidate = _stringValue(value['value']);
      if (candidate.isNotEmpty) {
        return candidate;
      }
      final String fallback = _stringValue(value['family']);
      if (fallback.isNotEmpty) {
        return fallback;
      }
      final String fallback2 = _stringValue(value['theme']);
      if (fallback2.isNotEmpty) {
        return fallback2;
      }
    }
    return '';
  }

  static bool _boolFlag(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
