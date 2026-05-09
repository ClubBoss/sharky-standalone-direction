import 'v4_runtime_context.dart';

class V4OrchestratorRouteColor {
  const V4OrchestratorRouteColor();

  static Map<String, Object?> route(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final runtime = ctx.runtime;

    return {
      "present": true,
      "primary": runtime["primary"],
      "secondary": runtime["secondary"],
    };
  }
}
