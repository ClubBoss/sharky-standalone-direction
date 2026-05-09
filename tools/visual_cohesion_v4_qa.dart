import 'dart:io';

import '../lib/ui_v2/theme/v4_token_registry.dart';

Future<int> runV4CohesionQA() async {
  final registry = const V4TokenRegistry();
  final tokens = <String, num>{
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

  final issues = <String>[];
  for (final entry in tokens.entries) {
    final key = entry.key;
    final value = entry.value;
    if (!_isAscii(key)) {
      issues.add('Non-ASCII token key: $key');
    }
    if (_isRadiusOrSpacing(key) && value < 0) {
      issues.add('Negative radius/spacing for $key: $value');
    }
    if (_isFontWeight(key) && (value < 0 || value > 900)) {
      issues.add('Font weight out of range for $key: $value');
    }
  }

  final warnings = <String>[];
  // Color alpha range cannot be inspected because registry does not expose colors.

  final buffer = StringBuffer();
  buffer.writeln('V4 Cohesion QA');
  buffer.writeln('Tokens inspected: ${tokens.length}');
  if (issues.isEmpty && warnings.isEmpty) {
    buffer.writeln('Status: PASS');
  } else {
    if (issues.isNotEmpty) {
      buffer.writeln('Structural failures (${issues.length}):');
      for (final issue in issues) {
        buffer.writeln('- $issue');
      }
    }
    if (warnings.isNotEmpty) {
      buffer.writeln('Warnings (${warnings.length}):');
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }
  }
  buffer.writeln('ASCII keys validated: ${tokens.keys.every(_isAscii)}');

  print(buffer.toString().trimRight());

  if (issues.isNotEmpty) return 2;
  if (warnings.isNotEmpty) return 1;
  return 0;
}

bool _isAscii(String text) {
  for (final code in text.codeUnits) {
    if (code < 0 || code > 127) return false;
  }
  return true;
}

Future<void> main() async {
  final code = await runV4CohesionQA();
  if (code != 0) {
    exit(code);
  }
}

bool _isRadiusOrSpacing(String key) =>
    key.contains('Elev') || key.contains('Radius') || key.contains('Spacing');

bool _isFontWeight(String key) => key.contains('FontWeight');
