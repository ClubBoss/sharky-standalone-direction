import 'dart:io';

void main() {
  final files = [
    'lib/ui_v2/design/design_tokens.dart',
    'lib/ui_v2/design/design_typography.dart',
    'lib/ui_v2/design/design_layout.dart',
    'lib/ui_v2/design/design_containers.dart',
    'lib/ui_v2/design/design_interactions.dart',
    'lib/ui_v2/components/design_button.dart',
    'lib/ui_v2/components/design_panel.dart',
    'lib/ui_v2/components/design_card.dart',
    'lib/ui_v2/components/design_list_tile.dart',
    'lib/ui_v2/components/design_text_field.dart',
    'lib/ui_v2/components/design_launcher_tile.dart',
    'lib/ui_v2/components/design_animated_transition.dart',
    'lib/ui_v2/components/sharky_persona_panel.dart',
    'lib/ui_v2/components/sharky_hint_balloon.dart',
    'lib/ui_v2/components/sharky_nav_cta.dart',
    'lib/ui_v2/components/sharky_reflection_card.dart',
    'lib/ui_v2/components/xp_progress_bar.dart',
    'lib/ui_v2/components/mastery_indicator.dart',
    'lib/ui_v2/components/traits_list.dart',
    'lib/ui_v2/motion/motion_primitives.dart',
    'lib/ui_v2/screens/module_launcher_screen.dart',
    'lib/ui_v2/screens/module_summary_screen.dart',
    'lib/ui_v2/screens/player_profile_screen.dart',
    'lib/ui_v2/screens/import_spots_screen.dart',
    'lib/ui_v2/screens/paste_spots_screen.dart',
    'lib/ui_v2/screens/tools_screen.dart',
    'lib/ui_v2/screens/settings_screen.dart',
    'lib/ui_v2/simulation/simulation_table_screen.dart',
  ];

  final missingFiles = _missing(files);
  final baseFilesOk = missingFiles.isEmpty;

  final colorsOk = _fileContainsAll('lib/ui_v2/design/design_tokens.dart', [
    'textSecondary',
    'surfaceBackground',
    'surfaceElevated',
    'accentStrong',
    'borderSubtle',
  ]);
  final contrastOk = _fileContainsAll('lib/ui_v2/design/design_tokens.dart', [
    'class ColorContrastSpec',
  ]);
  final typographyOk = _fileContainsAll(
    'lib/ui_v2/design/design_typography.dart',
    [
      'baseLineHeight',
      'bodyLineHeight',
      'captionLineHeight',
      'titleLineHeight',
    ],
  );
  final spacingOk = _fileContainsAll('lib/ui_v2/design/design_layout.dart', [
    'vspaceBase',
    'vspaceSmall',
    'vspaceMedium',
    'vspaceLarge',
  ]);
  final containersOk = _fileContainsAll(
    'lib/ui_v2/design/design_containers.dart',
    ['surfaceElevated', 'surfaceBackground', 'borderSubtle'],
  );
  final motionOk = _fileContainsAll('lib/ui_v2/motion/motion_primitives.dart', [
    'fadeScale(',
  ]);

  final personaFiles = [
    'lib/ui_v2/components/sharky_persona_panel.dart',
    'lib/ui_v2/components/sharky_hint_balloon.dart',
    'lib/ui_v2/components/sharky_nav_cta.dart',
    'lib/ui_v2/components/sharky_reflection_card.dart',
  ];
  final personaOk = _missing(personaFiles).isEmpty;

  final screenFiles = [
    'lib/ui_v2/simulation/simulation_table_screen.dart',
    'lib/ui_v2/screens/player_profile_screen.dart',
    'lib/ui_v2/screens/module_summary_screen.dart',
    'lib/ui_v2/screens/module_launcher_screen.dart',
    'lib/ui_v2/screens/tools_screen.dart',
    'lib/ui_v2/screens/settings_screen.dart',
  ];
  final screensOk = _missing(screenFiles).isEmpty;

  final overallOk = [
    baseFilesOk,
    colorsOk,
    contrastOk,
    typographyOk,
    spacingOk,
    containersOk,
    motionOk,
    personaOk,
    screensOk,
  ].every((value) => value);

  print('Visual Cohesion v3: ${overallOk ? 'PASS' : 'FAIL'}');
  print('Base Files: ${baseFilesOk ? 'PASS' : 'FAIL'}');
  if (!baseFilesOk) {
    for (final m in missingFiles) {
      print('Missing: $m');
    }
  }
  print('Color Tokens: ${colorsOk ? 'PASS' : 'FAIL'}');
  print('Color Contrast Spec: ${contrastOk ? 'PASS' : 'FAIL'}');
  print('Typography Tokens: ${typographyOk ? 'PASS' : 'FAIL'}');
  print('Spacing Tokens: ${spacingOk ? 'PASS' : 'FAIL'}');
  print('Design Containers Palette: ${containersOk ? 'PASS' : 'FAIL'}');
  print('Motion Primitives: ${motionOk ? 'PASS' : 'FAIL'}');
  print('Persona Surfaces: ${personaOk ? 'PASS' : 'FAIL'}');
  print('Φ-Series Screens: ${screensOk ? 'PASS' : 'FAIL'}');
  if (overallOk) {
    print('Φ-Series v2: DESIGN LAYER OK');
    return;
  }
  print('Φ-Series v2: DESIGN LAYER FAIL');
  exit(1);
}

List<String> _missing(List<String> paths) {
  return paths.where((path) => !File(path).existsSync()).toList();
}

bool _fileContainsAll(String path, List<String> snippets) {
  final file = File(path);
  if (!file.existsSync()) {
    return false;
  }
  final content = file.readAsStringSync();
  return snippets.every(content.contains);
}
