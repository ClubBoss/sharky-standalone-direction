import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('content/ missing');
    exit(1);
  }

  final requiredFiles = {
    'recap.md': () => '# Recap\n',
    'quiz.jsonl': () => '',
    'metadata.json': () => '{}\n',
  };
  final requiredDirs = ['drills', 'demos', 'checkpoints'];

  for (final module in root.listSync().whereType<Directory>()) {
    final moduleId = module.uri.pathSegments.lastWhere(
      (element) => element.isNotEmpty,
    );
    final created = <String>[];

    for (final dir in requiredDirs) {
      final target = Directory('${module.path}/$dir');
      if (!target.existsSync()) {
        target.createSync(recursive: true);
        created.add('$dir/');
      }
    }

    for (final entry in requiredFiles.entries) {
      final filePath = '${module.path}/${entry.key}';
      final file = File(filePath);
      if (!file.existsSync()) {
        file.writeAsStringSync(entry.value());
        created.add(entry.key);
      }
    }

    if (created.isEmpty) {
      print('[OK] $moduleId');
    } else {
      print('[FIXED] $moduleId -> ${created.join(', ')}');
    }
  }
}
