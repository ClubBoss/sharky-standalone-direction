/// AppSpacing defines unified spacing tokens for visual cohesion.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;

  /// Applies a density multiplier (used by design AI spacing scale).
  static double scale(double value, double multiplier) => value * multiplier;
}
