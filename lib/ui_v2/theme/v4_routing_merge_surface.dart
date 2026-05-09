import 'v4_runtime_context.dart';

class V4RoutingMergeSurface {
  const V4RoutingMergeSurface();

  static Map<String, Object?> merge(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "merge_colors":
          readiness["struct_colors"] != null &&
          runtime["primary"] != null &&
          runtime["secondary"] != null,
      "merge_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "merge_spacing": readiness["struct_spacing"] != null,
      "merge_motion": runtime["motion"] != null,
      "merge_elevation": runtime["elevation"] != null,
      "merge_stage": 1,
    };
  }
}
