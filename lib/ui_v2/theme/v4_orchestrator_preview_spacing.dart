import 'v4_runtime_context.dart';

class V4OrchestratorPreviewSpacing {
  const V4OrchestratorPreviewSpacing();

  static Map<String, Object?> preview(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;

    return {"present": true, "spacing_base": readiness["struct_spacing"]};
  }
}
