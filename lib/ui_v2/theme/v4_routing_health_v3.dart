import 'v4_runtime_context.dart';

class V4RoutingHealthV3 {
  const V4RoutingHealthV3();

  static Map<String, Object?> check(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "healthy_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "healthy_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "healthy_spacing": readiness["struct_spacing"] != null,
      "healthy_motion": runtime["motion"] != null,
      "healthy_elevation": runtime["elevation"] != null,
      "health_stage": 3,
    };
  }
}
