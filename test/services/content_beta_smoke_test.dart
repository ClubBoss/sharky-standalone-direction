import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('content beta smoke', () {
    test('all JSONL entries parse with goal and explanation field', () async {
      final isFast = _isFastMode();
      final contentDir = Directory('content');
      expect(
        contentDir.existsSync(),
        isTrue,
        reason: 'content directory missing',
      );

      final jsonlFiles = await _collectJsonl(
        contentDir,
        limit: isFast ? 1 : null,
      );
      expect(jsonlFiles, isNotEmpty, reason: 'no content JSONL files found');

      for (final file in jsonlFiles) {
        final lines = await file.readAsLines();
        for (final raw in lines) {
          if (raw.trim().isEmpty) continue;
          late Map<String, dynamic> data;
          try {
            data = jsonDecode(raw) as Map<String, dynamic>;
          } catch (e) {
            fail('Failed to decode ${file.path}: $e');
          }
          final goal = data['goal'];
          final prompt = data['prompt'];
          final question = data['question'];
          final heroAction = data['hero_action'];
          expect(
            (goal is String && goal.trim().isNotEmpty) ||
                (prompt is String && prompt.trim().isNotEmpty) ||
                (question is String && question.trim().isNotEmpty) ||
                (heroAction is String && heroAction.trim().isNotEmpty),
            isTrue,
            reason: 'Missing goal/prompt/question/hero_action in ${file.path}',
          );
          final reaction = data['reaction_text'];
          final rationale = data['rationale'];
          final explanation = data['explanation'];
          expect(
            (reaction is String && reaction.trim().isNotEmpty) ||
                (rationale is String && rationale.trim().isNotEmpty) ||
                (explanation is String && explanation.trim().isNotEmpty),
            isTrue,
            reason:
                'Missing reaction_text/rationale/explanation in ${file.path}',
          );
        }
      }
    });
  });
}

bool _isFastMode() {
  final value =
      (Platform.environment['FAST_MODE'] ??
              Platform.environment['HEALTH_FAST'] ??
              '')
          .trim()
          .toLowerCase();
  return value == '1' || value == 'true';
}

Future<List<File>> _collectJsonl(Directory root, {int? limit}) async {
  final files = <File>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.jsonl')) {
      final path = entity.path.replaceAll('\\', '/');
      final isLegacy =
          path.startsWith('content/_legacy_archive/') ||
          path.contains('/_legacy_archive/');
      if (isLegacy) continue;
      files.add(entity);
      if (limit != null && files.length >= limit) break;
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}
