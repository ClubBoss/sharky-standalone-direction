import 'v4_runtime_context.dart';

class V4RoutingStabilizationV3 {
  const V4RoutingStabilizationV3();

  static Map<String, Object?> stabilize(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;
    final rd = ctx.readiness;

    return {
      "present": true,
      "stable_colors": r["primary"] != null && r["secondary"] != null,
      "stable_typography":
          rd["struct_typography_scale_body"] != null &&
          rd["struct_typography_scale_title"] != null,
      "stable_spacing": rd["struct_spacing"] != null,
      "stable_motion": r["motion"] != null,
      "stable_elevation": r["elevation"] != null,
      "routing_stabilization_stage": 3,
    };
  }
}
