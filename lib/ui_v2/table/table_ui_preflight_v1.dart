class TableUIPreflightV1 {
  const TableUIPreflightV1();

  static Map<String, Object?> run({
    required Map<String, Object?> metaSurface,
    required Map<String, Object?> probe,
  }) {
    return {
      "present": true,
      "preflight_stage": 1,
      "readiness": {
        "meta_surface_ok": metaSurface.isNotEmpty,
        "probe_ok": probe["summary"] == "passive_consistency_probe_v1",
        "minimum_layers": metaSurface.length >= 3,
      },
      "summary": "table_ui_preflight_v1",
    };
  }
}
