import 'dart:convert';
import 'dart:io';

String _checkFiles(List<String> paths) {
  for (final path in paths) {
    if (!File(path).existsSync()) {
      return 'FAIL';
    }
  }
  return 'PASS';
}

Future<bool> _checkAdviceApi() async {
  final result = await Process.run('dart', [
    'run',
    'tools/persona_advice_api.dart',
    'core:intro:001',
  ], runInShell: true);
  if (result.exitCode != 0) {
    return false;
  }
  try {
    jsonDecode(result.stdout.toString());
    return true;
  } catch (_) {
    return false;
  }
}

void main(List<String> args) async {
  final coreFiles = [
    'lib/ui_v2/persona/sharky_persona_state.dart',
    'lib/ui_v2/persona/sharky_persona_router.dart',
    'lib/ui_v2/persona/sharky_persona_rules.dart',
    'lib/ui_v2/persona/sharky_persona_events.dart',
    'lib/ui_v2/persona/sharky_persona_behavior.dart',
    'lib/ui_v2/persona/sharky_idle_cycle.dart',
    'lib/ui_v2/persona/sharky_personality_curve.dart',
    'lib/ui_v2/persona/global_persona_controller.dart',
  ];

  final surfaces = [
    'lib/ui_v2/components/sharky_persona_panel.dart',
    'lib/ui_v2/components/sharky_hint_balloon.dart',
    'lib/ui_v2/components/sharky_nav_cta.dart',
    'lib/ui_v2/components/sharky_reflection_card.dart',
  ];

  final adviceModel = [
    'lib/ui_v2/persona/persona_advice_model.dart',
    'lib/ui_v2/persona/persona_advice_loader.dart',
  ];

  final coreStatus = _checkFiles(coreFiles);
  final surfaceStatus = _checkFiles(surfaces);
  final adviceStatus = _checkFiles(adviceModel);
  final adviceApiStatus = await _checkAdviceApi() ? 'PASS' : 'FAIL';

  print('PERSONA-INTEGRITY:');
  print('core: $coreStatus');
  print('surfaces: $surfaceStatus');
  print('advice_model: $adviceStatus');
  print('advice_api: $adviceApiStatus');

  if ([
    coreStatus,
    surfaceStatus,
    adviceStatus,
    adviceApiStatus,
  ].every((status) => status == 'PASS')) {
    exit(0);
  }
  exit(1);
}
