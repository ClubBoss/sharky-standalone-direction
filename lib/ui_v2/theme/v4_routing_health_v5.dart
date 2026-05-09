import 'v4_runtime_context.dart';

class V4RoutingHealthV5 {
  const V4RoutingHealthV5();

  static Map<String, Object?> check(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;
    final rd = ctx.readiness;

    return {
      "present": true,
      "health_colors": r["primary"] != null && r["secondary"] != null,
      "health_typography":
          rd["struct_typography_scale_body"] != null &&
          rd["struct_typography_scale_title"] != null,
      "health_spacing": rd["struct_spacing"] != null,
      "health_motion": r["motion"] != null,
      "health_elevation": r["elevation"] != null,
      "routing_health_stage": 5,
    };
  }
}
