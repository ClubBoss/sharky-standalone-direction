class V4FusionOnboardingTransitions {
  const V4FusionOnboardingTransitions();

  static Map<String, Object?> build(Map<String, Object?>? tableThemeSeeds) {
    if (tableThemeSeeds == null || tableThemeSeeds["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "onboarding_routing_ready": tableThemeSeeds["table_routing_seed"],
      "onboarding_theme_ready": tableThemeSeeds["table_theme_seed"],
      "fusion_onboarding_transition_stage": 1,
    };
  }
}
