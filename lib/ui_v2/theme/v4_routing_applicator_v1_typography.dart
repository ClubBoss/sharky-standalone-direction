import 'v4_runtime_context.dart';

class V4RoutingApplicatorV1Typography {
  const V4RoutingApplicatorV1Typography();

  static Map<String, Object?> apply(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final rd = ctx.readiness;

    return {
      "present": true,
      "typography_plan_body": rd["struct_typography_scale_body"] ?? null,
      "typography_plan_title": rd["struct_typography_scale_title"] ?? null,
      "routing_v1_typography_stage": 1,
    };
  }
}
