import 'v4_runtime_context.dart';

class V4OrchestratorPartialRouting {
  const V4OrchestratorPartialRouting();

  static Map<String, Object?> route(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;

    return {
      "present": true,
      "route_color_scheme_v4": readiness["struct_colors"] != null,
      "route_typography_v4": readiness["struct_typography"] != null,
      "route_spacing_v4": readiness["struct_spacing"] != null,
      "route_motion_v4": ctx.runtime["motion"] != null,
      "route_elevation_v4": ctx.runtime["elevation"] != null,
    };
  }
}
