import 'v4_runtime_context.dart';

class V4RoutingApplicatorV1Color {
  const V4RoutingApplicatorV1Color();

  static Map<String, Object?> apply(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;
    final rd = ctx.readiness;

    return {
      "present": true,
      "color_plan_primary": rd["struct_colors"] != null ? r["primary"] : null,
      "color_plan_secondary": rd["struct_colors"] != null
          ? r["secondary"]
          : null,
      "routing_v1_color_stage": 1,
    };
  }
}
