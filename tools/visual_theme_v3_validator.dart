import 'dart:io';

const files = [
  'ui_v2/_theme_v3/theme_tokens_v3.txt',
  'ui_v2/_theme_v3/theme_surfaces_v3.txt',
  'ui_v2/_theme_v3/component_surface_bindings_v3.txt',
  'ui_v2/_theme_v3/motion_primitives_v3.txt',
  'ui_v2/_theme_v3/visual_cohesion_map_v3.txt',
];

Future<void> main() async {
  for (final path in files) {
    final file = File(path);
    if (!await file.exists()) {
      stderr.writeln('Missing file: $path');
      exit(1);
    }
    final lines = await file.readAsLines();
    var lineNumber = 0;
    for (final raw in lines) {
      lineNumber++;
      final line = raw.trim();
      if (line.isEmpty) {
        stderr.writeln('$path line $lineNumber is empty');
        exit(1);
      }
      if (line.contains(' ')) {
        stderr.writeln('$path line $lineNumber contains spaces');
        exit(1);
      }
      if (!line.runes.every((r) => r >= 32 && r <= 126)) {
        stderr.writeln('$path line $lineNumber is not ASCII');
        exit(1);
      }
    }
  }
  stdout.writeln('OK: Visual Theme V3 valid');
}
