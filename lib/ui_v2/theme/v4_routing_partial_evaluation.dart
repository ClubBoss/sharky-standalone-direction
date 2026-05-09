import 'v4_runtime_context.dart';

class V4RoutingPartialEvaluation {
  const V4RoutingPartialEvaluation();

  static Map<String, Object?> evaluate(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "can_route_colors":
          readiness["struct_colors"] != null && runtime["primary"] != null,
      "can_route_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "can_route_spacing": readiness["struct_spacing"] != null,
      "can_route_motion": runtime["motion"] != null,
      "can_route_elevation": runtime["elevation"] != null,
      "routing_eval_stage": 1,
    };
  }
}
