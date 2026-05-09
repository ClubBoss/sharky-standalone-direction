import 'package:flutter/widgets.dart';

import '../theme/v4_token_registry.dart';
import '../theme_v3/style_token_bundle_v4.dart';
import '../theme_v3/theme_v3_resolver.dart';

// ignore: must_be_immutable
class SectionCardV3 extends StatelessWidget {
  SectionCardV3({super.key});

  Map<String, dynamic>? _v4BlendedStyle;
  Map<String, dynamic>? _v4ActivationEnablementBundle;
  bool _v4Active = false;
  Color _backgroundColor = const Color(0xFFE8E8E8);
  Color _foregroundColor = const Color(0xFF4A4A4A);
  static const StyleTokenBundleV4 _defaultTokens = StyleTokenBundleV4(
    primarySurface: Color(0xFFE8E8E8),
    secondarySurface: Color(0xFF4A4A4A),
    accentSurface: Color(0xFF3366FF),
  );

  @override
  Widget build(BuildContext context) => _buildContainer();

  void syncStyle(String style) {
    final bundle = resolveComponentBundleV4();
    applyResolvedStyle(style, bundle);
  }

  void attachV4BlendedStyle(Map<String, dynamic> data) {
    _v4BlendedStyle = data;
  }

  void attachV4ActivationEnablementBundle(Map<String, dynamic> bundle) {
    _v4ActivationEnablementBundle = bundle;
  }

  void syncV4Activation(bool flag) => _v4Active = flag;

  bool getV4Activation() => _v4Active;

  bool get canApplyV4Activation {
    final bundle = _v4ActivationEnablementBundle;
    if (bundle == null) return false;
    final flag = bundle['activationFlag'];
    if (flag is! Map<String, dynamic> || flag['enabled'] != true) return false;
    final enablement = bundle['visualEnablement'];
    if (enablement is! Map<String, dynamic> ||
        enablement['canApplyV4Visuals'] != true) {
      return false;
    }
    return true;
  }

  Map<String, dynamic>? exportV4ActivationEnablementBundle() =>
      _v4ActivationEnablementBundle;

  double resolveV4ActivationColorDelta(double base) {
    if (!canApplyV4Activation || _v4BlendedStyle == null) return base;
    final colorValue = _v4BlendedStyle!['color'];
    double delta = 0.0;
    if (colorValue is num) {
      delta = colorValue.toDouble();
    } else if (colorValue is String) {
      delta = double.tryParse(colorValue) ?? 0.0;
    }
    return base + delta;
  }

  Widget applyResolvedStyle(String style, [StyleTokenBundleV4? bundle]) {
    final tokens = bundle ?? _defaultTokens;
    applyStyleTokens(tokens);
    if (canApplyV4Activation) {
      final delta = resolveV4ActivationColorDelta(0.0).clamp(-0.25, 0.25);
      final target = HSLColor.fromColor(_backgroundColor).withLightness(
        (HSLColor.fromColor(_backgroundColor).lightness + delta).clamp(
          0.0,
          1.0,
        ),
      );
      _backgroundColor = _applyBlend(_backgroundColor, target);
    }
    return _buildContainer();
  }

  void applyStyleTokens(StyleTokenBundleV4 tokens) {
    _backgroundColor = tokens.primarySurface;
    _foregroundColor = tokens.secondarySurface;
  }

  Widget _buildContainer() {
    final elevation = _v4Active ? V4TokenRegistry().v4ShadowBase : 0.0;
    final baseColor = _backgroundColor;
    final tintValue = _v4Active ? V4TokenRegistry().v4SurfaceTint : 0.0;
    final contrast = _v4Active ? V4TokenRegistry().v4ContrastLevel : 1.0;
    final tintedColor = _v4Active
        ? _blendTint(baseColor, tintValue)
        : baseColor;
    final decorationColor = _colorWithMultiplier(tintedColor, contrast);
    final baseContainer = Container(
      decoration: BoxDecoration(
        color: decorationColor,
        border: Border.all(color: _borderColor(0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: const SizedBox(width: double.infinity, height: 70),
    );
    if (!_v4Active) return baseContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: elevation,
            offset: Offset(0, elevation * 0.3),
          ),
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: elevation * 1.15,
            offset: Offset(0, elevation * 0.3),
          ),
        ],
      ),
      child: baseContainer,
    );
  }

  Color _borderColor(double opacity) {
    final alpha = (opacity.clamp(0.0, 1.0) * 255).round();
    return Color.fromARGB(
      alpha,
      (_foregroundColor.r * 255).round() & 0xFF,
      (_foregroundColor.g * 255).round() & 0xFF,
      (_foregroundColor.b * 255).round() & 0xFF,
    );
  }

  Color _applyBlend(Color base, HSLColor delta) {
    final baseHsl = HSLColor.fromColor(base);
    return baseHsl
        .withHue(delta.hue)
        .withSaturation(delta.saturation)
        .withLightness(delta.lightness)
        .toColor();
  }

  Color _blendTint(Color color, double tint) {
    final tinted = _colorWithMultiplier(color, tint);
    return Color.alphaBlend(tinted, color);
  }

  Color _colorWithMultiplier(Color color, double multiplier) {
    final alpha = ((color.a / 255.0 * multiplier).clamp(0.0, 1.0) * 255)
        .round();
    return color.withAlpha(alpha);
  }
}
