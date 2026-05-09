import 'dart:io';

Future<String> _run(String command, List<String> args) async {
  final result = await Process.run(command, args, runInShell: true);
  return result.exitCode == 0 ? 'PASS' : 'FAIL';
}

Future<void> main(List<String> args) async {
  final stability = await _run('dart', [
    'run',
    'tools/stability_snapshot.dart',
  ]);
  final cohesion = await _run('dart', [
    'run',
    'tools/visual_persona_cohesion_sanity.dart',
  ]);
  final adaptive = await _run('dart', [
    'run',
    'tools/adaptive_layer_sanity.dart',
  ]);
  final designUi = await _run('dart', [
    'run',
    'tools/design_ui_consistency_guard.dart',
  ]);
  final persona = await _run('dart', [
    'run',
    'tools/persona_integrity_check.dart',
  ]);

  print('REGRESSION-GATE:');
  print('stability: $stability');
  print('cohesion: $cohesion');
  print('adaptive: $adaptive');
  print('design_ui: $designUi');
  print('persona: $persona');

  if ([
    stability,
    cohesion,
    adaptive,
    designUi,
    persona,
  ].every((status) => status == 'PASS')) {
    exit(0);
  }
  exit(1);
}
