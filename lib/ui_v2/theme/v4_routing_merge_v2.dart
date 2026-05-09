class V4RoutingMergeV2 {
  const V4RoutingMergeV2();

  static Map<String, Object?> merge(Map<String, Object?>? synthesis) {
    if (synthesis == null || synthesis["present"] == false) {
      return const {"present": false};
    }

    final colors = synthesis["synthesis_colors"] as Map<String, Object?>?;
    final typo = synthesis["synthesis_typography"] as Map<String, Object?>?;
    final spacing = synthesis["synthesis_spacing"];
    final motion = synthesis["synthesis_motion"];
    final elev = synthesis["synthesis_elevation"];

    return {
      "present": true,
      "merged_v2_colors": colors != null
          ? {"primary": colors["primary"], "secondary": colors["secondary"]}
          : null,
      "merged_v2_typography": typo != null
          ? {"body": typo["body"], "title": typo["title"]}
          : null,
      "merged_v2_spacing": spacing,
      "merged_v2_motion": motion,
      "merged_v2_elevation": elev,
      "routing_merge_v2_stage": 2,
    };
  }
}
