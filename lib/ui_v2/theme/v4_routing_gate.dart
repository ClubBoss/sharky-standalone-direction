import 'v4_runtime_context.dart';

class V4RoutingGate {
  const V4RoutingGate();

  static Map<String, Object?> gate(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "allow_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "allow_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "allow_spacing": readiness["struct_spacing"] != null,
      "allow_motion": runtime["motion"] != null,
      "allow_elevation": runtime["elevation"] != null,
      "gate_stage": 1,
    };
  }
}
