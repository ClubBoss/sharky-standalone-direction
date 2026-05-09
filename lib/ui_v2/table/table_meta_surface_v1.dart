class TableMetaSurfaceV1 {
  const TableMetaSurfaceV1();

  static Map<String, Object?> build({
    required Map<String, Object?> layout,
    required Map<String, Object?> cards,
    required Map<String, Object?> chips,
    required Map<String, Object?> highlights,
    required Map<String, Object?> animations,
    required Map<String, Object?> interaction,
    required Map<String, Object?> typography,
  }) {
    return {
      "present": true,
      "stage": "table_meta_surface_v1",
      "layout": layout,
      "cards": cards,
      "chips": chips,
      "highlights": highlights,
      "animations": animations,
      "interaction": interaction,
      "typography": typography,
      "table_meta_ready": false,
    };
  }
}
