import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_emotional_fusion_v3.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_emotional_kernel_v3.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_renderer_v3.dart';
import 'package:poker_analyzer/ui_v2/theme_v3/style_token_bundle_v4.dart';
import 'package:poker_analyzer/ui_v2/theme_v3/theme_v3.dart';

void main() {
  final theme = ThemeV3();
  final contract = theme.exportV4ThemeContract();
  final snapshot = theme.getV4BaselineSnapshot();
  final bundle = theme.getComponentBundleV4();
  final kernel = PersonaEmotionalKernelV3();
  final fusion = PersonaEmotionalFusionV3();
  final renderer = PersonaRendererV3(kernel: kernel, fusion: fusion);
  renderer.applyComponentBundle(bundle);
  final mood = kernel.inferMood();
  final microdeltas = kernel.inferMicrodeltas();
  final activationDelta = renderer.resolveV4ActivationColorDelta(0.0);
  final microColor = fusion.applyMicrodeltas(
    bundle.primarySurface,
    microdeltas,
  );
  final activationColor = HSLColor.fromColor(microColor)
      .withLightness(
        (HSLColor.fromColor(microColor).lightness + activationDelta * 0.02)
            .clamp(0.0, 1.0),
      )
      .toColor();
  final readiness = _evaluateReadiness(
    kernel,
    renderer,
    microdeltas,
    activationDelta,
  );
  final cohesion = _describeCohesion(
    bundle,
    mood,
    microdeltas,
    activationColor,
  );

  final buffer = StringBuffer()
    ..writeln('==== THEME V4 CONTRACT ====')
    ..writeln(contract)
    ..writeln('==== BASELINE SNAPSHOT ====')
    ..writeln(snapshot.trim())
    ..writeln('==== ACTIVATION/MOOD SYNC ====')
    ..writeln(
      'Tokens RGB ${_describeColor(bundle.primarySurface)}, mood ${mood.toString()}, micro ${microdeltas['warmth']}/${microdeltas['energy']}, activation delta=${activationDelta.toStringAsFixed(3)}, blended=${_describeColor(activationColor)}',
    )
    ..writeln('==== PERSONA READINESS ====')
    ..writeln(readiness)
    ..writeln('==== VISUAL COHESION ====')
    ..writeln(cohesion);

  stdout.write(buffer);
  final report = File('release/_reports/v4_consolidated_snapshot.txt');
  report.parent.createSync(recursive: true);
  report.writeAsStringSync(buffer.toString());
}

String _describeColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  final r = ((color.r * 255).round()) & 0xFF;
  final g = ((color.g * 255).round()) & 0xFF;
  final b = ((color.b * 255).round()) & 0xFF;
  return 'rgb($r,$g,$b) hsl(${hsl.hue.toStringAsFixed(1)},${(hsl.saturation * 100).toStringAsFixed(1)}%,${(hsl.lightness * 100).toStringAsFixed(1)}%)';
}

String _evaluateReadiness(
  PersonaEmotionalKernelV3 kernel,
  PersonaRendererV3 renderer,
  Map<String, double> microdeltas,
  double activationDelta,
) {
  final failures = <String>[];
  if (kernel.stressLevel < 0 || kernel.stressLevel > 1) {
    failures.add('stress ${kernel.stressLevel} out of bounds');
  }
  if (kernel.focusLevel < 0 || kernel.focusLevel > 1) {
    failures.add('focus ${kernel.focusLevel} out of bounds');
  }
  if (microdeltas['warmth']!.abs() > 0.03 ||
      microdeltas['energy']!.abs() > 0.03) {
    failures.add('microdeltas exceed 0.03');
  }
  if (renderer.canApplyV4Activation && activationDelta == 0.0) {
    failures.add('activation gate true but delta zero');
  }
  if (failures.isEmpty) return 'Status PASS';
  return ['Status FAIL', ...failures.map((f) => '  • $f')].join('\n');
}

String _describeCohesion(
  StyleTokenBundleV4 bundle,
  PersonaMoodV4 mood,
  Map<String, double> microdeltas,
  Color activationColor,
) {
  return 'Tokens ${_describeColor(bundle.primarySurface)} | mood=$mood | micro=${microdeltas['warmth']}/${microdeltas['energy']} | activation=${_describeColor(activationColor)}';
}
