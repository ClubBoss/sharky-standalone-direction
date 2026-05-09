/// Compatibility helpers for debug metrics dashboard
class DebugMetricsCompat {
  /// Null-safe number conversion
  static num nz(num? v) => v ?? 0;

  /// Safe map getter with default
  static T getOr<T>(Map m, String k, T d) => (m[k] as T?) ?? d;
}
