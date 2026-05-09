class MotionPrimitives {
  static Map<String, double> fadeScale({
    required double t,
    double minScale = 0.92,
    double maxScale = 1.0,
    double minOpacity = 0.0,
    double maxOpacity = 1.0,
  }) {
    final scale = minScale + (maxScale - minScale) * t;
    final opacity = minOpacity + (maxOpacity - minOpacity) * t;
    return {'scale': scale, 'opacity': opacity};
  }
}
