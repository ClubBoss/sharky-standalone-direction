import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_emotional_fusion_v3.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_emotional_kernel_v3.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_renderer_v3.dart';
import 'package:poker_analyzer/ui_v2/theme_v3/theme_v3_resolver.dart';

void main() {
  final bundle = resolveComponentBundleV4();
  final kernel = PersonaEmotionalKernelV3();
  final fusion = PersonaEmotionalFusionV3();
  final renderer = PersonaRendererV3(kernel: kernel, fusion: fusion);
  renderer.applyComponentBundle(bundle);
  final mood = kernel.inferMood();
  final microdeltas = kernel.inferMicrodeltas();
  final activationDelta = renderer.resolveV4ActivationColorDelta(0.0);
  final tokensColor = bundle.primarySurface;
  final moodColor = bundle.applyMoodVariant(mood).primarySurface;
  final microColor = fusion.applyMicrodeltas(moodColor, microdeltas);
  final activationColor = HSLColor.fromColor(microColor)
      .withLightness(
        (HSLColor.fromColor(microColor).lightness +
                (renderer.canApplyV4Activation ? activationDelta * 0.02 : 0.0))
            .clamp(0.0, 1.0),
      )
      .toColor();
  final buffer = StringBuffer();
  final failures = <String>[];
  if (kernel.stressLevel < 0.0 || kernel.stressLevel > 1.0) {
    failures.add('stress level ${kernel.stressLevel} out of range');
  }
  if (kernel.focusLevel < 0.0 || kernel.focusLevel > 1.0) {
    failures.add('focus level ${kernel.focusLevel} out of range');
  }
  if (microdeltas['warmth']!.abs() > 0.03 ||
      microdeltas['energy']!.abs() > 0.03) {
    failures.add('microdeltas exceed 0.03 bounds');
  }
  if (renderer.canApplyV4Activation && activationDelta == 0.0) {
    failures.add('canApplyV4Activation true but delta zero');
  }
  buffer.writeln('Persona Readiness Gate');
  buffer.writeln('Mood | ${mood.toString()}');
  buffer.writeln(
    'Tokens | ${_describeColor(tokensColor)}\nMoodAdjusted | ${_describeColor(moodColor)}',
  );
  buffer.writeln('Microdeltas | ${_describeColor(microColor)}');
  buffer.writeln(
    'Activation | ${_describeColor(activationColor)} delta=$activationDelta',
  );
  if (failures.isEmpty) {
    buffer.writeln('Status | PASS');
  } else {
    buffer.writeln('Status | FAIL');
    failures.forEach((reason) => buffer.writeln('  • $reason'));
  }
  stdout.write(buffer);
  final report = File('release/_reports/persona_readiness_gate.txt');
  report.parent.createSync(recursive: true);
  report.writeAsStringSync(buffer.toString());
  if (failures.isNotEmpty) {
    exit(1);
  }
}

String _describeColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  return 'rgb(${color.r},${color.g},${color.b}) '
      'hsl(${hsl.hue.toStringAsFixed(1)},${(hsl.saturation * 100).toStringAsFixed(1)}%,${(hsl.lightness * 100).toStringAsFixed(1)}%)';
}
