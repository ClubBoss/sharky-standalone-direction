import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_checkpoint_template.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final moduleDir = Directory('content/$moduleId');
  if (!moduleDir.existsSync()) {
    stderr.writeln('Module directory content/$moduleId missing');
    exit(1);
  }

  final checkpointDir = Directory('${moduleDir.path}/checkpoints');
  if (!checkpointDir.existsSync()) {
    stderr.writeln('checkpoints/ missing for $moduleId');
    exit(1);
  }

  final visibleFiles = checkpointDir.listSync().whereType<File>().where(
    (file) => !file.uri.pathSegments.last.startsWith('.'),
  );

  if (visibleFiles.isNotEmpty) {
    print('[SKIP] real checkpoints');
    return;
  }

  final template = File('${checkpointDir.path}/intro.md');
  template.writeAsStringSync('''# Checkpoint
Summarize what the learner should recall before moving on.
''');
  print('[SEEDED] checkpoints');
}
