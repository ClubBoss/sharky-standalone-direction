import 'v4_runtime_context.dart';

class V4RoutingSelector {
  const V4RoutingSelector();

  static Map<String, Object?> select(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "route_colors":
          readiness["struct_colors"] != null && runtime["primary"] != null,
      "route_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "route_spacing": readiness["struct_spacing"] != null,
      "route_motion": runtime["motion"] != null,
      "route_elevation": runtime["elevation"] != null,
    };
  }
}
