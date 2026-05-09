import 'v4_runtime_context.dart';

class V4OrchestratorPreviewTypography {
  const V4OrchestratorPreviewTypography();

  static Map<String, Object?> preview(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;

    return {
      "present": true,
      "scale_body": readiness["struct_typography_scale_body"],
      "scale_title": readiness["struct_typography_scale_title"],
    };
  }
}
