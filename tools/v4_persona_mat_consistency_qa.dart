import 'package:flutter/material.dart';

import '../lib/ui_v2/app_root.dart';
import 'dart:io';

import '../lib/ui_v2/persona/persona_renderer_v3.dart';
import '../lib/ui_v2/theme/visual_cohesion_tokens_v3.dart';
import '../lib/ui_v2/theme/v4_theme_builder.dart';
import '../lib/ui_v2/theme/v4_token_registry.dart';

Future<int> runV4PersonaMatConsistencyQA() async {
  final registry = const V4TokenRegistry();
  final builder = V4ThemeDataBuilder();
  final renderer = PersonaRendererV3();

  final personaIssues = <String>[];
  final gatingActive = appRoot.isV4RuntimeActivated;
  final bundle = renderer.personaProfileViewBundleOrNull;
  final personaSummary = renderer.personaProfileSummaryText;
  if (bundle != null && !gatingActive) {
    personaIssues.add(
      'bundle present while appRoot.isV4RuntimeActivated is false (should gate)',
    );
  }
  if (gatingActive && bundle == null) {
    personaIssues.add('V4 runtime active but persona bundle is null');
  }
  if (bundle != null) {
    if (bundle.personaId.isEmpty) {
      personaIssues.add('bundle personaId is empty');
    }
    if (personaSummary.isEmpty) {
      personaIssues.add('personaProfileSummaryText is empty');
    }
  }

  final themeIssues = <String>[];
  final baseTheme = ThemeData.light();
  final v4Theme = builder.build(baseTheme, true, registry);
  if (v4Theme.cardTheme.shape == null) {
    themeIssues.add(
      'cardTheme.shape missing (V4 builder didn\'t apply radius)',
    );
  }
  if (v4Theme.cardTheme.surfaceTintColor == null) {
    themeIssues.add('card surface tint missing (should reflect tokens)');
  }
  if (v4Theme.chipTheme.shape == null) {
    themeIssues.add('chipTheme.shape missing');
  }
  if (v4Theme.dividerTheme.color == null) {
    themeIssues.add('dividerTheme color missing');
  }
  final textTheme = v4Theme.textTheme;
  if (textTheme.bodyLarge?.fontSize == null ||
      textTheme.bodyLarge!.fontSize! <= 0) {
    themeIssues.add('bodyLarge text size invalid');
  }
  if (textTheme.titleLarge?.fontWeight == null) {
    themeIssues.add('titleLarge fontWeight missing');
  }

  final matIssues = <String>[];
  final cohesion = builder.componentCohesionPreview;
  const expectation = <String, num>{
    'radiusBase': VisualCohesionTokensV3.radiusM,
    'spacingSm': VisualCohesionTokensV3.spacingS,
    'spacingMd': VisualCohesionTokensV3.spacingM,
    'elevationLow': VisualCohesionTokensV3.elevationS,
  };
  for (final key in expectation.keys) {
    if (!cohesion.containsKey(key)) {
      matIssues.add('componentCohesionPreview missing $key');
      continue;
    }
    final value = cohesion[key];
    if (value is! num) {
      matIssues.add('componentCohesionPreview $key is not numeric');
      continue;
    }
    if (value < 0) {
      matIssues.add('componentCohesionPreview $key negative: $value');
    }
  }
  for (final entry in registryValues(registry).entries) {
    if (!_isAscii(entry.key)) {
      matIssues.add('token key not ASCII: ${entry.key}');
    }
    if (entry.value == null) {
      matIssues.add('token ${entry.key} exposed null');
    }
  }

  final report = [
    _sectionReport('persona_consistency', personaIssues),
    _sectionReport('theme_consistency', themeIssues),
    _sectionReport('mat_consistency', matIssues),
  ].join('\n');
  print(report);

  final hasFailures = [personaIssues, themeIssues, matIssues].any(
    (issues) => issues.any(
      (issue) => issue.contains('missing') || issue.contains('negative'),
    ),
  );
  final hasWarnings =
      [
        personaIssues,
        themeIssues,
        matIssues,
      ].any((issues) => issues.isNotEmpty) &&
      !hasFailures;
  if (hasFailures) return 2;
  if (hasWarnings) return 1;
  return 0;
}

Map<String, num?> registryValues(V4TokenRegistry registry) => {
  'v4RadiusBase': registry.v4RadiusBase,
  'v4ShadowBase': registry.v4ShadowBase,
  'v4ContrastLevel': registry.v4ContrastLevel,
  'v4SurfaceTint': registry.v4SurfaceTint,
  'v4FontSizeScale': registry.v4FontSizeScale,
  'v4FontWeightDelta': registry.v4FontWeightDelta,
  'v4IconTone': registry.v4IconTone,
  'v4MotionAlpha': registry.v4MotionAlpha,
  'v4MotionShift': registry.v4MotionShift,
  'v4MotionOverlay': registry.v4MotionOverlay,
  'v4ElevLow': registry.v4ElevLow,
  'v4ElevMed': registry.v4ElevMed,
  'v4ElevHigh': registry.v4ElevHigh,
  'v4SpacingSmall': registry.v4SpacingSmall,
  'v4SpacingMedium': registry.v4SpacingMedium,
  'v4SpacingLarge': registry.v4SpacingLarge,
  'v4FontScaleBody': registry.v4FontScaleBody,
  'v4FontScaleTitle': registry.v4FontScaleTitle,
  'v4FontWeightBody': registry.v4FontWeightBody,
  'v4FontWeightTitle': registry.v4FontWeightTitle,
  'v4LetterSpacingDelta': registry.v4LetterSpacingDelta,
  'v4SurfaceNeutralLow': registry.v4SurfaceNeutralLow,
  'v4SurfaceNeutralHigh': registry.v4SurfaceNeutralHigh,
  'v4RoleAccentTone': registry.v4RoleAccentTone,
};

String _sectionReport(String name, List<String> issues) {
  final status = issues.isEmpty ? 'OK' : 'WARN';
  final buffer = StringBuffer();
  buffer.writeln('$name: $status');
  for (final issue in issues) {
    buffer.writeln('- $issue');
  }
  return buffer.toString().trimRight();
}

bool _isAscii(String text) {
  for (final code in text.codeUnits) {
    if (code < 0 || code > 127) return false;
  }
  return true;
}

Future<void> main() async {
  final code = await runV4PersonaMatConsistencyQA();
  if (code != 0) exit(code);
}
