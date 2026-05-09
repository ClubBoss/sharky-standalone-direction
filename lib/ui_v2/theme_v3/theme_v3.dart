import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';

import '../theme_v3/style_token_bundle_v4.dart';

class ThemeV3 {
  ThemeV3({
    this.primaryColor = const Color(0xFF3366FF),
    this.surfaceColor = const Color(0xFFF5F5F5),
    this.textColor = const Color(0xFF1F1F1F),
  });

  final Color primaryColor;
  final Color surfaceColor;
  final Color textColor;

  StyleTokenBundleV4 getComponentBundleV4() {
    return StyleTokenBundleV4(
      primarySurface: surfaceColor,
      secondarySurface: textColor,
      accentSurface: primaryColor,
    );
  }

  String getV4BaselineSnapshot() {
    final buffer = StringBuffer();
    buffer.writeln('ThemeV4 Baseline');
    buffer.writeln('primary | ${_describeColor(primaryColor)}');
    buffer.writeln('surface | ${_describeColor(surfaceColor)}');
    buffer.writeln('text    | ${_describeColor(textColor)}');
    return buffer.toString();
  }

  Map<String, dynamic> exportV4ThemeContract() {
    final bundle = getComponentBundleV4();
    return {
      'surfaces': bundle.toContractMap(),
      'tokens': {
        'primaryToken': 'surface.primary',
        'secondaryToken': 'surface.text',
        'accentToken': 'surface.accent',
      },
    };
  }

  Map<String, Object?> exportV4ActivationEnablementBundle() =>
      Map<String, Object?>.unmodifiable({
        'isV4Active': false,
        'activationSupervisor': null,
        'activationConsistency': null,
        'visualEnablement': null,
        'activationContext': null,
      });

  Map<String, Object?> exportV4ActivationConsistencyRelay() =>
      Map<String, Object?>.unmodifiable({
        'activationConsistency': null,
        'activationReadiness': null,
        'activationSupervisor': null,
        'activationContext': null,
      });

  Map<String, Object?> exportV4DiagnosticsBundle() =>
      Map<String, Object?>.unmodifiable({
        'activationEnablement': exportV4ActivationEnablementBundle(),
        'activationConsistency': exportV4ActivationConsistencyRelay(),
      });

  bool get isV4ActivationReady => false;

  String _describeColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final r = ((color.r * 255).round()) & 0xFF;
    final g = ((color.g * 255).round()) & 0xFF;
    final b = ((color.b * 255).round()) & 0xFF;
    return 'rgb($r,$g,$b) '
        'hsl(${hsl.hue.toStringAsFixed(1)},${(hsl.saturation * 100).toStringAsFixed(1)}%,${(hsl.lightness * 100).toStringAsFixed(1)}%)';
  }
}
