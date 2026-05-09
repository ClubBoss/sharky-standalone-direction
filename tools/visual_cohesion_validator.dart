import 'dart:io';

Future<void> main() async {
  final paths = [
    'ui_v2/_visual/theme_tokens.txt',
    'ui_v2/_visual/component_families.txt',
    'ui_v2/_visual/layout_patterns.txt',
    'ui_v2/_visual/motion_primitives.txt',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!await file.exists()) {
      stderr.writeln('Missing file: $path');
      exit(1);
    }
    final lines = await file.readAsLines();
    final entries = <String>[];
    final seen = <String>{};
    var lineNumber = 0;
    for (final raw in lines) {
      lineNumber++;
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (!isAscii(line)) {
        stderr.writeln('$path line $lineNumber has non-ASCII characters');
        exit(1);
      }
      if (!seen.add(line)) {
        stderr.writeln('$path line $lineNumber duplicates $line');
        exit(1);
      }
      entries.add(line);
    }
    if (entries.length < 3) {
      stderr.writeln('$path contains fewer than 3 entries');
      exit(1);
    }
  }
  stdout.writeln('OK: Visual cohesion valid');
}

bool isAscii(String text) => text.runes.every((r) => r >= 32 && r <= 126);
