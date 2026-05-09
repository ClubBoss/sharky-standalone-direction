import 'v4_runtime_context.dart';

class V4RoutingMergeV1 {
  const V4RoutingMergeV1();

  static Map<String, Object?> merge(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final r = ctx.runtime;
    final rd = ctx.readiness;

    return {
      "present": true,
      "merged_colors": rd["struct_colors"] != null
          ? {"primary": r["primary"], "secondary": r["secondary"]}
          : null,
      "merged_typography":
          (rd["struct_typography_scale_body"] != null &&
              rd["struct_typography_scale_title"] != null)
          ? {
              "body": rd["struct_typography_scale_body"],
              "title": rd["struct_typography_scale_title"],
            }
          : null,
      "merged_spacing": rd["struct_spacing"] != null
          ? rd["struct_spacing"]
          : null,
      "merged_motion": r["motion"] ?? null,
      "merged_elevation": r["elevation"] ?? null,
      "merge_v1_stage": 1,
    };
  }
}
