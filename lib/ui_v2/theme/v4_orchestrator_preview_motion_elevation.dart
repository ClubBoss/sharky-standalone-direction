import 'v4_runtime_context.dart';

class V4OrchestratorPreviewMotionElevation {
  const V4OrchestratorPreviewMotionElevation();

  static Map<String, Object?> preview(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final runtime = ctx.runtime;

    return {
      "present": true,
      "motion_curve": runtime["motion"],
      "elevation_level": runtime["elevation"],
    };
  }
}
