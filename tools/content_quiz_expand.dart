import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tools/content_quiz_expand.dart <moduleId>');
    exit(1);
  }

  final moduleId = args.first;
  final quizFile = File('content/$moduleId/quiz.jsonl');
  if (!quizFile.existsSync()) {
    stderr.writeln('quiz.jsonl missing for $moduleId');
    exit(1);
  }

  final lines = quizFile
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (lines.length != 1) {
    print('[SKIP] real quiz');
    return;
  }

  bool placeholder = false;
  try {
    final decoded = jsonDecode(lines.first);
    if (decoded is Map &&
        decoded['q'] == 'Placeholder question?' &&
        decoded['a'] == 'Placeholder answer.') {
      placeholder = true;
    }
  } catch (_) {
    // treat as non-placeholder
  }

  if (!placeholder) {
    print('[SKIP] real quiz');
    return;
  }

  final enriched = [
    jsonEncode({
      'q': 'What is the core concept of this module?',
      'a': 'High-level explanation.',
    }),
    jsonEncode({
      'q': 'Give a practical example of applying the concept.',
      'a': 'Example description.',
    }),
    jsonEncode({
      'q': 'Name a common mistake learners make.',
      'a': 'Pitfall description.',
    }),
  ];

  quizFile.writeAsStringSync('${enriched.join('\n')}\n');
  print('[EXPANDED] quiz');
}
