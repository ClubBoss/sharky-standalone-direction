import 'dart:io';

String _checkFiles(List<String> paths) {
  for (final path in paths) {
    if (!File(path).existsSync()) {
      return 'FAIL';
    }
  }
  return 'PASS';
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

  final adaptiveFiles = [
    'lib/ui_v2/persona/persona_advice_model.dart',
    'lib/ui_v2/persona/persona_advice_loader.dart',
    'lib/ui_v2/persona/global_persona_controller.dart',
  ];

  final designStatus = _checkFiles(designFiles);
  final personaStatus = _checkFiles(personaFiles);
  final adaptiveStatus = _checkFiles(adaptiveFiles);

  print('COHESION:');
  print('design: $designStatus');
  print('persona_components: $personaStatus');
  print('adaptive_layer: $adaptiveStatus');

  if (designStatus == 'PASS' &&
      personaStatus == 'PASS' &&
      adaptiveStatus == 'PASS') {
    exit(0);
  }
  exit(1);
}
