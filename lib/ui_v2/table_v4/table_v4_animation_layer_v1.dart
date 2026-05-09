import 'package:flutter/material.dart';

/// Stateless animation layer for Table V4 micro-animations.
class TableV4AnimationLayerV1 extends StatelessWidget {
  const TableV4AnimationLayerV1({
    super.key,
    required this.child,
    required this.animationSpec,
  });

  final Widget child;
  final Map<String, Object?> animationSpec;

  @override
  Widget build(BuildContext context) {
    if (animationSpec['active'] != true) {
      return child;
    }
    final String type = (animationSpec['type'] as String?) ?? 'fade';
    final Duration duration = _duration(animationSpec['duration_ms']);
    final Curve curve = _parseCurve(animationSpec['curve'] as String?);
    switch (type) {
      case 'scale':
        final double scale = _clampScale(
          _readDouble(animationSpec, 'scale', 1.0),
        );
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1.0, end: scale),
          duration: duration,
          curve: curve,
          builder: (_, value, child) =>
              Transform.scale(scale: value, child: child),
          child: child,
        );
      case 'glow':
        final double glowOpacity = _clampGlow(
          _readDouble(animationSpec, 'glow_opacity', 0.2),
        );
        final Tween<double> glowTween = Tween<double>(begin: 0.0, end: 1.0);
        return TweenAnimationBuilder<double>(
          tween: glowTween,
          duration: duration,
          curve: curve,
          builder: (_, value, child) {
            final double pulse = _triangle(value) * glowOpacity;
            return Stack(
              children: <Widget>[
                child ?? const SizedBox.shrink(),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _glowColor(pulse),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: _glowColor(pulse),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: child,
        );
      case 'fade':
      default:
        final double targetOpacity = _clampOpacity(
          _readDouble(animationSpec, 'opacity', 1.0),
        );
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: targetOpacity),
          duration: duration,
          curve: curve,
          builder: (_, value, child) => Opacity(opacity: value, child: child),
          child: child,
        );
    }
  }

  static double _readDouble(
    Map<String, Object?> spec,
    String key,
    double fallback,
  ) {
    final Object? value = spec[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static Duration _duration(Object? raw) {
    if (raw is num) {
      return _durationFromMillis(raw.toInt());
    }
    if (raw is String) {
      final int? parsed = int.tryParse(raw);
      if (parsed != null) {
        return _durationFromMillis(parsed);
      }
    }
    return _durationFromMillis(200);
  }

  static Duration _durationFromMillis(int millis) {
    final int clamped = millis.clamp(80, 600);
    return Duration(milliseconds: clamped);
  }

  static Curve _parseCurve(String? curve) {
    switch (curve) {
      case 'linear':
        return Curves.linear;
      case 'ease_out':
        return Curves.easeOut;
      case 'ease':
      default:
        return Curves.easeInOut;
    }
  }

  static double _clampScale(double candidate) {
    if (candidate <= 1.0) {
      return candidate;
    }
    return candidate.clamp(1.0, 1.05);
  }

  static double _clampOpacity(double value) => value.clamp(0.0, 1.0);

  static double _clampGlow(double value) => value.clamp(0.0, 0.35);

  static Color _glowColor(double value) {
    final int alpha = (value * 255).round().clamp(0, 255);
    return Colors.white.withAlpha(alpha);
  }

  static double _triangle(double value) {
    if (value <= 0.5) {
      return value * 2;
    }
    return (1 - value) * 2;
  }
}
