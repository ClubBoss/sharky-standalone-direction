class TableUIAssemblyV2 {
  const TableUIAssemblyV2();

  static Map<String, Object?> assemble({
    required Map<String, Object?> assemblyV1,
  }) {
    final structure = (assemblyV1["structure"] as Map?)
        ?.cast<String, Object?>();
    return {
      "present": true,
      "assembly_stage": 2,
      "groups": {
        "visual_group": {
          "layout": structure?["layout"],
          "cards": structure?["cards"],
          "chips": structure?["chips"],
        },
        "effect_group": {
          "highlights": structure?["highlights"],
          "animations": structure?["animations"],
        },
        "logic_group": {
          "interaction": structure?["interaction"],
          "depth": structure?["depth"],
          "performance": structure?["performance"],
        },
      },
      "summary": "table_ui_assembly_v2",
    };
  }
}
