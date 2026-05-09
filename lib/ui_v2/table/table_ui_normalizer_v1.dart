class TableUINormalizerV1 {
  const TableUINormalizerV1();

  static Map<String, Object?> normalize({
    required Map<String, Object?> handoff,
  }) {
    return {
      "present": true,
      "stage": "table_ui_normalizer_v1",
      "layout_ok": handoff["layout"] != null,
      "cards_ok": handoff["cards"] != null,
      "chips_ok": handoff["chips"] != null,
      "highlights_ok": handoff["highlights"] != null,
      "animations_ok": handoff["animations"] != null,
      "interaction_ok": handoff["interaction"] != null,
      "typography_ok": handoff["typography"] != null,
      "normalized_surface": {
        "layout": handoff["layout"],
        "cards": handoff["cards"],
        "chips": handoff["chips"],
        "highlights": handoff["highlights"],
        "animations": handoff["animations"],
        "interaction": handoff["interaction"],
        "typography": handoff["typography"],
      },
      "normalized_ready": false,
    };
  }
}
