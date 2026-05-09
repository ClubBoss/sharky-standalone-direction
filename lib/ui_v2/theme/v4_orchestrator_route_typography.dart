import 'v4_runtime_context.dart';

class V4OrchestratorRouteTypography {
  const V4OrchestratorRouteTypography();

  static Map<String, Object?> route(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;

    return {
      "present": true,
      "scale_body": readiness["struct_typography_scale_body"],
      "scale_title": readiness["struct_typography_scale_title"],
    };
  }
}
