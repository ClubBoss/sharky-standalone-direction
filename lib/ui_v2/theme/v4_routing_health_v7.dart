class V4RoutingHealthV7 {
  const V4RoutingHealthV7();

  static Map<String, Object?> check(Map<String, Object?>? synthesisV3) {
    if (synthesisV3 == null || synthesisV3["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "health_v7_colors": synthesisV3["synthesis_v3_colors"] != null,
      "health_v7_typography": synthesisV3["synthesis_v3_typography"] != null,
      "health_v7_spacing": synthesisV3["synthesis_v3_spacing"] != null,
      "health_v7_motion": synthesisV3["synthesis_v3_motion"] != null,
      "health_v7_elevation": synthesisV3["synthesis_v3_elevation"] != null,
      "routing_health_stage": 7,
    };
  }
}
