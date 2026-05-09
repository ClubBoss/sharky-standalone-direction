import 'dart:io';

import 'package:flutter/material.dart';

import '../lib/ui_v2/app_root.dart';
import '../lib/ui_v2/persona/persona_renderer_v3.dart';
import '../lib/ui_v2/theme/v4_token_registry.dart';
import '../lib/ui_v2/theme/v4_theme_builder.dart';

Future<int> runV4PersonaMatVisualConsistencyGate() async {
  final renderer = PersonaRendererV3();
  final registry = const V4TokenRegistry();
  final builder = V4ThemeDataBuilder();
  final personaBundle = renderer.personaProfileBundleOrNull;
  final isV4Active = appRoot.isV4RuntimeActivated;
  final personaIssues = <String>[];
  if (!isV4Active && personaBundle != null) {
    personaIssues.add('Persona bundle exposed while V4 inactive');
  }
  if (isV4Active && personaBundle == null) {
    personaIssues.add('V4 active but persona bundle missing');
  }
  final themeIssues = <String>[];
  try {
    final theme = builder.build(themeBuilderBase(), isV4Active, registry);
    if (theme.textTheme.bodyLarge?.fontSize == null) {
      themeIssues.add('bodyLarge size missing');
    }
    if (theme.cardTheme.elevation == null) {
      themeIssues.add('card elevation missing');
    }
  } catch (e) {
    themeIssues.add('Theme build failed: $e');
  }
  final matIssues = <String>[];
  final tokens = registryValues(registry);
  tokens.forEach((key, value) {
    if (value.isNegative) matIssues.add('Token $key negative: $value');
  });
  final buffer = StringBuffer();
  buffer.writeln('V4 Persona-MAT Visual Consistency Gate');
  buffer.writeln(_section('persona_bundle', personaIssues));
  buffer.writeln(_section('theme_runtime', themeIssues));
  buffer.writeln(_section('mat_theme', themeIssues));
  buffer.writeln(_section('token_alignment', matIssues));

  final personaContent = File(
    'lib/ui_v2/persona/persona_renderer_v3.dart',
  ).readAsStringSync();
  final personaSymbols = <String>{
    'personaProfileModelOrNull',
    'personaProfileOverlayOrNull',
    'personaProfileBundleOrNull',
    'runtimePersonaProfileOrNull',
    'runtimePersonaLongSummaryOrNull',
    'personaProfileSafeSummary',
    'personaProfileSubtitleOrNull',
  };
  final missingPersonaSymbols = personaSymbols
      .where((symbol) => !personaContent.contains(symbol))
      .toList();
  final lengthConstraintOk =
      personaContent.contains('length > 40') &&
      personaContent.contains('substring(0, 40)');

  final tokenRegistryContent = File(
    'lib/ui_v2/theme/v4_token_registry.dart',
  ).readAsStringSync();
  final tokenGetters = <String>{
    'spacingTokens',
    'radiusTokens',
    'elevationTokens',
    'typographyTokens',
  };
  final missingTokenGetters = tokenGetters
      .where((getter) => !tokenRegistryContent.contains(getter))
      .toList();

  final builderContent = File(
    'lib/ui_v2/theme/v4_theme_builder.dart',
  ).readAsStringSync();
  final themeSymbols = <String>{
    'buildTextThemeV4',
    'mergeBodyStyleV4',
    'mergeTitleStyleV4',
  };
  final missingThemeSymbols = themeSymbols
      .where((symbol) => !builderContent.contains(symbol))
      .toList();
  final themeUsesIsActive = builderContent.contains('isActive');

  final matContent = File(
    'lib/ui_v2/app_shell/material_app_shell.dart',
  ).readAsStringSync();
  final personaImportsBuilder = personaContent.contains(
    'v4_theme_builder.dart',
  );
  final builderImportsMat = builderContent.contains('material_app_shell.dart');
  final matImportsPersona = matContent.contains('persona_renderer_v3.dart');
  final circularImports = <String>[];
  if (personaImportsBuilder && builderImportsMat && matImportsPersona) {
    circularImports.add(
      'persona_renderer_v3.dart->v4_theme_builder.dart->material_app_shell.dart',
    );
  }

  final personaOk = missingPersonaSymbols.isEmpty && lengthConstraintOk;
  final v4TokensOk = missingTokenGetters.isEmpty;
  final v4ThemeOk = missingThemeSymbols.isEmpty && themeUsesIsActive;
  final missingList = <String>[];
  if (!personaOk) missingList.add('persona_symbols');
  if (!lengthConstraintOk) missingList.add('subtitle_length_check');
  if (missingTokenGetters.isNotEmpty) {
    missingList.add('token_getters:${missingTokenGetters.join(',')}');
  }
  if (!v4ThemeOk) missingList.add('v4_theme_methods');
  if (circularImports.isNotEmpty) {
    missingList.add('circular_imports:${circularImports.join(',')}');
  }

  buffer.writeln('[persona_v4_mat_consistency_final]');
  buffer.writeln('persona_ok: ${personaOk ? 'true' : 'false'}');
  buffer.writeln('v4_tokens_ok: ${v4TokensOk ? 'true' : 'false'}');
  buffer.writeln('v4_theme_ok: ${v4ThemeOk ? 'true' : 'false'}');
  buffer.writeln('circular_imports: ${circularImports.join(',')}');
  buffer.writeln('missing: ${missingList.join(',')}');

  print(buffer.toString().trimRight());
  if (!personaOk || !v4TokensOk || !v4ThemeOk || circularImports.isNotEmpty) {
    return 2;
  }
  final hasFailures = [personaIssues, themeIssues, matIssues].any(
    (list) => list.any(
      (entry) => entry.contains('missing') || entry.contains('failed'),
    ),
  );
  final hasWarnings =
      [personaIssues, themeIssues, matIssues].any((list) => list.isNotEmpty) &&
      !hasFailures;
  if (hasFailures) return 2;
  if (hasWarnings) return 1;
  return 0;
}

Future<void> main() async {
  final code = await runV4PersonaMatVisualConsistencyGate();
  if (code != 0) exit(code);
}

ThemeData themeBuilderBase() => ThemeData.light();

String _section(String name, List<String> issues) {
  if (issues.isEmpty) return '$name: OK';
  return '$name: WARN (${issues.length})\n${issues.map((e) => '- $e').join('\n')}';
}

Map<String, double> registryValues(V4TokenRegistry registry) => {
  'v4RadiusBase': registry.v4RadiusBase,
  'v4SpacingSmall': registry.v4SpacingSmall,
  'v4SpacingMedium': registry.v4SpacingMedium,
  'v4SpacingLarge': registry.v4SpacingLarge,
  'v4ElevLow': registry.v4ElevLow,
  'v4ElevMed': registry.v4ElevMed,
  'v4ElevHigh': registry.v4ElevHigh,
  'v4FontScaleBody': registry.v4FontScaleBody,
  'v4FontScaleTitle': registry.v4FontScaleTitle,
  'v4FontWeightBody': registry.v4FontWeightBody.toDouble(),
  'v4FontWeightTitle': registry.v4FontWeightTitle.toDouble(),
};
