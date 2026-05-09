import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:poker_analyzer/ui_v2/components_v3/panel_v3.dart';
import 'package:poker_analyzer/ui_v2/components_v3/section_card_v3.dart';
import 'package:poker_analyzer/ui_v2/components_v3/surface_container_v3.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_emotional_fusion_v3.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_emotional_kernel_v3.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_renderer_v3.dart';
import 'package:poker_analyzer/ui_v2/theme_v3/theme_v3_resolver.dart';

void main() {
  final bundle = resolveComponentBundleV4();
  final kernel = PersonaEmotionalKernelV3()
    ..stressLevel = 0.42
    ..focusLevel = 0.55;
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
  final blendedLightness =
      (HSLColor.fromColor(microColor).lightness + activationDelta * 0.01).clamp(
        0.0,
        1.0,
      );
  final blendedColor = HSLColor.fromColor(
    microColor,
  ).withLightness(blendedLightness).toColor();
  final summary = StringBuffer()
    ..writeln(
      'Tokens | primary=${bundle.primarySurface.toARGB32().toRadixString(16).padLeft(8, '0')} '
      '| secondary=${bundle.secondarySurface.toARGB32().toRadixString(16).padLeft(8, '0')} '
      '| accent=${bundle.accentSurface.toARGB32().toRadixString(16).padLeft(8, '0')}',
    )
    ..writeln('Mood | ${mood.toString()}')
    ..writeln(
      'Microdeltas | warmth=${microdeltas['warmth']} energy=${microdeltas['energy']}',
    )
    ..writeln('Activation | delta=${activationDelta.toStringAsFixed(3)}')
    ..writeln(
      'Blended Color | ${blendedColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
    );
  stdout.write(summary);
  final buffer = StringBuffer();
  buffer.write(summary);
  final components = <String, dynamic>{
    'PanelV3': PanelV3(),
    'SurfaceContainerV3': SurfaceContainerV3(),
    'SectionCardV3': SectionCardV3(),
  };
  for (final entry in components.entries) {
    final component = entry.value;
    component.applyStyleTokens(bundle);
    component.applyResolvedStyle('snapshot', bundle);
    final delta = component.resolveV4ActivationColorDelta(0.0);
    final line =
        '${entry.key.padRight(20)} | activationDelta=${delta.toStringAsFixed(3)}';
    buffer.writeln(line);
    stdout.writeln(line);
  }
  final report = File('release/_reports/visual_cohesion_snapshot_persona.txt');
  report.parent.createSync(recursive: true);
  report.writeAsStringSync(buffer.toString());
}
