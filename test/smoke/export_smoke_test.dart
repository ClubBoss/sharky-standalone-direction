import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Export Smoke', () {
    test('export/sessions directory is writable', () async {
      final dir = Directory('export/sessions');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      expect(await dir.exists(), true);
    });

    test('session export file creation succeeds', () async {
      final dir = Directory('export/sessions');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final testFile = File('export/sessions/smoke_test.json');
      await testFile.writeAsString('{"test": true}');
      expect(await testFile.exists(), true);
      await testFile.delete();
    });
  });
}
