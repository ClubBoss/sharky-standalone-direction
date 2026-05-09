import 'v4_runtime_context.dart';

class V4RoutingOverrideLayer {
  const V4RoutingOverrideLayer();

  static Map<String, Object?> override(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "override_colors":
          readiness["struct_colors"] != null && runtime["primary"] != null,
      "override_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "override_spacing": readiness["struct_spacing"] != null,
      "override_motion": runtime["motion"] != null,
      "override_elevation": runtime["elevation"] != null,
      "override_stage": 1,
    };
  }
}
