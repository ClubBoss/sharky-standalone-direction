import 'v4_runtime_context.dart';

class V4RoutingHealthV4 {
  const V4RoutingHealthV4();

  static Map<String, Object?> check(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "health_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "health_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "health_spacing": readiness["struct_spacing"] != null,
      "health_motion": runtime["motion"] != null,
      "health_elevation": runtime["elevation"] != null,
      "health_stage": 4,
    };
  }
}
