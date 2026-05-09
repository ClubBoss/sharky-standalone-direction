class ClipFrameSpec {
  final double t;
  final double scale;
  final double yLift;
  final double opacity;

  const ClipFrameSpec({
    required this.t,
    this.scale = 1.0,
    this.yLift = 0.0,
    this.opacity = 1.0,
  });
}
