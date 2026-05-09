import 'v4_runtime_context.dart';

class V4RoutingStabilizationV2 {
  const V4RoutingStabilizationV2();

  static Map<String, Object?> stabilize(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "stable_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "stable_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "stable_spacing": readiness["struct_spacing"] != null,
      "stable_motion": runtime["motion"] != null,
      "stable_elevation": runtime["elevation"] != null,
      "stabilization_stage": 2,
    };
  }
}
