import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/training_pack_template_validator.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';

void main() {
  group('Content Tools Smoke', () {
    test('content directory exists', () {
      final contentDir = Directory('content');
      expect(contentDir.existsSync(), true);
    });

    test('content validation helper runs', () async {
      final contentDir = Directory('content');
      if (!contentDir.existsSync()) {
        return;
      }
      final files = contentDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.jsonl'))
          .toList();
      expect(files, isNotEmpty);
    });

    test('ASCII validation helper works', () {
      final ascii = 'test';
      final nonAscii = 'тест';
      expect(_isAsciiOnly(ascii), true);
      expect(_isAsciiOnly(nonAscii), false);
    });

    test('TrainingPackTemplateValidator instantiates', () {
      final validator = TrainingPackTemplateValidator();
      expect(validator, isNotNull);
    });

    test('HeroPosition enum contains standard positions', () {
      expect(HeroPosition.values, contains(HeroPosition.btn));
      expect(HeroPosition.values, contains(HeroPosition.bb));
      expect(HeroPosition.values, contains(HeroPosition.sb));
    });

    test('JSONL file parsing smoke test', () async {
      final contentDir = Directory('content');
      if (!contentDir.existsSync()) return;

      final jsonlFiles = contentDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.jsonl'))
          .take(1)
          .toList();

      if (jsonlFiles.isEmpty) return;

      final content = await jsonlFiles.first.readAsString();
      final lines = content.split('\n').where((l) => l.trim().isNotEmpty);

      for (final line in lines.take(5)) {
        final parsed = jsonDecode(line);
        expect(parsed, isA<Map>());
      }
    });
  });
}

bool _isAsciiOnly(String str) {
  for (int i = 0; i < str.length; i++) {
    if (str.codeUnitAt(i) > 127) return false;
  }
  return true;
}
