class V4FusionHealthSampler {
  const V4FusionHealthSampler();

  static Map<String, Object?> sample(
    Map<String, Object?>? onboardingTransitions,
  ) {
    if (onboardingTransitions == null ||
        onboardingTransitions["present"] != true) {
      return const {"present": false};
    }

    return {
      "present": true,
      "health_routing_ready": onboardingTransitions["onboarding_routing_ready"],
      "health_theme_ready": onboardingTransitions["onboarding_theme_ready"],
      "fusion_health_sampler_stage": 1,
    };
  }
}
