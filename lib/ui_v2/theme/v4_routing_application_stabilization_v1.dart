import 'v4_runtime_context.dart';

class V4RoutingApplicationStabilizationV1 {
  const V4RoutingApplicationStabilizationV1();

  static Map<String, Object?> stabilize(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;
    final rd = ctx.readiness;

    return {
      "present": true,
      "stable_colors":
          rd["struct_colors"] != null &&
          r["primary"] != null &&
          r["secondary"] != null,
      "stable_typography":
          rd["struct_typography_scale_body"] != null &&
          rd["struct_typography_scale_title"] != null,
      "stable_spacing": rd["struct_spacing"] != null,
      "stable_motion": r["motion"] != null,
      "stable_elevation": r["elevation"] != null,
      "application_stabilization_stage": 1,
    };
  }
}
