import 'package:flutter/widgets.dart';

/// Minimal no-op stub for headless `dart test` (no dart:ui).
class Lottie {
  static Widget asset(
    String name, {
    Key? key,
    BoxFit? fit,
    bool? repeat,
    bool? animate,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
  }) => const SizedBox.shrink();

  static Widget network(
    String url, {
    Key? key,
    BoxFit? fit,
    bool? repeat,
    bool? animate,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
  }) => const SizedBox.shrink();
}

/// Some projects import LottieBuilder; provide a harmless alias.
typedef LottieBuilder = Widget;
