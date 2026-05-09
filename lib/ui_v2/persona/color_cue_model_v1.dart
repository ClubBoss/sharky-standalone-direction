class ColorCueModelV1 {
  const ColorCueModelV1({
    this.hueShift,
    this.saturationBoost,
    this.contrastBoost,
  });

  final double? hueShift;
  final double? saturationBoost;
  final double? contrastBoost;

  void debugPrintChannels() {
    // TODO Phase-5 color debug
  }
}
