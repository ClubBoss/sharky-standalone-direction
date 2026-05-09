import 'dart:io';

import 'package:test/test.dart';

void main() {
  const bannedImports = <String>[
    'package:flutter/',
    'package:flutter_test/',
    'dart:ui',
  ];
  test('dart test files do not import Flutter symbols', () {
    final testDir = Directory('test/contracts');
    if (!testDir.existsSync()) {
      fail('`test/contracts` directory is missing');
    }

    final violations = <String>[];

    for (final entity in testDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final path = entity.path;
      if (!path.endsWith('.dart')) continue;
      if (path.endsWith('_flutter_test.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (!(line.startsWith('import') || line.startsWith('export'))) {
          continue;
        }
        for (final pattern in bannedImports) {
          if (line.contains(pattern)) {
            violations.add('$path:${i + 1} $line');
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      final message = StringBuffer()
        ..writeln('Found Flutter imports in dart-only tests:')
        ..writeln(violations.join('\n'));
      fail(message.toString());
    }
  });
}
