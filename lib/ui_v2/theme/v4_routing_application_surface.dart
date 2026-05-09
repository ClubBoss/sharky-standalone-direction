import 'v4_runtime_context.dart';

class V4RoutingApplicationSurface {
  const V4RoutingApplicationSurface();

  static Map<String, Object?> surface(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "apply_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "apply_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "apply_spacing": readiness["struct_spacing"] != null,
      "apply_motion": runtime["motion"] != null,
      "apply_elevation": runtime["elevation"] != null,
      "application_stage": 1,
    };
  }
}
