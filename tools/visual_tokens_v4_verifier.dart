import 'dart:io';

import '../lib/ui_v2/theme/v4_token_registry.dart';

class _VerificationResult {
  const _VerificationResult(this.group, this.issues);
  final String group;
  final List<String> issues;
  bool get isEmpty => issues.isEmpty;
}

Future<int> runV4VisualTokensVerification() async {
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
    'motion': {
      'v4MotionAlpha': registry.v4MotionAlpha,
      'v4MotionShift': registry.v4MotionShift,
      'v4MotionOverlay': registry.v4MotionOverlay,
    },
    'tone': {
      'v4SurfaceTint': registry.v4SurfaceTint,
      'v4ContrastLevel': registry.v4ContrastLevel,
      'v4SurfaceNeutralLow': registry.v4SurfaceNeutralLow,
      'v4SurfaceNeutralHigh': registry.v4SurfaceNeutralHigh,
      'v4RoleAccentTone': registry.v4RoleAccentTone,
    },
  };

  final results = <_VerificationResult>[];
  for (final entry in groups.entries) {
    final issues = <String>[];
    final tokens = entry.value;
    for (final token in tokens.entries) {
      final key = token.key;
      final value = token.value;
      if (!_isAscii(key)) {
        issues.add('non-ASCII key: $key');
      }
      if (value.isNaN) {
        issues.add('NaN value for $key');
        continue;
      }
      if (value.isInfinite) {
        issues.add('Infinite value for $key');
        continue;
      }
      if (value < 0) {
        issues.add('Negative value for $key: $value');
      }
      if (entry.key == 'typography' &&
          key.contains('FontScale') &&
          value <= 0) {
        issues.add('Non-positive font scale for $key: $value');
      }
      if (entry.key == 'typography' &&
          key.contains('LetterSpacing') &&
          !_isFinite(value)) {
        issues.add('Non-finite letter spacing for $key');
      }
      if (entry.key == 'typography' &&
          key.contains('FontWeight') &&
          (value < 0 || value > 900)) {
        issues.add('FontWeight out of range for $key: $value');
      }
    }
    results.add(_VerificationResult(entry.key, issues));
  }

  final buffer = StringBuffer();
  buffer.writeln('V4 Visual Tokens Verification');
  var failed = false;
  var warned = false;
  for (final result in results) {
    if (result.isEmpty) {
      buffer.writeln('${result.group}: OK');
      continue;
    }
    final level = result.issues.any((issue) => issue.contains('Negative'))
        ? 'FAIL'
        : 'WARN';
    if (level == 'FAIL') failed = true;
    if (level == 'WARN') warned = true;
    buffer.writeln('${result.group}: $level (${result.issues.length})');
    for (final issue in result.issues) {
      buffer.writeln('- $issue');
    }
  }

  print(buffer.toString().trimRight());
  if (failed) return 2;
  if (warned) return 1;
  return 0;
}

bool _isAscii(String text) {
  for (final code in text.codeUnits) {
    if (code < 0 || code > 127) return false;
  }
  return true;
}

Future<void> main() async {
  final code = await runV4VisualTokensVerification();
  if (code != 0) exit(code);
}

bool _isFinite(num value) {
  if (value is double) return value.isFinite;
  return true;
}
