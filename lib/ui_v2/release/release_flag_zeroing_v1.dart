class ReleaseFlagZeroingV1 {
  const ReleaseFlagZeroingV1(this.rawFlags);

  final Map<String, Object?> rawFlags;

  Map<String, Object> asReadOnlyMap() {
    final bool v4Active = _normalizedBool(rawFlags['v4_active']);
    final bool v3Fallback = _normalizedBool(rawFlags['v3_fallback']);
    final bool personaEnabled = _normalizedBool(rawFlags['persona_enabled']);
    final bool themeV4Enabled = _normalizedBool(rawFlags['theme_v4_enabled']);
    final bool packEngineReady = _normalizedBool(rawFlags['pack_engine_ready']);
    final bool tableV4Ready = _normalizedBool(rawFlags['table_v4_ready']);
    final bool releaseReady =
        v4Active &&
        v3Fallback &&
        personaEnabled &&
        themeV4Enabled &&
        packEngineReady &&
        tableV4Ready;
    return <String, Object>{
      'v4_active': v4Active,
      'v3_fallback': v3Fallback,
      'persona_enabled': personaEnabled,
      'theme_v4_enabled': themeV4Enabled,
      'pack_engine_ready': packEngineReady,
      'table_v4_ready': tableV4Ready,
      'release_ready': releaseReady,
    };
  }

  static bool _normalizedBool(Object? input) {
    if (input is bool) {
      return input;
    }
    if (input is num) {
      return input != 0;
    }
    if (input is String) {
      final String normalized = input.toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
    }
    return false;
  }
}
