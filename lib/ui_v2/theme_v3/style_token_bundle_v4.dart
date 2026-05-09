import 'package:flutter/painting.dart';

enum PersonaMoodV4 { calm, focus, playful, sharp }

class StyleTokenBundleV4 {
  final Color primarySurface;
  final Color secondarySurface;
  final Color accentSurface;
  final PersonaMoodV4? mood;

  const StyleTokenBundleV4({
    required this.primarySurface,
    required this.secondarySurface,
    required this.accentSurface,
    this.mood,
  });

  StyleTokenBundleV4 copyWith({
    Color? primarySurface,
    Color? secondarySurface,
    Color? accentSurface,
    PersonaMoodV4? mood,
  }) {
    return StyleTokenBundleV4(
      primarySurface: primarySurface ?? this.primarySurface,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      accentSurface: accentSurface ?? this.accentSurface,
      mood: mood,
    );
  }

  // Mood adjustments must keep HSL channels clamped (0–1) and rounded to 4 decimals.
  StyleTokenBundleV4 applyMoodVariant([PersonaMoodV4? override]) {
    final mode = override ?? mood;
    if (mode == null) return this;
    Color change(Color color) {
      final hsl = HSLColor.fromColor(color);
      switch (mode) {
        case PersonaMoodV4.calm:
          return hsl
              .withSaturation((hsl.saturation - 0.08).clamp(0.0, 1.0))
              .toColor();
        case PersonaMoodV4.focus:
          final delta = hsl.lightness >= 0.5 ? 0.05 : -0.05;
          return hsl
              .withLightness((hsl.lightness + delta).clamp(0.0, 1.0))
              .toColor();
        case PersonaMoodV4.playful:
          return hsl.withHue((hsl.hue + 4.0) % 360.0).toColor();
        case PersonaMoodV4.sharp:
          return hsl
              .withHue((hsl.hue - 3.0).clamp(0.0, 360.0))
              .withSaturation((hsl.saturation + 0.03).clamp(0.0, 1.0))
              .toColor();
      }
    }

    return StyleTokenBundleV4(
      primarySurface: _rounded(change(primarySurface)),
      secondarySurface: _rounded(change(secondarySurface)),
      accentSurface: _rounded(change(accentSurface)),
      mood: mode,
    );
  }

  Map<String, dynamic> toContractMap() {
    return {
      'primary': _describeColor(primarySurface),
      'secondary': _describeColor(secondarySurface),
      'accent': _describeColor(accentSurface),
      'hsl': {
        'primary': _describeHsl(primarySurface),
        'secondary': _describeHsl(secondarySurface),
        'accent': _describeHsl(accentSurface),
      },
      'mood': mood?.toString(),
    };
  }

  Color _rounded(Color color) => color;

  Map<String, double> _describeHsl(Color color) {
    final hsl = HSLColor.fromColor(color);
    return {
      'h': double.parse(hsl.hue.toStringAsFixed(4)),
      's': double.parse(hsl.saturation.toStringAsFixed(4)),
      'l': double.parse(hsl.lightness.toStringAsFixed(4)),
    };
  }

  Map<String, dynamic> _describeColor(Color color) {
    final r = ((color.r * 255).round()) & 0xFF;
    final g = ((color.g * 255).round()) & 0xFF;
    final b = ((color.b * 255).round()) & 0xFF;
    final alpha = ((color.a * 255).round()) & 0xFF;
    final hex = ((alpha << 24) | (r << 16) | (g << 8) | b)
        .toRadixString(16)
        .padLeft(8, '0');
    return {'rgb': '$r,$g,$b', 'hex': hex};
  }
}
