class V4RoutingHealthV6 {
  const V4RoutingHealthV6();

  static Map<String, Object?> check(Map<String, Object?>? synthesisV2) {
    if (synthesisV2 == null || synthesisV2["present"] == false) {
      return const {"present": false};
    }

    return {
      "present": true,
      "health_v6_colors": synthesisV2["synthesis_v2_colors"] != null,
      "health_v6_typography": synthesisV2["synthesis_v2_typography"] != null,
      "health_v6_spacing": synthesisV2["synthesis_v2_spacing"] != null,
      "health_v6_motion": synthesisV2["synthesis_v2_motion"] != null,
      "health_v6_elevation": synthesisV2["synthesis_v2_elevation"] != null,
      "routing_health_stage": 6,
    };
  }
}
