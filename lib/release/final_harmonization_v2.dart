class FinalHarmonizationV2 {
  const FinalHarmonizationV2();

  static Map<String, Object?> check({
    required Map<String, Object?> scores,
    required Map<String, Object?> flags,
  }) {
    return {
      "present": true,
      "stage": "harmonization_v2",
      "scores_seen": scores.keys.toList(),
      "flags_seen": flags.keys.toList(),
      "harmonized": false,
    };
  }
}
