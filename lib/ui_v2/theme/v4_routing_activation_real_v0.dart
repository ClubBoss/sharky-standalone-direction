import 'v4_runtime_context.dart';

class V4RoutingActivationRealV0 {
  const V4RoutingActivationRealV0();

  static Map<String, Object?> activate(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "activate_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "activate_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "activate_spacing": readiness["struct_spacing"] != null,
      "activate_motion": runtime["motion"] != null,
      "activate_elevation": runtime["elevation"] != null,
      "activation_stage": 0,
    };
  }
}
