class CardRendererV1 {
  const CardRendererV1();

  static Map<String, Object?> stage({
    required Map<String, Object?> cardsGroup,
  }) {
    return {
      "present": true,
      "stage": "card_renderer_v1",
      "cards_ok": cardsGroup.isNotEmpty,
      "render_plan": {
        "geometry": cardsGroup["card_geometry"],
        "ranks": cardsGroup["rank_map"],
        "suits": cardsGroup["suit_map"],
        "vector_layers": cardsGroup["vector_layers"],
      },
      "card_stage_ready": false,
    };
  }
}
