import 'v4_runtime_context.dart';

class V4OrchestratorAdapter {
  const V4OrchestratorAdapter();

  static Map<String, Object?> adapt(V4RuntimeContext? ctx) {
    if (ctx == null) {
      return const {"present": false};
    }
    return {
      "present": true,
      "readiness": ctx.readiness,
      "runtime": ctx.runtime,
      "global": ctx.global,
    };
  }
}
