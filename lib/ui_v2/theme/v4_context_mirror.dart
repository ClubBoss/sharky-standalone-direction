import 'v4_runtime_context.dart';

class V4ContextMirror {
  const V4ContextMirror();

  static Map<String, Object?> reflect(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};
    return {
      "present": true,
      "readiness": ctx.readiness,
      "runtime": ctx.runtime,
      "global": ctx.global,
    };
  }
}
