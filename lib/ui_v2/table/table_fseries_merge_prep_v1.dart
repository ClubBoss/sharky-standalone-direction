class TableFSeriesMergePrepV1 {
  const TableFSeriesMergePrepV1();

  static Map<String, Object?> analyze({
    required double width,
    required double height,
    required Map<String, Object?> layout,
    required Map<String, Object?> cards,
    required Map<String, Object?> chips,
    required Map<String, Object?> highlights,
    required Map<String, Object?> animations,
    required Map<String, Object?> interaction,
    required Map<String, Object?> metaSurface,
  }) {
    final layoutOk = layout["present"] == true;
    final cardsOk = cards["present"] == true;
    final chipsOk = chips["present"] == true;
    final highlightsOk = highlights["present"] == true;
    final animationsOk = animations["present"] == true;
    final interactionOk = interaction["present"] == true;
    final zones = metaSurface.keys.toList();
    final layoutDensity = (width * height) / 10000;

    return Map.unmodifiable({
      "present": true,
      "stage": "fseries_merge_prep_v1",
      "fseries_ready":
          layoutOk &&
          cardsOk &&
          chipsOk &&
          highlightsOk &&
          animationsOk &&
          interactionOk &&
          zones.isNotEmpty,
      "merge_flags": {
        "layout": layoutOk,
        "cards": cardsOk,
        "chips": chipsOk,
        "highlights": highlightsOk,
        "animations": animationsOk,
        "interaction": interactionOk,
      },
      "surface_alignment_markers": {
        "zones": zones,
        "dimensions": {"width": width, "height": height},
        "density": layoutDensity,
      },
    });
  }
}
