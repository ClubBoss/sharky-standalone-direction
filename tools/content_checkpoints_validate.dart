import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('content/ missing');
    exit(1);
  }

  var failures = 0;

  for (final module in root.listSync().whereType<Directory>()) {
    final moduleId = module.uri.pathSegments.lastWhere(
      (segment) => segment.isNotEmpty,
    );
    final checkpoints = Directory('${module.path}/checkpoints');
    if (!checkpoints.existsSync()) {
      print('[CHECKPOINTS] $moduleId -> missing directory');
      failures++;
      continue;
    }

    final entries = checkpoints.listSync().whereType<File>().where((file) {
      final name = file.uri.pathSegments.last;
      return !name.startsWith('.');
    }).toList();

    if (entries.isEmpty) {
      print('[CHECKPOINTS] $moduleId -> empty');
      failures++;
      continue;
    }

    bool hasNonEmpty = false;
    for (final entry in entries) {
      if (entry.path.endsWith('.md') || entry.path.endsWith('.jsonl')) {
        if (entry.lengthSync() > 0) {
          hasNonEmpty = true;
          break;
        }
      }
    }

    if (!hasNonEmpty) {
      print('[CHECKPOINTS] $moduleId -> all blank');
      failures++;
    }
  }

  if (failures == 0) {
    print('Checkpoints OK');
    exit(0);
  }
  exit(1);
}
