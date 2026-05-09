class InteractionRendererV1 {
  const InteractionRendererV1();

  static Map<String, Object?> stage({
    required Map<String, Object?> interactionGroup,
  }) {
    return {
      "present": true,
      "stage": "interaction_renderer_v1",
      "interaction_ok": interactionGroup.isNotEmpty,
      "interaction_plan": {
        "tap_zones": interactionGroup["tap_zones"],
        "gesture_rules": interactionGroup["gesture_rules"],
        "priority": interactionGroup["priority"],
      },
      "interaction_stage_ready": false,
    };
  }
}
