import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_quiz_semantic_expand.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final quiz = File('content/$moduleId/quiz.jsonl');
  if (!quiz.existsSync()) {
    stderr.writeln('quiz.jsonl missing for $moduleId');
    exit(1);
  }

  final lines = quiz
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (lines.length > 3) {
    print('[SKIP] real quiz');
    return;
  }

  for (final line in lines) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map) {
        print('[SKIP] real quiz');
        return;
      }
      final q = decoded['q'] as String?;
      final a = decoded['a'] as String?;
      if (q == null || a == null || q.length > 60 || a.length > 80) {
        print('[SKIP] real quiz');
        return;
      }
    } catch (_) {
      print('[SKIP] real quiz');
      return;
    }
  }

  final enriched = [
    jsonEncode({
      'q': 'What strategic principle defines this module?',
      'a': 'Explain the principle and its core purpose.',
    }),
    jsonEncode({
      'q': 'Describe a practical situation where this principle applies.',
      'a': 'Concrete scenario description.',
    }),
    jsonEncode({
      'q': 'What mistake do learners commonly make here?',
      'a': 'Pitfall description and correction.',
    }),
    jsonEncode({
      'q': 'How does this concept connect to later modules?',
      'a': 'Forward link explanation.',
    }),
    jsonEncode({
      'q': 'What is the simplest way to validate your intuition in this spot?',
      'a': 'Short heuristic or practical check.',
    }),
  ];

  quiz.writeAsStringSync('${enriched.join('\n')}\n');
  print('[EXPANDED] semantic quiz');
}
