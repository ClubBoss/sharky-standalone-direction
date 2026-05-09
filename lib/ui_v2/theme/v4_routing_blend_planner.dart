import 'v4_runtime_context.dart';

class V4RoutingBlendPlanner {
  const V4RoutingBlendPlanner();

  static Map<String, Object?> plan(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "blend_colors":
          readiness["struct_colors"] != null && runtime["primary"] != null,
      "blend_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "blend_spacing": readiness["struct_spacing"] != null,
      "blend_motion": runtime["motion"] != null,
      "blend_elevation": runtime["elevation"] != null,
      "blend_stage": 1,
    };
  }
}
