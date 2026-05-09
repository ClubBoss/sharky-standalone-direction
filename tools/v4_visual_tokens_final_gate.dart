import 'dart:io';

import '../lib/ui_v2/theme/v4_token_registry.dart';

Future<int> runV4VisualTokensFinalGate() async {
  final registry = const V4TokenRegistry();
  final groups = <String, Map<String, num>>{
    'spacing': {
      'v4SpacingSmall': registry.v4SpacingSmall,
      'v4SpacingMedium': registry.v4SpacingMedium,
      'v4SpacingLarge': registry.v4SpacingLarge,
    },
    'radius': {'v4RadiusBase': registry.v4RadiusBase},
    'elevation': {
      'v4ElevLow': registry.v4ElevLow,
      'v4ElevMed': registry.v4ElevMed,
      'v4ElevHigh': registry.v4ElevHigh,
    },
    'typography': {
      'v4FontScaleBody': registry.v4FontScaleBody,
      'v4FontScaleTitle': registry.v4FontScaleTitle,
      'v4FontWeightBody': registry.v4FontWeightBody,
      'v4FontWeightTitle': registry.v4FontWeightTitle,
      'v4LetterSpacingDelta': registry.v4LetterSpacingDelta,
    },
    'registry': {
      'v4ContrastLevel': registry.v4ContrastLevel,
      'v4SurfaceTint': registry.v4SurfaceTint,
      'v4IconTone': registry.v4IconTone,
      'v4MotionAlpha': registry.v4MotionAlpha,
      'v4MotionShift': registry.v4MotionShift,
      'v4MotionOverlay': registry.v4MotionOverlay,
      'v4SurfaceNeutralLow': registry.v4SurfaceNeutralLow,
      'v4SurfaceNeutralHigh': registry.v4SurfaceNeutralHigh,
      'v4RoleAccentTone': registry.v4RoleAccentTone,
    },
  };

  int failures = 0;
  int warns = 0;
  final buffer = StringBuffer()..writeln('V4 Visual Tokens Final Gate');
  for (final entry in groups.entries) {
    buffer.writeln('${entry.key}:');
    for (final token in entry.value.entries) {
      final key = token.key;
      final value = token.value;
      if (!_isAscii(key)) {
        buffer.writeln('- INVALID key not ASCII: $key');
        failures++;
        continue;
      }
      if (!value.isFinite) {
        buffer.writeln('- INVALID $key not finite');
        failures++;
        continue;
      }
      if ((entry.key == 'spacing' ||
              entry.key == 'radius' ||
              entry.key == 'elevation') &&
          value < 0) {
        buffer.writeln('- INVALID $key negative: $value');
        failures++;
        continue;
      }
      if (entry.key == 'typography') {
        if (key.contains('FontScale') && value <= 0) {
          buffer.writeln('- INVALID $key <= 0: $value');
          failures++;
          continue;
        }
        if (key.contains('FontWeight') && (value < 100 || value > 900)) {
          buffer.writeln('- INVALID $key out of range: $value');
          failures++;
          continue;
        }
        if (key.contains('LetterSpacing') && value.abs() > 2.5) {
          buffer.writeln('- WARN $key large spacing: $value');
          warns++;
          continue;
        }
      }
    }
    if (entry.key == 'registry') {
      buffer.writeln('- registry tokens inspected');
    }
  }
  final status = failures > 0
      ? 'FAIL'
      : warns > 0
      ? 'WARN'
      : 'PASS';
  buffer.writeln('Summary: $status');

  final spacingOkMissing = <String>[];
  final radiusOkMissing = <String>[];
  final elevationOkMissing = <String>[];
  final typographyOkMissing = <String>[];

  final spacingOk = _validateNonNegativeTokens(
    registry.spacingTokens,
    spacingOkMissing,
  );
  final radiusOk = _validateNonNegativeTokens(
    registry.radiusTokens,
    radiusOkMissing,
  );
  final elevationOk = _validateNonNegativeTokens(
    registry.elevationTokens,
    elevationOkMissing,
  );
  final typographyOk = _validateTypographyTokens(
    registry.typographyTokens,
    typographyOkMissing,
  );

  final tokenMissing = [
    ...spacingOkMissing,
    ...radiusOkMissing,
    ...elevationOkMissing,
    ...typographyOkMissing,
  ];

  buffer.writeln('[token_shapes_final]');
  buffer.writeln('spacing_ok: ${spacingOk ? 'true' : 'false'}');
  buffer.writeln('radius_ok: ${radiusOk ? 'true' : 'false'}');
  buffer.writeln('elevation_ok: ${elevationOk ? 'true' : 'false'}');
  buffer.writeln('typography_ok: ${typographyOk ? 'true' : 'false'}');
  buffer.writeln('missing: ${tokenMissing.join(',')}');

  print(buffer.toString().trimRight());
  if (!spacingOk || !radiusOk || !elevationOk || !typographyOk) return 2;
  if (failures > 0) return 2;
  if (warns > 0) return 1;
  return 0;
}

Future<void> main() async {
  final code = await runV4VisualTokensFinalGate();
  if (code != 0) exit(code);
}

bool _isAscii(String text) {
  for (final code in text.codeUnits) {
    if (code < 0 || code > 127) return false;
  }
  return true;
}

bool _validateNonNegativeTokens(Map<String, num> tokens, List<String> missing) {
  var ok = true;
  for (final entry in tokens.entries) {
    final key = entry.key;
    final value = entry.value.toDouble();
    if (!_isAscii(key) || !value.isFinite) {
      missing.add(key);
      ok = false;
      continue;
    }
    if (value < 0) {
      missing.add(key);
      ok = false;
    }
  }
  return ok;
}

bool _validateTypographyTokens(Map<String, num> tokens, List<String> missing) {
  var ok = true;
  for (final entry in tokens.entries) {
    final key = entry.key;
    final value = entry.value.toDouble();
    if (!_isAscii(key) || !value.isFinite) {
      missing.add(key);
      ok = false;
      continue;
    }
    if (key.contains('FontScale') && value <= 0) {
      missing.add(key);
      ok = false;
      continue;
    }
    if (key.contains('FontWeight') && (value < 100 || value > 900)) {
      missing.add(key);
      ok = false;
      continue;
    }
    if (key.contains('LetterSpacing') && value.abs() > 2.0) {
      missing.add(key);
      ok = false;
    }
  }
  return ok;
}
