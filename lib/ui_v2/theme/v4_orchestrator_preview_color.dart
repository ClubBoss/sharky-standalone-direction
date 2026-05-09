import 'v4_runtime_context.dart';

class V4OrchestratorPreviewColor {
  const V4OrchestratorPreviewColor();

  static Map<String, Object?> preview(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final runtime = ctx.runtime;

    return {
      "present": true,
      "primary": runtime["primary"] ?? null,
      "secondary": runtime["secondary"] ?? null,
    };
  }
}
