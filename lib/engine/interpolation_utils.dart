class InterpolationUtils {
  const InterpolationUtils._();

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double clamp01(double t) {
    if (t < 0.0) return 0.0;
    return t > 1.0 ? 1.0 : t;
  }
}
