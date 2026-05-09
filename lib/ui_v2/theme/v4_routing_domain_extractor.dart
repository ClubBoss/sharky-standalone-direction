import 'v4_runtime_context.dart';

class V4RoutingDomainExtractor {
  const V4RoutingDomainExtractor();

  static Map<String, Object?> extract(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;
    final rd = ctx.readiness;

    return {
      "present": true,
      "domain_colors":
          rd["struct_colors"] != null &&
          r["primary"] != null &&
          r["secondary"] != null,
      "domain_typography":
          rd["struct_typography_scale_body"] != null &&
          rd["struct_typography_scale_title"] != null,
      "domain_spacing": rd["struct_spacing"] != null,
      "domain_motion": r["motion"] != null,
      "domain_elevation": r["elevation"] != null,
      "domain_stage": 1,
    };
  }
}
