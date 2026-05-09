import 'dart:io';

import '../lib/ui_v2/theme/v4_token_registry.dart';

Future<int> runV4VisualCohesionGate() async {
  final registry = const V4TokenRegistry();
  final groups = <String, Map<String, double>>{
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
      'v4FontWeightBody': registry.v4FontWeightBody.toDouble(),
      'v4FontWeightTitle': registry.v4FontWeightTitle.toDouble(),
      'v4LetterSpacingDelta': registry.v4LetterSpacingDelta,
    },
  };

  final issues = <String>[];
  var warn = false;
  for (final entry in groups.entries) {
    for (final token in entry.value.entries) {
      if (!_isAscii(token.key)) {
        issues.add('non-ASCII key: ${token.key}');
        continue;
      }
      if (token.value.isNaN) {
        issues.add('NaN value for ${token.key}');
        continue;
      }
      if (!token.value.isFinite || token.value < 0) {
        issues.add('invalid value for ${token.key}: ${token.value}');
        continue;
      }
      if (entry.key == 'typography' &&
          token.key.contains('FontScale') &&
          token.value <= 0) {
        issues.add('non-positive font scale for ${token.key}');
      }
      if (entry.key == 'typography' &&
          token.key.contains('LetterSpacing') &&
          token.value.abs() > 2) {
        warn = true;
        issues.add('large letter spacing for ${token.key}: ${token.value}');
      }
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('V4 Visual Cohesion Gate');
  buffer.writeln(
    'Tokens checked: ${groups.values.fold(0, (sum, map) => sum + map.length)}',
  );
  if (issues.isEmpty && !warn) {
    buffer.writeln('Status: PASS');
  } else {
    buffer.writeln('Status: ${issues.isEmpty ? 'WARN' : 'FAIL'}');
    for (final issue in issues) {
      buffer.writeln('- $issue');
    }
  }

  final personaFile = File('lib/ui_v2/persona/persona_renderer_v3.dart');
  final personaContent = personaFile.existsSync()
      ? personaFile.readAsStringSync()
      : '';
  final personaSymbols = <String>[
    'class PersonaRendererV3',
    'personaProfileModelOrNull',
    'personaProfileOverlayOrNull',
    'personaProfileBundleOrNull',
    'runtimePersonaProfileOrNull',
    'runtimePersonaLongSummaryOrNull',
    'personaProfileSafeSummary',
    'personaProfileSubtitleOrNull',
  ];
  final missingSymbols = <String>[];
  for (final symbol in personaSymbols) {
    if (!_isAscii(symbol)) continue;
    if (!personaContent.contains(symbol)) {
      missingSymbols.add(symbol);
    }
  }
  final symbolsOk = missingSymbols.isEmpty && personaContent.isNotEmpty;
  buffer.writeln('[persona_profile_surface]');
  buffer.writeln('symbols_ok: ${symbolsOk ? 'true' : 'false'}');
  buffer.writeln('missing: ${missingSymbols.join(',')}');
  print(buffer.toString().trimRight());

  if (missingSymbols.isNotEmpty) return 2;
  if (issues.isNotEmpty) return 2;
  if (warn) return 1;
  return 0;
}

Future<void> main() async {
  final code = await runV4VisualCohesionGate();
  if (code != 0) exit(code);
}

bool _isAscii(String text) {
  for (final code in text.codeUnits) {
    if (code < 0 || code > 127) return false;
  }
  return true;
}
