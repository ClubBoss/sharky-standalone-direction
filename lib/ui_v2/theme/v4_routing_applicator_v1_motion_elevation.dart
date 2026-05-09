import 'v4_runtime_context.dart';

class V4RoutingApplicatorV1MotionElevation {
  const V4RoutingApplicatorV1MotionElevation();

  static Map<String, Object?> apply(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;

    return {
      "present": true,
      "motion_plan": r["motion"] ?? null,
      "elevation_plan": r["elevation"] ?? null,
      "routing_v1_motion_elevation_stage": 1,
    };
  }
}
