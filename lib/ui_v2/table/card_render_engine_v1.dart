class CardRenderEngineV1 {
  const CardRenderEngineV1();

  static Map<String, Object?> render({
    required double screenWidth,
    required double screenHeight,
  }) {
    return {
      "present": true,
      "stage": "card_render_v2",
      "surface": {"width": screenWidth, "height": screenHeight},
      "outline": "rounded_rect_v1",
      "glyphs": "rank_and_suit",
    };
  }

  static Map<String, Object?> renderCard({
    required String rank,
    required String suit,
    required double scale,
  }) {
    return {
      "present": true,
      "rank": rank,
      "suit": suit,
      "scale": scale,
      "vector": {
        "outline": "rounded_rect_v1",
        "rank_glyph": "text_v1",
        "suit_glyph": "vector_icon_v1",
        "stage": 1,
      },
    };
  }
}
