import 'v4_runtime_context.dart';

class V4OrchestratorTokenIntake {
  const V4OrchestratorTokenIntake();

  static Map<String, Object?> intake(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};
    return {
      "present": true,
      "colors": ctx.readiness["struct_colors"] ?? const [],
      "typography": ctx.readiness["struct_typography"] ?? const [],
      "spacing": ctx.readiness["struct_spacing"] ?? const [],
    };
  }
}
