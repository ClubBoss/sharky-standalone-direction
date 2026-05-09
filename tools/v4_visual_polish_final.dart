import 'dart:io';

import '../lib/ui_v2/theme/v4_theme_builder.dart';
import '../lib/ui_v2/theme/v4_token_registry.dart';

Future<int> runV4VisualPolishFinal() async {
  final registry = const V4TokenRegistry();
  final builder = V4ThemeDataBuilder();
  final cohesion = builder.componentCohesionPreview;

  final tokenIssues = <String>[];
  final registryWarnings = <String>[];
  final sections = <String, Map<String, double>>{
    'spacing': registry.spacingTokens,
    'radius': registry.radiusTokens,
    'elevation': registry.elevationTokens,
    'typography': registry.typographyTokens,
  };
  for (final entry in sections.entries) {
    for (final token in entry.value.entries) {
      if (!_isAscii(token.key)) {
        tokenIssues.add('non-ASCII key: ${token.key}');
        continue;
      }
      if (!token.value.isFinite) {
        tokenIssues.add('${token.key} not finite');
        continue;
      }
      if ((entry.key == 'spacing' ||
              entry.key == 'radius' ||
              entry.key == 'elevation') &&
          token.value < 0) {
        tokenIssues.add('${token.key} negative: ${token.value}');
      }
    }
  }
  final letterSpacing = registry.v4LetterSpacingDelta;
  if (letterSpacing.isNaN || !letterSpacing.isFinite) {
    tokenIssues.add('letter spacing not finite');
  } else if (letterSpacing < -2.0 || letterSpacing > 2.0) {
    tokenIssues.add('letter spacing outside [-2,2]: $letterSpacing');
  }
  if (letterSpacing > 1.0) {
    registryWarnings.add('letter spacing high: $letterSpacing');
  }
  if (!cohesion.containsKey('radiusBase') ||
      !cohesion.containsKey('spacingSm') ||
      !cohesion.containsKey('spacingMd') ||
      !cohesion.containsKey('elevationLow')) {
    tokenIssues.add('cohesion preview missing radius/spacing/elevation key');
  }
  final report = StringBuffer();
  report.writeln('V4 Visual Polish Final');
  report.writeln(_section('tokens', tokenIssues));
  report.writeln(
    _section(
      'typography',
      tokenIssues.where((e) => e.contains('letter spacing')).toList(),
    ),
  );
  report.writeln(_section('spacing', tokenIssues));
  report.writeln(_section('registry', registryWarnings));

  final finalTokens = sections.values.expand((map) => map.keys);
  final tokenSet = <String>{};
  final duplicateTokens = <String>[];
  for (final key in finalTokens) {
    if (!_isAscii(key)) continue;
    if (!tokenSet.add(key)) duplicateTokens.add(key);
  }
  final tokensOk = duplicateTokens.isEmpty && tokenIssues.isEmpty;

  final builderContent = File(
    'lib/ui_v2/theme/v4_theme_builder.dart',
  ).readAsStringSync();
  final mergeMethods = [
    'mergeBodyStyleV4',
    'mergeTitleStyleV4',
    'mergeSurfaceV4',
  ];
  final missingMergeMethods = mergeMethods
      .where((method) => !builderContent.contains(method))
      .toList();
  final mergesUseIsActive = builderContent.contains('isActive');
  final usesAppRoot =
      builderContent.contains('AppRoot') || builderContent.contains('appRoot');
  final deprecatedUsage = builderContent.contains('MaterialStatePropertyAll')
      ? 'MaterialStatePropertyAll'
      : '';
  final mergesOk =
      missingMergeMethods.isEmpty &&
      mergesUseIsActive &&
      !usesAppRoot &&
      deprecatedUsage.isEmpty;

  final personaContent = File(
    'lib/ui_v2/persona/persona_renderer_v3.dart',
  ).readAsStringSync();
  final personaLimitsOk =
      personaContent.contains('substring(0, 80)') &&
      personaContent.contains('substring(0, 500)') &&
      personaContent.contains('substring(0, 40)');

  report.writeln('[v4_release_ready_polish]');
  report.writeln('tokens_ok: ${tokensOk ? 'true' : 'false'}');
  report.writeln('merges_ok: ${mergesOk ? 'true' : 'false'}');
  report.writeln(
    'deprecated_usage: ${deprecatedUsage.isEmpty ? 'none' : deprecatedUsage}',
  );
  report.writeln('persona_limits_ok: ${personaLimitsOk ? 'true' : 'false'}');
  final missingItems = <String>[
    if (!tokensOk) 'duplicate_tokens:${duplicateTokens.join(',')}',
    if (missingMergeMethods.isNotEmpty)
      'merge_methods:${missingMergeMethods.join(',')}',
    if (!personaLimitsOk) 'persona_limits',
  ];
  report.writeln('missing: ${missingItems.join(',')}');

  print(report.toString().trimRight());

  if (!tokensOk ||
      !mergesOk ||
      !personaLimitsOk ||
      deprecatedUsage.isNotEmpty) {
    return 2;
  }
  if (tokenIssues.isNotEmpty) {
    return 2;
  }
  if (registryWarnings.isNotEmpty) {
    return 1;
  }
  return 0;
}

String _section(String name, List<String> issues) {
  if (issues.isEmpty) return '$name: OK';
  final buffer = StringBuffer();
  buffer.writeln('$name: WARN (${issues.length})');
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
  final code = await runV4VisualPolishFinal();
  if (code != 0) exit(code);
}
