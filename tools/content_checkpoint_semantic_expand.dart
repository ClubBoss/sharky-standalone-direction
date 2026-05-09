import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_checkpoint_semantic_expand.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final dir = Directory('content/$moduleId/checkpoints');
  if (!dir.existsSync()) {
    stderr.writeln('checkpoints/ missing for $moduleId');
    exit(1);
  }

  var expanded = false;

  bool isPlaceholder(File file) {
    final text = file.readAsStringSync();
    if (!text.startsWith('# Checkpoint')) return false;
    if (text.length >= 250) return false;
    final headers = text
        .split('\n')
        .where((line) => line.startsWith('##'))
        .toList();
    return headers.length <= 2;
  }

  void upgrade(File file) {
    file.writeAsStringSync('''# Checkpoint

## Core ideas to confirm
- Key concept
- Critical rule
- Common pitfall

## Mini self-test
Provide 2–3 reflection questions the learner should answer.

## Before moving on
Briefly describe what readiness looks like.
''');
  }

  for (final file in dir.listSync().whereType<File>().where(
    (file) => file.path.endsWith('.md'),
  )) {
    if (isPlaceholder(file)) {
      upgrade(file);
      expanded = true;
    }
  }

  if (expanded) {
    print('[EXPANDED] semantic checkpoints');
  } else {
    print('[SKIP] real checkpoints');
  }
}
