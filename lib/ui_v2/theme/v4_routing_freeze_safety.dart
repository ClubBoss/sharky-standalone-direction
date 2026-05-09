import 'v4_runtime_context.dart';

class V4RoutingFreezeSafety {
  const V4RoutingFreezeSafety();

  static Map<String, Object?> freeze(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "freeze_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "freeze_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "freeze_spacing": readiness["struct_spacing"] != null,
      "freeze_motion": runtime["motion"] != null,
      "freeze_elevation": runtime["elevation"] != null,
      "freeze_stage": 1,
    };
  }
}
