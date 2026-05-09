class TableUIMapperV1 {
  const TableUIMapperV1();

  static Map<String, Object?> map({required Map<String, Object?> normalized}) {
    return {
      "present": true,
      "stage": "table_ui_mapper_v1",
      "layout_ok": normalized["layout"] != null,
      "cards_ok": normalized["cards"] != null,
      "chips_ok": normalized["chips"] != null,
      "highlights_ok": normalized["highlights"] != null,
      "animations_ok": normalized["animations"] != null,
      "interaction_ok": normalized["interaction"] != null,
      "typography_ok": normalized["typography"] != null,
      "ui_groups": {
        "layout_group": normalized["layout"],
        "visual_group": {
          "cards": normalized["cards"],
          "chips": normalized["chips"],
          "highlights": normalized["highlights"],
          "animations": normalized["animations"],
        },
        "interaction_group": normalized["interaction"],
        "typography_group": normalized["typography"],
      },
      "mapped_ready": false,
    };
  }
}
