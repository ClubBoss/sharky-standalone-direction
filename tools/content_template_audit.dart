import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('content/ missing');
    exit(1);
  }

  final requiredFiles = ['recap.md', 'quiz.jsonl', 'metadata.json'];
  final requiredDirs = ['drills', 'demos', 'checkpoints'];
  var missingCount = 0;

  for (final module in root.listSync().whereType<Directory>()) {
    final moduleId = module.uri.pathSegments.lastWhere(
      (element) => element.isNotEmpty,
    );
    final missing = <String>[];

    for (final file in requiredFiles) {
      if (!File('${module.path}/$file').existsSync()) {
        missing.add(file);
      }
    }

    for (final dir in requiredDirs) {
      if (!Directory('${module.path}/$dir').existsSync()) {
        missing.add('$dir/');
      }
    }

    if (missing.isEmpty) {
      print('[OK] $moduleId');
    } else {
      print('[MISS] $moduleId -> ${missing.join(', ')}');
      missingCount++;
    }
  }

  if (missingCount > 0) {
    exit(1);
  }
}
