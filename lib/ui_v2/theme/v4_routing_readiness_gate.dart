import 'v4_runtime_context.dart';

class V4RoutingReadinessGate {
  const V4RoutingReadinessGate();

  static Map<String, Object?> assess(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    final okColors = readiness["struct_colors"] != null;
    final okTypography = readiness["struct_typography"] != null;
    final okSpacing = readiness["struct_spacing"] != null;
    final okMotion = runtime["motion"] != null;
    final okElevation = runtime["elevation"] != null;

    return {
      "present": true,
      "ready_for_full_routing":
          okColors && okTypography && okSpacing && okMotion && okElevation,
    };
  }
}
