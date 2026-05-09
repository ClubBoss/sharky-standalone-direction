class AnimationRendererV1 {
  const AnimationRendererV1();

  static Map<String, Object?> stage({
    required Map<String, Object?> animationGroup,
  }) {
    return {
      "present": true,
      "stage": "animation_renderer_v1",
      "animation_ok": animationGroup.isNotEmpty,
      "animation_plan": {
        "rules": animationGroup["animation_rules"],
        "timings": animationGroup["timings"],
        "zones": animationGroup["zones"],
      },
      "animation_stage_ready": false,
    };
  }
}
