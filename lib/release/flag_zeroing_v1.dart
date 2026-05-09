class FlagZeroingV1 {
  const FlagZeroingV1();

  static Map<String, Object?> zero({
    required Map<String, Object?> domainFlags,
    required Map<String, Object?> personaFlags,
  }) {
    return {
      "present": true,
      "stage": "flag_zeroing_v1",
      "domain_flags_seen": domainFlags.keys.toList(),
      "persona_flags_seen": personaFlags.keys.toList(),
      "all_zero": false,
    };
  }
}
