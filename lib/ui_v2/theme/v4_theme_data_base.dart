import 'package:flutter/material.dart';
import 'v4_theme_struct.dart';

class V4ThemeDataBase {
  const V4ThemeDataBase({
    required this.activationBundle,
    required this.colorDelta,
    required this.struct,
  });

  final Map<String, Object?>? activationBundle;
  final Map<String, Object?>? colorDelta;
  final V4ThemeStruct struct;

  ThemeData build() {
    final primary = _extractColor(struct.colors["primary"]);
    final secondary = _extractColor(struct.colors["secondary"]);
    final bodyScale = struct.typography["scale_body"] as double? ?? 1.0;
    final titleScale = struct.typography["scale_title"] as double? ?? 1.0;
    final spacingUnit = struct.spacing["unit"] as double? ?? 4.0;
    spacingUnit;
    final baseTextTheme = Typography.material2021().black;
    final bodyTextTheme = baseTextTheme.apply(fontSizeFactor: bodyScale);
    final titleTextTheme = baseTextTheme.apply(fontSizeFactor: titleScale);
    final harmonizedTextTheme = bodyTextTheme.copyWith(
      displayLarge: titleTextTheme.displayLarge,
      displayMedium: titleTextTheme.displayMedium,
      displaySmall: titleTextTheme.displaySmall,
    );
    final elevationLevel = (struct.elevation["base"] as double? ?? 1.0).clamp(
      0.0,
      8.0,
    );
    Curve _resolveCurve(String? name) {
      switch (name) {
        case "ease_in":
          return Curves.easeIn;
        case "ease_out":
          return Curves.easeOut;
        case "ease_in_out":
          return Curves.easeInOut;
        default:
          return Curves.linear;
      }
    }

    final curveToken = struct.motion["curve"] as String? ?? "linear";
    final motionCurve = _resolveCurve(curveToken);
    final colorScheme = ColorScheme.light(
      primary: primary ?? const Color(0xFF000000),
      secondary: secondary ?? const Color(0xFFFFFFFF),
    );
    return ThemeData(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.secondary,
      textTheme: harmonizedTextTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      extensions: <ThemeExtension<dynamic>>[
        _V4ElevationLevel(elevationLevel),
        _V4MotionCurve(motionCurve),
      ],
    );
  }

  Color? _extractColor(Object? value) {
    if (value is int) return Color(value);
    return null;
  }
}

class _V4ElevationStub extends ThemeExtension<_V4ElevationStub> {
  const _V4ElevationStub(this.base);

  final double base;

  @override
  _V4ElevationStub copyWith({double? base}) =>
      _V4ElevationStub(base ?? this.base);

  @override
  _V4ElevationStub lerp(
    covariant ThemeExtension<_V4ElevationStub>? other,
    double t,
  ) => this;
}

class _V4MotionStub extends ThemeExtension<_V4MotionStub> {
  const _V4MotionStub(this.curve);

  final String curve;

  @override
  _V4MotionStub copyWith({String? curve}) => _V4MotionStub(curve ?? this.curve);

  @override
  _V4MotionStub lerp(
    covariant ThemeExtension<_V4MotionStub>? other,
    double t,
  ) => this;
}

class _V4ElevationLevel extends ThemeExtension<_V4ElevationLevel> {
  const _V4ElevationLevel(this.level);

  final double level;

  @override
  _V4ElevationLevel copyWith({double? level}) =>
      _V4ElevationLevel(level ?? this.level);

  @override
  _V4ElevationLevel lerp(
    covariant ThemeExtension<_V4ElevationLevel>? other,
    double t,
  ) => this;
}

class _V4MotionCurve extends ThemeExtension<_V4MotionCurve> {
  const _V4MotionCurve(this.curve);

  final Curve curve;

  @override
  _V4MotionCurve copyWith({Curve? curve}) =>
      _V4MotionCurve(curve ?? this.curve);

  @override
  _V4MotionCurve lerp(
    covariant ThemeExtension<_V4MotionCurve>? other,
    double t,
  ) => this;
}
