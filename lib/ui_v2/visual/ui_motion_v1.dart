import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// Motion tokens for non-table UI surfaces with deterministic defaults.
/// These values mirror the small, functional transitions already scattered
/// across `lib/ui_v2` so adding motion here keeps behavior identical.
abstract class UiMotionV1 {
  UiMotionV1._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 240);
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve gentleCurve = Curves.easeOut;

  /// Wraps [child] in an [AnimatedScale] that toggles between [baseScale] and
  /// [targetScale] when [active] changes.
  static Widget interactiveScale({
    required bool active,
    required Widget child,
    double baseScale = 1.0,
    double targetScale = 1.06,
    Duration duration = fast,
    Curve curve = standardCurve,
    Alignment alignment = Alignment.center,
  }) {
    return AnimatedScale(
      scale: active ? targetScale : baseScale,
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: child,
    );
  }
}
