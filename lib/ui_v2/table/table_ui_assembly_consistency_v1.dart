class TableUIAssemblyConsistencyV1 {
  const TableUIAssemblyConsistencyV1();

  static Map<String, Object?> check({
    required Map<String, Object?> assemblyV2,
  }) {
    final groups = assemblyV2["groups"] as Map<String, Object?>?;

    return {
      "present": true,
      "consistency_stage": 1,
      "checks": {
        "visual_group_ok": groups?["visual_group"] is Map<String, Object?>,
        "effect_group_ok": groups?["effect_group"] is Map<String, Object?>,
        "logic_group_ok": groups?["logic_group"] is Map<String, Object?>,
      },
      "summary": "table_ui_assembly_consistency_v1",
    };
  }
}
