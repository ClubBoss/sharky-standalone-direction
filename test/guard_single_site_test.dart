import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

String _readFile(File file) => file.readAsStringSync();

void main() {
  test('SpotKind canonical guard lives in one site', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib directory missing');

    final guardFiles = <File>[];
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      final content = _readFile(entity);
      if (content.contains('SpotKind must be append-only')) {
        guardFiles.add(entity);
      }
    }

    expect(
      guardFiles.length,
      1,
      reason:
          'expected a single canonical guard; found ${guardFiles.map((f) => f.path).toList()}',
    );

    final guardFile = guardFiles.single;
    final normalized = p.normalize(guardFile.path);
    expect(
      normalized.endsWith('lib/ui/session_player/models.dart'),
      isTrue,
      reason: 'canonical guard drifted to $normalized',
    );

    final content = _readFile(guardFile);
    expect(
      RegExp(r'_spotKindBaseline').allMatches(content).length,
      greaterThan(0),
      reason: '_spotKindBaseline missing from canonical guard site',
    );
    expect(
      RegExp(r'_spotKindGuard').allMatches(content).length,
      1,
      reason: 'guard helper should appear exactly once',
    );
    expect(
      content.contains('assert(() {'),
      isTrue,
      reason: 'guard must remain active (assert(() { ... }));',
    );
  });
}
