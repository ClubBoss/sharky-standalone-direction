import 'v4_runtime_context.dart';

class V4RoutingPreflight {
  const V4RoutingPreflight();

  static Map<String, Object?> preflight(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "preflight_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "preflight_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "preflight_spacing": readiness["struct_spacing"] != null,
      "preflight_motion": runtime["motion"] != null,
      "preflight_elevation": runtime["elevation"] != null,
      "preflight_stage": 0,
    };
  }
}
