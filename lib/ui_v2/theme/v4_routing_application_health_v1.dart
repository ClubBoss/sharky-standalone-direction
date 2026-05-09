import 'v4_runtime_context.dart';

class V4RoutingApplicationHealthV1 {
  const V4RoutingApplicationHealthV1();

  static Map<String, Object?> check(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;
    final rd = ctx.readiness;

    return {
      "present": true,
      "health_colors":
          rd["struct_colors"] != null &&
          r["primary"] != null &&
          r["secondary"] != null,
      "health_typography":
          rd["struct_typography_scale_body"] != null &&
          rd["struct_typography_scale_title"] != null,
      "health_spacing": rd["struct_spacing"] != null,
      "health_motion": r["motion"] != null,
      "health_elevation": r["elevation"] != null,
      "application_health_stage": 1,
    };
  }
}
