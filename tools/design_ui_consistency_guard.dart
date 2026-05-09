import 'dart:io';

String _checkFiles(List<String> paths) {
  for (final path in paths) {
    if (!File(path).existsSync()) {
      return 'FAIL';
    }
  }
  return 'PASS';
}

bool _checkScreenImports(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return false;
  }
  final content = file.readAsStringSync();
  final tokens = "design_tokens.dart";
  return content.contains(tokens) &&
      content.contains('GlobalPersonaController');
}

void main(List<String> args) {
  final designFiles = [
    'lib/ui_v2/design/design_tokens.dart',
    'lib/ui_v2/design/design_layout.dart',
    'lib/ui_v2/design/design_typography.dart',
    'lib/ui_v2/design/design_containers.dart',
    'lib/ui_v2/design/design_interactions.dart',
  ];

  final personaFiles = [
    'lib/ui_v2/components/sharky_persona_panel.dart',
    'lib/ui_v2/components/sharky_hint_balloon.dart',
    'lib/ui_v2/components/sharky_nav_cta.dart',
    'lib/ui_v2/components/sharky_reflection_card.dart',
  ];

  final screens = [
    'lib/ui_v2/simulation/simulation_table_screen.dart',
    'lib/ui_v2/screens/player_profile_screen.dart',
    'lib/ui_v2/screens/module_summary_screen.dart',
    'lib/ui_v2/screens/module_launcher_screen.dart',
    'lib/ui_v2/screens/import_spots_screen.dart',
    'lib/ui_v2/screens/paste_spots_screen.dart',
    'lib/ui_v2/screens/tools_screen.dart',
    'lib/ui_v2/screens/settings_screen.dart',
  ];

  final designStatus = _checkFiles(designFiles);
  final personaStatus = _checkFiles(personaFiles);
  var screensStatus = 'PASS';
  for (final screen in screens) {
    if (!_checkScreenImports(screen)) {
      screensStatus = 'FAIL';
      break;
    }
  }

  print('DESIGN/UI CONSISTENCY:');
  print('design_files: $designStatus');
  print('persona_components: $personaStatus');
  print('screens_imports: $screensStatus');

  if (designStatus == 'PASS' &&
      personaStatus == 'PASS' &&
      screensStatus == 'PASS') {
    exit(0);
  }
  exit(1);
}
